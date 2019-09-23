# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

from django.urls import path
from . import views

urlpatterns = [
    path('', views.upload_images, name='upload_images'),
]
