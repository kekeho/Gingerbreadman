from django.shortcuts import render, redirect
from django.http import HttpResponseNotAllowed
from django.http import JsonResponse
import requests
import json
from PIL import Image
import urllib
import base64
from io import BytesIO
import random


def get_places_all(request):
    allowed_methods = ['GET']
    if request.methid not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)
    
    places = requests.get('http://db-controller:8888/get_places_all').json()
    return render(request, 'visualizer/select.html', places)


def dashboard(request):
    allowed_methods = ['GET']
    if request.method not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)

    response = render(request, 'visualizer/visualizer.html')
    return response


def grouping(request):
    allowed_methods = ['GET']
    if request.method not in allowed_methods:
        return HttpResponseNotAllowed(allowed_methods)

    selected_places = request.GET.getlist('places')
    from_date = request.GET.get('datetime-from')
    to_date = request.GET.get('datetime-to')

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

    # Get images as base64
    base_url = 'http://db-controller:8888'
    for group_id, person in grouped_faces.items():
        for i, face in enumerate(person['faces']):
            image_url = urllib.parse.urljoin(base_url, face['image_url'])
            
            with BytesIO() as img_fp:
                binary = requests.get(image_url).content
                img_fp.write(binary)
                image = Image.open(img_fp)

                with BytesIO() as onmemory_file:
                    top, right, bottom, left = face['face_location']
                    croped = image.crop((left, top, right, bottom))
                    croped.save(onmemory_file, 'jpeg')
                    b64 = base64.b64encode(onmemory_file.getvalue())
                    b64 = b'data:image/jpeg;base64,' + b64  # HTML img src
                    grouped_faces[group_id]['faces'][i]['face_image'] = str(b64)[2:-1]
    
    # Set person color (random)
    for group_id in grouped_faces.keys():
        grouped_faces[group_id]['person_color'] = tuple(map(lambda ab:random.randint(*ab), [(128, 255)] * 3))

    context = {'grouped_faces': grouped_faces}
    return JsonResponse(context, safe=False)
