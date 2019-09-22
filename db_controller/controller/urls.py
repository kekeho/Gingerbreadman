# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

from django.urls import path
from . import views

urlpatterns = [
    path('get_places_all/', views.get_places_all, name='get_places_all'),
    path('regist_images/', views.regist_images, name='regist_images')
]
