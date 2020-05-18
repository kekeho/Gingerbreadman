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

from django.db import models
from django.core.validators import MaxValueValidator, MinValueValidator
from django.utils import timezone
from datetime import datetime
import uuid


unixzero = datetime.fromtimestamp(0)


def uuid4_str():
    return str(uuid.uuid4())


class Date(models.Model):
    """Date column
    date: Date info
    """
    id = models.AutoField(primary_key=True, unique=True)
    year = models.IntegerField(null=True, validators=[
        MinValueValidator(0),
    ])
    month = models.IntegerField(null=True, validators=[
        MinValueValidator(1), MaxValueValidator(12),
    ])
    day = models.IntegerField(null=True, validators=[
        MinValueValidator(1), MaxValueValidator(31),
    ])


class Place(models.Model):
    """Place column
    name: Place name
    """
    name = models.TextField(null=False, blank=False,
                            primary_key=True, unique=True)
    latitude = models.FloatField(null=False, default=-1.0)
    longitude = models.FloatField(null=False, default=-1.0)


class Sex(models.Model):
    """Sex column
    id: Sex code (ISO 5218)
        0; Not known
        1: Male
        2: Female
    """
    id = models.IntegerField(primary_key=True, validators=[
                             MinValueValidator(0), MaxValueValidator(2)])


class Image(models.Model):
    """Image column
    filename: Photo filename
    date: Date when photo was taken
    place: Place where photo was taken
    image: image file
    face_analyzed: is analyzed by service/face_analyzer
    """
    id = models.CharField(primary_key=True, default=uuid4_str, max_length=36)
    filename = models.CharField(max_length=150, blank=False,
                                null=False)
    date = models.ForeignKey(Date, on_delete=models.PROTECT,
                             blank=False, null=False)
    datetime = models.DateTimeField(
        null=False, blank=False, default=timezone.now)
    place = models.ForeignKey(
        Place, on_delete=models.PROTECT, blank=False, null=False)
    image = models.ImageField(
        upload_to='images', default='default', blank=False, null=False)
    
    service_face_location_analyzing_startdate = models.DateTimeField(null=False, blank=False, default=unixzero)
    service_face_location_analyzed = models.BooleanField(default=False)


class Face(models.Model):
    """Face column
    id: face id (uuid.uuid4().hex)
    image: image which are appeard
    sex: sex code (ISO 5218)
    age: Age group
    smile: smile score (from Microsoft Face API)
    anger ~ surprise: Emotion score (from Microsoft Face API)
    """
    id = models.CharField(max_length=36, primary_key=True, default=uuid4_str, unique=True)
    image = models.ForeignKey(Image, on_delete=models.PROTECT,
                              blank=False, null=False)
    
    # Location on self.image
    face_location_x = models.IntegerField(blank=False, null=False, default=0)
    face_location_y = models.IntegerField(blank=False, null=False, default=0)
    face_location_w = models.IntegerField(blank=False, null=False, default=0)
    face_location_h = models.IntegerField(blank=False, null=False, default=0)

    service_face_encoding_analyzing_startdate = models.DateTimeField(null=False, blank=False, default=unixzero)
    service_face_encoding_analyzed = models.BooleanField(default=False)
    face_encoding = models.TextField(blank=True, null=True)

    service_sex_detection_analyzing_startdate = models.DateTimeField(null=False, blank=False, default=unixzero)
    service_sex_detection_analyzed = models.BooleanField(default=False)
    sex = models.ForeignKey(Sex, on_delete=models.PROTECT,
                               blank=True, null=True)

    service_age_prediction_analyzing_startdate = models.DateTimeField(null=False, blank=False, default=unixzero)
    service_age_prediction_analyzed = models.BooleanField(default=False)
    age = models.IntegerField(null=True, blank=True)

    # Emotion
    smile = models.FloatField(blank=True, default=0.0)
    anger = models.FloatField(blank=True, default=0.0)
    contempt = models.FloatField(blank=True, default=0.0)
    disgust = models.FloatField(blank=True, default=0.0)
    fear = models.FloatField(blank=True, default=0.0)
    happiness = models.FloatField(blank=True, default=0.0)
    neutral = models.FloatField(blank=True, default=0.0)
    sadness = models.FloatField(blank=True, default=0.0)
    surprise = models.FloatField(blank=True, default=0.0)


class Person(models.Model):
    """Person column
    id: Person ID
    faces: which person appeard
    """
    id = models.IntegerField(primary_key=True)
    faces = models.ManyToManyField(Face, blank=False)
