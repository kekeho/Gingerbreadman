from django.contrib import admin
from .models import Date, Place, Gender, AgeGroup, Image, Face, Person

admin.site.register([Date, Place, Gender, AgeGroup, Image, Face, Person])
