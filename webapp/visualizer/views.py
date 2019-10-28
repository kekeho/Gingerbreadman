from django.shortcuts import render
from django.http import HttpResponseNotAllowed
import requests
import json
from PIL import Image
import urllib
import base64
from io import BytesIO


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

        # Get images as base64
        base_url = 'http://db-controller:8888'
        for group_id, faces in grouped_faces.items():
            for i, face in enumerate(faces):
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
                        grouped_faces[group_id][i]['face_image'] = str(b64)[2:-1]

        context = {'grouped_faces': grouped_faces}
        return render(request, 'visualizer/visualizer.html', context=context)
