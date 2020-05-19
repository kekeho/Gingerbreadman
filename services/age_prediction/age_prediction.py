# Copyright (C) 2020 Hiroki Takemura (kekeho)
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

from tensorflow import keras
from PIL import Image
import requests
from io import BytesIO
from typing import List, Tuple
import numpy as np
from urllib.parse import urljoin
import os
import time
import asyncio


agemodel = keras.models.load_model('age_prediction.h5')


def get_image(url: str, location: List[int]) -> Image.Image:
    resp = requests.get(url, timeout=3)
    image = BytesIO(resp.content)
    
    # preprocess
    pil_image = Image.open(image)
    pil_image = pil_image.convert('RGB')
    margin = 50  # 50px
    top, right, bottom, left = location
    croped = pil_image.crop((left-margin, top-margin, right+margin, bottom+margin))
    croped.thumbnail((200, 200))
    preprocessed = Image.new(croped.mode, (200, 200), 255)
    preprocessed.paste(croped)

    return preprocessed


def get_images_with_url(urls: List[str], locations: List[List[int]]) -> np.ndarray:
    images = [np.asarray(get_image(url, location), dtype=np.float16)[:,:,:3] for url, location in zip(urls, locations)]  # trim RGB
    return np.array(images)

class RegistError(Exception):
    pass


class AgeAnalyzer():
    def __init__(self, db_controller_host: str, db_controller_port: int, get_unanalyzed_faces_url: str, regist_url: str):
        self.db_controller_url = f'http://{db_controller_host}:{db_controller_port}'
        self.get_unanalyzed_faces_url = urljoin(self.db_controller_url, get_unanalyzed_faces_url)
        self.regist_url = urljoin(self.db_controller_url, regist_url)

        self.unanalyzed_ids = []
        self.unanalyzed_urls = []
        self.known_locations = []
        self.__get_unanalyzed_urls_ids()  # get unanalyzed faces
        self.images = get_images_with_url(self.unanalyzed_urls, self.known_locations)

        print(f'Got {self.images.shape[0]} images')

        self.agelist = None
    
    def __get_unanalyzed_urls_ids(self) -> List[str]:
        resp = requests.get(self.get_unanalyzed_faces_url)
        if resp.status_code == 404:  # There is no face to analyze
            return
        
        resp_json = resp.json()

        for id, url, location in resp_json:
            self.unanalyzed_ids.append(id)
            normalized_url = urljoin(self.db_controller_url, url)
            self.unanalyzed_urls.append(normalized_url)
            self.known_locations.append(location)
    
    async def analyze(self):
        if self.images.size == 0:
            return 0

        self.agelist = agemodel.predict(self.images)
        return self.regist()

    def regist(self):
        if len(self.agelist) <= 0:  # Empty
            return
        
        data = []
        for id, age in zip(self.unanalyzed_ids, self.agelist):
            data.append({'face_id': id, 'age': int(age)})

        resp = requests.post(self.regist_url, json=data)
        
        if resp.status_code != 200:
            raise RegistError
            
        return len(data)


async def getAnalyzer():
    analyzer = AgeAnalyzer(
        os.getenv('NGINX_HOST'), os.getenv('NGINX_PORT'),
        '/api/db/get_unanalyzed_faces_age/',
        'api/db/regist_faces_age/',
    )

    return analyzer



async def analyze_and_getnext(analyzer: AgeAnalyzer) -> (int, AgeAnalyzer):
    analyzer_task = asyncio.create_task(analyzer.analyze())
    next_analyzer_task =  asyncio.create_task(getAnalyzer())
    count = await analyzer_task
    next_analyzer = await next_analyzer_task

    return count, next_analyzer


def main():
    analyzer = AgeAnalyzer(
            os.getenv('NGINX_HOST'), os.getenv('NGINX_PORT'),
            '/api/db/get_unanalyzed_faces_age/',
            'api/db/regist_faces_age/',
        )
    loop = asyncio.get_event_loop()
    while True:
        n, analyzer = loop.run_until_complete(analyze_and_getnext(analyzer))

        if analyzer.images.size <= 0:
            time.sleep(2)
        else:
            print(n)


if __name__ == "__main__":
    main()