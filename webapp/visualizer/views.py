from django.shortcuts import render
from django.http import HttpResponseNotAllowed
import requests


def grouping(request):
    allowed_methods = ['GET', 'POST']
    if request.method not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)

    if request.method == 'GET':
        places = requests.get('http://db-controller:8888/get_places_all').json()
        return render(request, 'visualizer/select.html', places)

    if request.method == 'POST':
        selected_places = request.POST.get('places')
        from_date = request.POST.get('datetime-from')
        to_date = request.POST.get('datetime-to')

        return render(request, 'visualizer/visualizer.html')