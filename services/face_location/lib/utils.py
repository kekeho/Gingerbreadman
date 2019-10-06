from PIL import Image
import requests
from typing import List
import face_recognition
import numpy as np
from io import BytesIO
import json
from urllib.parse import urljoin


def get_image(url: str) -> Image.Image:
    resp = requests.get(url)
    image = BytesIO(resp.content)
    pil_image = Image.open(image)
    return pil_image


def get_images_with_url(urls: List[str]) -> np.ndarray:
    images = [np.asarray(get_image(url)) for url in urls]
    return np.array(images)


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

        self.locations = None

    def __get_unanalyzed_urls_ids(self) -> List[str]:
        print(f'CHECK FROM {self.get_unanalyzed_images_endpoint}')
        resp = requests.get(self.get_unanalyzed_images_endpoint)
        if resp.status_code == 404:
            return

        resp_json = resp.json()

        for id, url in resp_json:
            self.unanalyzed_ids.append(id)
            normalize_url = urljoin(self.db_controller_url, url)
            self.unanalyzed_urls.append(normalize_url)

    def analyze_face_locations(self):
        # if check_same_size(images):
        #     locations = face_recognition.api.batch_face_locations(images)  # TODO: UP TO 50
        # else:
        #     locations = [face_recognition.api.face_locations(i, model='cnn')  # TODO: UP TO 50
        #                  for i in images]

        print(f'ANALYZING {self.images}')
        self.locations = [face_recognition.api.face_locations(i, model='cnn')  # TODO: UP TO 50
                          for i in self.images]

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
