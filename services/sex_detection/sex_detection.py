from tensorflow import keras
from PIL import Image
import requests
from io import BytesIO
from typing import List, Tuple
import numpy as np
from urllib.parse import urljoin
import model
import os
import time


sexmodel = keras.models.load_model('sex_detection.h5')


def get_image(url: str, location: List[int]) -> Image.Image:
    resp = requests.get(url)
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



class SexAnalyzer():
    def __init__(self, db_controller_host: str, db_controller_port: int, get_unanalyzed_faces_url: str, regist_url: str):
        self.db_controller_url = f'http://{db_controller_host}:{db_controller_port}'
        self.get_unanalyzed_faces_url = urljoin(self.db_controller_url, get_unanalyzed_faces_url)
        self.regist_url = urljoin(self.db_controller_url, regist_url)

        self.unanalyzed_ids = []
        self.unanalyzed_urls = []
        self.known_locations = []
        self.__get_unanalyzed_urls_ids()  # get unanalyzed faces
        self.images = get_images_with_url(self.unanalyzed_urls, self.known_locations)

        self.sexlist = None
    
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
    
    def analyze(self):
        self.sexlist = [model.result_to_sex(result) for result in sexmodel.predict(self.images)]

    def regist(self):
        if len(self.sexlist) <= 0:  # Empty
            return
        
        data = []
        for id, sex in zip(self.unanalyzed_ids, self.sexlist):
            sex_str = 'MALE' if sex == model.Sex.MALE else 'FEMALE'
            data.append({'face_id': id, 'sex': sex_str})
        
        resp = requests.post(self.regist_url, json=data)
        
        if resp.status_code != 200:
            raise RegistError
            
        return len(data)


def main():
    while True:
        analyzer = SexAnalyzer(
            os.getenv('NGINX_HOST'), int(os.getenv('NGINX_PORT')),
            '/api/db/get_unanalyzed_faces_sex/',
            'api/db/regist_faces_sex/',
        )

        if len(analyzer.unanalyzed_ids) <= 0:
            time.sleep(5)
            continue

        analyzer.analyze()
        count = analyzer.regist()

        print(f'Analyzed {count} images')



if __name__ == "__main__":
    main()
