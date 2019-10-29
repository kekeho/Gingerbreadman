from django.urls import path
from . import views

app_name = 'visualizer'

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('select/', views.select, name='select'),
    path('/grouping', views.grouping, name='grouping'),
]
