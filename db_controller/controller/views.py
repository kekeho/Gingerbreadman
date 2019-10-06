# Copyright (c) 2019 Hiroki Takemura (kekeho)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


from django.shortcuts import render
from django.http import HttpResponseNotAllowed, Http404, HttpResponseNotFound
from django.utils import timezone
from datetime import datetime
from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from PIL import Image, ExifTags
from django.core.files.uploadedfile import InMemoryUploadedFile
import os
import redis

from . import models

redis_client = redis.client.Redis(host='redis')


def get_places_all(request):
    places = models.Place.objects.all()
    resp_data = {'places': [p.name for p in places]}
    return JsonResponse(resp_data)


@csrf_exempt
def regist_images(request):
    places = models.Place.objects.all()
    context = {'places': [p.name for p in places]}

    if request.method == 'POST':
        images = request.FILES.getlist('images')
        print(len(images), images)
        images_mtimes = list(map(
            int, request.POST.get('images_mtimes').split(',')
        ))
        place_selected = request.POST.get('place_selected')
        place_new = request.POST.get('place_new')
        place_form = place_new if place_new else place_selected

        # save to db
        for image, mtime in zip(images, images_mtimes):
            i = models.Image()

            # filename
            i.filename = str(image)

            # date
            date = datetime.fromtimestamp(mtime/1000)
            d = models.Date.objects.get_or_create(year=date.year,
                                                  month=date.month,
                                                  day=date.day)
            i.date = d[0]

            # datetime
            i.datetime = date

            # place
            place = models.Place.objects.get_or_create(name=place_form)
            i.place = place[0]

            # photo
            i.image = image

            # Set analyzed False (waiting analyze)
            i.service_face_encoding_analyzed = False

            i.save()

            # Regist analyze queue
            redis_client.lpush('service_face_encoding_queue', i.id)
            print(i)

        return JsonResponse(context)

    else:
        return HttpResponseNotAllowed(['POST'])


@csrf_exempt
def get_unanalyzed_face_location_images(request):
    if request.method != 'GET':
        HttpResponseNotAllowed(["GET"])

    images = models.Image.objects.filter(service_face_location_analyzed=False)
    if list(images) == []:
        return HttpResponseNotFound()

    return JsonResponse([[str(i.id), str(i.image.url)] for i in images], safe=False)


@csrf_exempt
def regist_faces(request):
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])
    
    # [
    #   {"image_id": models.Image.id,
    #    "location": [x, y, w, h]
    #   }
    #   ...
    # ]

    face_list = json.loads(request.body)

    for face_info in face_list:
        face = models.Face()
        parent_image = models.Image.objects.get(id=face_info['image_id'])
        face.image = parent_image
        parent_image.service_face_location_analyzed = True

        (x, y, w, h) = face_info['location']
        face.face_location_x = x
        face.face_location_y = y
        face.face_location_w = w
        face.face_location_h = h

        parent_image.save()
        face.save()

    return JsonResponse({'message': 'Done'})
