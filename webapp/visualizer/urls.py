from django.urls import path
from . import views

urlpatterns = [
    path('', views.grouping, name='visualizer-grouping'),
]
