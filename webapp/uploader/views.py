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

from . import models


def upload_images(request):
    if request.method == 'GET':
        context = requests.get("http://db-controller:8888/get_places_all").json()
        return render(request, 'upload.html', context)

    elif request.method == 'POST':
        data = {
            'place_selected': request.POST.get('place_selected'),
            'place_new': request.POST.get('place_new')
        }

        for file in request.FILES.getlist('images'):
            files = {file.name: file.read()}
            result = requests.post(url='http://db-controller:8888/regist_images/', data=data, files=files)
            print(result)

        return render(request, 'upload.html')
    
    else:
        return HttpResponseNotAllowed(['GET', 'POST'])


