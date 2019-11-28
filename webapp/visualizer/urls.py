from django.urls import path
from . import views

app_name = 'visualizer'

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('visualizer/get_places_all/', views.get_places_all, name='get_places_all'),
    path('visualizer/grouping/', views.grouping, name='grouping'),
]
