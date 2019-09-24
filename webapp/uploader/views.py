# Copyright (c) 2019 Hiroki Takemura (kekeho)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

from django.shortcuts import render
from django.http import HttpResponseNotAllowed
from django.utils import timezone
from datetime import datetime
import requests
from io import BytesIO
from types import FunctionType
import mimetypes

from . import models


def upload_images(request):
    if request.method == 'GET':
        context = requests.get(
            "http://db-controller:8888/get_places_all"
        ).json()
        return render(request, 'upload.html', context)

    elif request.method == 'POST':
        data = {
            'place_selected': request.POST.get('place_selected'),
            'place_new': request.POST.get('place_new'),
            'images_mtimes': request.POST.get('images_mtimes')
        }

        files = [('images', (f.name, f.file, mimetypes.guess_type(f.name)[0]))
                 for f in request.FILES.getlist('images')]

        result = requests.post(url='http://db-controller:8888/regist_images/',
                               data=data, files=files)
        return render(request, 'upload.html', context=result.json())

    else:
        return HttpResponseNotAllowed(['GET', 'POST'])
