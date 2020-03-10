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
    # Get images as base64
    # base_url = 'http://db-controller:8888'
    return_dict = dict()
    for group_id, person in enumerate(grouped_faces):
        return_group_dict = dict()
        return_group_dict['faces'] = []
        for i, face_ in enumerate(person['faces']):
            # image_url = urllib.parse.urljoin(base_url, face['image_url'])
            face = controller_models.Face.get(face_['id'])
            face_img = face_model.image.image

            face_dict = serializers.serialize(face)

            with BytesIO() as onmemory_file:
                top, right, bottom, left = (face.face_location_x, face.face_location_y, face.face_location.w, face.face_location.h)
                croped = face_img.crop((left, top, right, bottom))
                croped.save(onmemory_file, 'jpeg')
                b64 = base64.b64encode(onmemory_file.getvalue())
                b64 = b'data:image/jpeg;base64,' + b64  # HTML img src
                # grouped_faces[group_id]['faces'][i]['face_image'] = str(b64)[2:-1]
                face_dict['face_image'] = str(b64)[2:-1]
            return_group_dict['faces'].add(face_dict)

        return_dict[group_id] = return_group_dict
            

    
    # Set person color (random)
    for group_id, _ in enumerate(grouped_faces):
        return_dict[group_id]['person_color'] = tuple(map(lambda ab:random.randint(*ab), [(128, 255)] * 3))

    context = {'grouped_faces': return_dict}
    return JsonResponse(context, safe=False)

