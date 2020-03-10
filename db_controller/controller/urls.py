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

from django.urls import path
from . import views

urlpatterns = [
    path('get_places_all/', views.get_places_all, name='get_places_all'),
    path('regist_images/', views.regist_images, name='regist_images'),
    path('regist_faces/', views.regist_faces, name='regist_faces'),
    path('get_unanalyzed_face_location_images/', views.get_unanalyzed_face_location_images, name='url_un_face_location_images'),
    path('get_unanaluzed_face_location_images_count/', views.get_unanalyzed_images_count),
    path('get_unanalyzed_face_encodings/', views.get_unanalyzed_face_encoding_faces),
    path('regist_face_encodings/', views.regist_encodings, name='regist_encodings'),
    path('get_face_encodings/', views.get_face_encodings, name='get_face_encodings'),
]
