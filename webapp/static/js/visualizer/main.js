// Copyright (C) 2019 Hiroki Takemura (kekeho)
// 
// This file is part of Gingerbreadman.
// 
// Gingerbreadman is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Gingerbreadman is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

// Elm Init
var app = Elm.Main.init({node: document.getElementById('app')});


// Elm PORT: Initialize OpenLayer
app.ports.initMap.subscribe(function (mapId) {
    var map = new ol.Map({
        layers: [
            new ol.layer.Tile({
                source: new ol.source.OSM()
            })
        ],
        target: mapId,
        view: new ol.View({
            center: [0, 0],
            zoom: 4
        })
    });
});
