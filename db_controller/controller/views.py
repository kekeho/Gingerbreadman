# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT



from django.shortcuts import render
from django.http import HttpResponseNotAllowed
from django.utils import timezone
from datetime import datetime
from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from PIL import Image, ExifTags

from . import models


def get_datetime(image) -> datetime:
    """Get datetime object from exif"""
    time_string = None
    exif = image._getexif()
    if exif is None:
        # No exif data
        return None

    for id, val in exif.items():
        tag = ExifTags.TAGS.get(id)
        if tag == "DateTimeOriginal":
            time_string = val.split('+')[0]


    
    if time_string is None:
        # No DateTimeOriginal column
        return None

    # example: 2019:06:14 11:58:27
    time_format = '%Y:%m:%d %H:%M:%S'
    return datetime.strptime(time_string, time_format)


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
        place_selected = request.POST.get('place_selected')
        place_new = request.POST.get('place_new')
        place_form = place_new if place_new else place_selected

        # save to db
        for image in images:
            pil_img = Image.open(image)
            i = models.Image()
            
            # filename
            i.filename = str(image)

            # date
            exif_date = get_datetime(pil_img)
            if exif_date is None:
                context['error'] = f'Broken exif: {image}'
                # return render(request, 'upload.html', context)
                return JsonResponse(context)

            d = models.Date.objects.get_or_create(year=exif_date.year, month=exif_date.month, day=exif_date.day)
            i.date = d[0]

            # datetime
            i.datetime = exif_date

            # place
            place = models.Place.objects.get_or_create(name=place_form)
            i.place = place[0]

            # photo
            i.photo = image

            # Set analyzed False (waiting analyze)
            i.analyzed = False

            i.save()
            print(i)
        

        return JsonResponse(context)
    
    else:
        return HttpResponseNotAllowed(['POST'])

