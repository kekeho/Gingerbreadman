# Copyright (C) 2020 Hiroki Takemura (kekeho)
# 
# This file is part of gingerbreadman.
# 
# gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

from django.shortcuts import render
from django.http.response import JsonResponse
from django.http import HttpResponse, HttpResponseNotAllowed, Http404, HttpResponseNotFound
from django.core import serializers

from controller import models as controller_models

import requests
import json
import random
import base64
from io import BytesIO
from PIL import Image

def grouping(request):
    allowed_methods = ['GET']
    if request.method not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)

    selected_places = request.GET.getlist('places')
    from_date = request.GET.get('datetime-from')
    to_date = request.GET.get('datetime-to')

    # Get faces
    # get_params = {
    #         'selected_places': selected_places,
    #         'from_date': from_date,
    #         'to_date': to_date,
    #     }
    # faces = requests.get('http://db-controller:8888/get_face_encodings/', params=get_params).json()

    faces = controller_models.Face.objects.filter(
        image__place__in=selected_places,
        image__datetime__range=[from_date, to_date],
        service_face_encoding_analyzed=True,
    )

    faces_info = [
        {'id': str(face.id),
        'face_encoding': json.loads(str(face.face_encoding)),
        } for face in faces]


    # Grouping
    headers = {'Content-Type': 'application/json'}
    grouped_faces = requests.post('http://service_face_grouping:8000/cluster/', json.dumps(faces_info), headers=headers).json()
    grouped_faces = list(grouped_faces.values())
    
    if len(grouped_faces) == 0:
        return JsonResponse({'grouped_faces': []}, safe=False)
    
    # Get images as base64
    # base_url = 'http://db-controller:8888'
    return_list = []
    for group_id, person in enumerate(grouped_faces):
        return_group_list = []
        for i, face_ in enumerate(person['faces']):
            # image_url = urllib.parse.urljoin(base_url, face['image_url'])
            face = controller_models.Face.objects.get(id=face_['id'])
            face_img = face.image.image

            face_dict = dict()
            face_dict['id'] = face.id
            face_dict['image_id'] = face.image.id
            face_dict['image_url'] = face.image.image.url
            face_dict['face_location'] = [
                face.face_location_x, face.face_location_y,
                face.face_location_w, face.face_location_h
            ]
            face_dict['face_encoding'] = json.loads(face.face_encoding)
            face_dict['place'] = {
                'name': face.image.place.name,
                'latitude': face.image.place.latitude,
                'longitude': face.image.place.longitude
            }
            face_dict['posix_millisec'] = int(face.image.datetime.timestamp() * 1e3)
            face_dict['sex'] = face.sex.id

            with BytesIO() as img_fp:
                image = Image.open(face.image.image.file)
                image = image.convert('RGB')

                with BytesIO() as onmemory_file:
                    top, right, bottom, left = (face.face_location_x, face.face_location_y, face.face_location_w, face.face_location_h)
                    croped = image.crop((left, top, right, bottom))
                    croped.save(onmemory_file, 'jpeg')
                    b64 = base64.b64encode(onmemory_file.getvalue())
                    b64 = b'data:image/jpeg;base64,' + b64  # HTML img src
                    # grouped_faces[group_id]['faces'][i]['face_image'] = str(b64)[2:-1]
                    face_dict['face_image'] = str(b64)[2:-1]
            return_group_list.append(face_dict)

        return_list.append(return_group_list)

    context = {'grouped_faces': return_list}
    return JsonResponse(context, safe=False)

