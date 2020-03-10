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
