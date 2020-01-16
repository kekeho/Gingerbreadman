# Copyright (C) 2019 Hiroki Takemura (kekeho)
# 
# This file is part of Gingerbreadman.
# 
# Gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

from PIL import Image
import requests
from typing import List
import face_recognition
import numpy as np
from io import BytesIO
import json
from urllib.parse import urljoin
import multiprocessing as mp
import os


GPU_ENV = True if os.getenv('GB_GPU') != None else False
print("GPU_ENV =", GPU_ENV)


def get_image(url: str) -> Image.Image:
    resp = requests.get(url)
    image = BytesIO(resp.content)
    pil_image = Image.open(image)
    return pil_image


def get_images_with_url(urls: List[str]) -> List[np.ndarray]:
    images = [np.asarray(get_image(url)) for url in urls]
    return images


def mp_cnn_wrapper(image: np.ndarray):
    return face_recognition.api.face_locations(image, model='cnn')


def check_same_size(images: np.array):
    first = images[0].shape
    for i in images[1:]:
        if i.shape != first:
            return False
    
    return True


class RegistError(Exception):
    pass


class LocationAnalzyer(object):
    def __init__(self, db_controller_host: str, db_controller_port: int, get_unanalyzed_images_endpoint: str, regist_entrypoint: str):
        self.db_controller_url = f'http://{db_controller_host}:{db_controller_port}'
        self.get_unanalyzed_images_endpoint = urljoin(self.db_controller_url, get_unanalyzed_images_endpoint)
        self.regist_entrypoint = urljoin(self.db_controller_url, regist_entrypoint)
        print('SELF.REGIST_EP', self.regist_entrypoint)
        self.unanalyzed_ids = []
        self.unanalyzed_urls = []
        self.__get_unanalyzed_urls_ids()
        self.images = get_images_with_url(self.unanalyzed_urls)

        self.locations = []

    def __get_unanalyzed_urls_ids(self) -> List[str]:
        print(f'CHECK FROM {self.get_unanalyzed_images_endpoint}')
        resp = requests.get(self.get_unanalyzed_images_endpoint)
        if resp.status_code == 404:
            return

        try:
            resp_json = resp.json()
        except json.decoder.JSONDecodeError as e:
            return

        for id, url in resp_json:
            self.unanalyzed_ids.append(id)
            normalize_url = urljoin(self.db_controller_url, url)
            self.unanalyzed_urls.append(normalize_url)

    def analyze_face_locations(self):
        if len(self.images) <= 0:
            return

        if GPU_ENV:
            if check_same_size(self.images):
                self.locations = face_recognition.api.batch_face_locations(self.images, batch_size=30)
            else:
                # Multiprocessing with CNN
                with mp.Pool(mp.cpu_count()) as pool:
                    self.locations = pool.map(mp_cnn_wrapper, self.images)
        else:
            # CPU Multiprocessing without CNN
            with mp.Pool(mp.cpu_count()) as pool:
                self.locations = pool.map(face_recognition.api.face_locations, self.images)

    def regist(self):
        if len(self.locations) <= 0:
            return 0
        
        data = []
        for id, locations in zip(self.unanalyzed_ids, self.locations):
            data += [{'image_id': id, 'location': l} for l in locations]
        
        resp = requests.post(self.regist_entrypoint, json=data)

        if resp.status_code != 200:
            raise RegistError

        return len(data)
