from django.shortcuts import render
from django.http import HttpResponseNotAllowed
import requests
import json


def grouping(request):
    allowed_methods = ['GET', 'POST']
    if request.method not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)

    if request.method == 'GET':
        places = requests.get('http://db-controller:8888/get_places_all').json()
        return render(request, 'visualizer/select.html', places)

    if request.method == 'POST':
        selected_places = request.POST.getlist('places')
        from_date = request.POST.get('datetime-from')
        to_date = request.POST.get('datetime-to')

        # Get faces
        get_params = {
                'selected_places': selected_places,
                'from_date': from_date,
                'to_date': to_date,
            }
        faces = requests.get('http://db-controller:8888/get_face_encodings/', params=get_params).json()

        # Grouping
        headers = {'Content-Type': 'application/json'}
        grouped_faces = requests.post('http://service_face_grouping:8000/cluster/', json.dumps(faces), headers=headers).json()

        context = {'grouped_faces': grouped_faces}
        return render(request, 'visualizer/visualizer.html', context=context)
