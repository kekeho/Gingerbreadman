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

from . import models
from . import view_utils


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


def get_unanalyzed_face_encoding_faces(request):
    """Return face parent image and rect of face"""
    if request.method != 'GET':
        HttpResponseNotAllowed(['GET'])

    faces = models.Face.objects.filter(service_face_encoding_analyzed=False)
    if list(faces) == []:
        return HttpResponseNotFound()

    def get_face_location(f): return [(
            int(f.face_location_x), int(f.face_location_y),
            int(f.face_location_w), int(f.face_location_h)
        )]

    return JsonResponse([[str(f.id), str(f.image.image.url), get_face_location(f)] for f in faces], safe=False)


@csrf_exempt
def regist_encodings(request):
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    # [
    #   {"face_id": models.Image.id,
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
