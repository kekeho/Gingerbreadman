from . import models

def get_place(request) -> models.Place:
    place_selected = request.POST.get('place_selected')
    place_new = request.POST.get('place_new')
    new_latitude = request.POST.get('new_latitude')
    new_longitude = request.POST.get('new_longitude')

    if place_new != '':
        p = models.Place()
        p.name = place_new
        p.latitude = new_latitude
        p.longitude = new_longitude

        return p
    else:
        p = models.Place.objects.get(name=place_selected)
        return p
