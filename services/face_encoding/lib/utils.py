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


class EncodingAnalzyer(object):
    def __init__(self, db_controller_host: str, db_controller_port: int, get_unanalyzed_faces_endpoint: str, regist_entrypoint: str):
        self.db_controller_url = f'http://{db_controller_host}:{db_controller_port}'
        self.get_unanalyzed_faces_endpoint = urljoin(self.db_controller_url,
                                                     get_unanalyzed_faces_endpoint)
        self.regist_entrypoint = urljoin(self.db_controller_url,
                                         regist_entrypoint)

        self.unanalyzed_ids = []
        self.unanalyzed_urls = []
        self.known_locations = []
        self.__get_unanalyzed_urls_ids()
        self.images = get_images_with_url(self.unanalyzed_urls)

        self.encodings = None

    def __get_unanalyzed_urls_ids(self) -> List[str]:
        print(f'CHECK FROM {self.get_unanalyzed_faces_endpoint}')
        resp = requests.get(self.get_unanalyzed_faces_endpoint)
        if resp.status_code == 404:
            return

        resp_json = resp.json()

        for id, url, location in resp_json:
            self.unanalyzed_ids.append(id)
            normalize_url = urljoin(self.db_controller_url, url)
            self.unanalyzed_urls.append(normalize_url)
            self.known_locations.append(location)

    def analyze_face_encodings(self):
        self.encodings = [list(face_recognition.face_encodings(img, known_face_locations=loc)[0])
                          for img, loc in zip(self.images, self.known_locations)]

    def regist(self):
        if len(self.encodings) <= 0:
            return 0

        data = []
        for id, encoding in zip(self.unanalyzed_ids, self.encodings):
            data += [{'face_id': id, 'encoding': encoding}]

        resp = requests.post(self.regist_entrypoint, json=data)

        if resp.status_code != 200:
            raise RegistError

        return len(data)
