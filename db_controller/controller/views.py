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

from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotAllowed, Http404, HttpResponseNotFound
from django.utils import timezone
from datetime import datetime
from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from PIL import Image, ExifTags
from django.core.files.uploadedfile import InMemoryUploadedFile
import os
from datetime import timedelta

from . import models
from . import view_utils


def get_face_location(f: models.Face):
    return (
        int(f.face_location_x), int(f.face_location_y),
        int(f.face_location_w), int(f.face_location_h)
    )


def get_places_all(request):
    places = models.Place.objects.all()
    resp_data = [{'name': p.name,
                  'latitude': p.latitude,
                  'longitude': p.longitude}
                 for p in places]
    return JsonResponse(resp_data, safe=False)


@csrf_exempt
def regist_images(request):
    places = models.Place.objects.all()
    context = {'places': [p.name for p in places]}

    if request.method == 'POST':
        images = request.FILES.getlist('images')
        images_mtimes = list(map(
            int, request.POST.getlist('images_mtimes')
        ))

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
            place = view_utils.get_place(request)
            place.save()
            i.place = place

            # photo
            i.image = image

            # Set analyzed False (waiting analyze)
            i.service_face_encoding_analyzed = False

            i.save()

        return JsonResponse(context)

    else:
        return HttpResponseNotAllowed(['POST'])


@csrf_exempt
def get_unanalyzed_face_location_images(request):
    if request.method != 'GET':
        HttpResponseNotAllowed(["GET"])

    # Get unanalyzed images
    unixstart = datetime.fromtimestamp(0)
    locktime = timezone.now() - timedelta(minutes=10)
    images = models.Image.objects.filter(
        service_face_location_analyzed=False,
        service_face_location_analyzing_startdate__range=(unixstart, locktime),
        )[:100]  # 100 images per request

    if list(images) == []:
        return HttpResponseNotFound()
    
    # Refresh service_face_location_analyzing_startdate
    for image in images:
        image.service_face_location_analyzing_startdate = timezone.now()
        image.save()

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
        parent_image = models.Image.objects.get(id=face_info['image_id'])
        parent_image.service_face_location_analyzed = True
        parent_image.save()
        
        if face_info['location'] != []:
            face = models.Face()
            face.image = parent_image
            
            (x, y, w, h) = face_info['location']
            face.face_location_x = x
            face.face_location_y = y
            face.face_location_w = w
            face.face_location_h = h
            
            face.save()

    return JsonResponse({'message': 'Done'})


def get_unanalyzed_face_encoding_faces(request):
    """Return face parent image and rect of face"""
    if request.method != 'GET':
        HttpResponseNotAllowed(['GET'])
    
    # Get unanalyzed faces
    unixstart = datetime.fromtimestamp(0)
    locktime = timezone.now() - timedelta(minutes=10)
    faces = models.Face.objects.filter(
        service_face_encoding_analyzed=False,
        service_face_encoding_analyzing_startdate__range=(unixstart, locktime),
        )[:100]  # 100 images per request

    if list(faces) == []:
        return HttpResponseNotFound()
    
    # Refresh service_face_encoding_analyzing_startdate
    for face in faces:
        face.service_face_encoding_analyzing_startdate = timezone.now()
        face.save()

    return JsonResponse([[str(f.id), str(f.image.image.url), [get_face_location(f)]] for f in faces], safe=False)


@csrf_exempt
def regist_sex(request):
    if request.method != 'POST':
        return HttpResponseNotAllowed(['POST'])
    
    # [
    #     {"face_id": models.Face.id,
    #      "sex": "MALE" | "FEMALE"
    #     }
    # ]

    face_list = json.loads(request.body)
    for face_info in face_list:
        id = face_info['face_id']
        sex_id = 1 if face_info['sex'] == 'MALE' else 2 if face_info['sex'] == 'FEMALE' else 0
        
        sex, _ = models.Sex.objects.get_or_create(id=sex_id)

        face = models.Face.objects.get(id=id)
        face.sex = sex
        face.service_sex_detection_analyzed = True
        face.save()
    
    return JsonResponse({'message': 'Done'})


def get_unanalyzed_faces_sex(request):
    """Return face parent image and rect of face"""
    if request.method != 'GET':
        HttpResponseNotAllowed(['GET'])
    
    # Get unanalyzed faces
    unixstart = datetime.fromtimestamp(0)
    locktime = timezone.now() - timedelta(minutes=10)
    faces = models.Face.objects.filter(
        service_sex_detection_analyzed=False,
        service_sex_detection_analyzing_startdate__range=(unixstart, locktime),
        )[:100]  # 100 images per request

    if list(faces) == []:
        return HttpResponseNotFound()
    
    # Refresh service_face_encoding_analyzing_startdate
    for face in faces:
        face.service_sex_detection_analyzing_startdate = timezone.now()
        face.save()

    return JsonResponse([[str(f.id), str(f.image.image.url), get_face_location(f)] for f in faces], safe=False)



@csrf_exempt
def regist_encodings(request):
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    # [
    #   {"face_id": models.Face.id,
    #    "encoding": [x, y, w, h]
    #   }
    #   ...
    # ]

    face_list = json.loads(request.body)
    for face_info in face_list:
        id = face_info['face_id']
        encoding = face_info['encoding']

        face = models.Face.objects.get(id=id)
        face.face_encoding = encoding
        face.service_face_encoding_analyzed = True
        face.save()

    return JsonResponse({'message': 'Done'})


def get_face_encodings(request):
    if request.method != 'GET':
        return HttpResponseNotAllowed(['GET'])

    places = request.GET.getlist('selected_places')
    from_date = str(request.GET.get('from_date'))
    to_date = str(request.GET.get('to_date'))


    faces = models.Face.objects.filter(
        image__place__in=places,
        image__datetime__range=[from_date, to_date],
        service_face_encoding_analyzed=True
    )


    return_faces_info = [{
        'id': str(face.id),
        'image_id': str(face.image.id),
        'image_url': str(face.image.image.url),
        'face_location': [
            int(face.face_location_x),
            int(face.face_location_y),
            int(face.face_location_w),
            int(face.face_location_h),
        ],

        'face_encoding': json.loads(str(face.face_encoding)),
        'place': {
            'name': face.image.place.name,
            'latitude': face.image.place.latitude,
            'longitude': face.image.place.longitude,
        },
        'posix_millisec' : int(face.image.datetime.timestamp() * 1e3),
        'gender': str(face.gender.id) if face.gender else -1,
        'age': int(face.age.id) if face.age else -1,
        'emotion': {
            'smile': float(face.smile),
            'anger': float(face.anger),
            'contempt': float(face.contempt),
            'disgust': float(face.disgust),
            'fear': float(face.fear),
            'happiness': float(face.happiness),
            'neutral': float(face.neutral),
            'sadness': float(face.sadness),
            'surprise': float(face.surprise),
        }
    } for face in faces]

    return JsonResponse(return_faces_info, safe=False)


def get_unanalyzed_images_count(request):
    allowed_method = ['GET']
    if request.method not in allowed_method:
        return HttpResponseNotAllowed(allowed_method)
    
    count = models.Image.objects.filter(service_face_location_analyzed=False).count()
    return HttpResponse(count)