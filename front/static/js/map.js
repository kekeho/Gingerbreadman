// Copyright (C) 2020 Hiroki Takemura (kekeho)
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


// Elm PORT: Initialize Leaflet

var map = null;
var tileLayer = null;
var placeMarkerList = null;
var trafficLineList = null;
var layers = null;

function initMap (mapId) {
    placeMarkerList = L.layerGroup();
    trafficLineList = L.layerGroup();
    layers = {
        'people': placeMarkerList,
        'traffic': trafficLineList,
    };

    map = L.map('map').setView([36.575,135.984], 5);    // 日本を中心に設定

    tileLayer = L.tileLayer('http://localhost:8000/mapcache/{s}/{z}/{x}/{y}',{
        attribution: '© <a href="http://osm.org/copyright">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19
    });
    tileLayer.addTo(map);

    L.control.layers([], layers).addTo(map);
}


app.ports.initMap.subscribe(function (id) {
    requestAnimationFrame(function(){
        initMap(id);
    });
});


app.ports.clearMap.subscribe(function (mapId) {
    if (map !== null) {
        map.remove();
        map = null;
        tileLayer = null;
        placeMarkerList = null;
        trafficLineList = null;
        layers = null;
    }
});


app.ports.drawPlaceCirclePort.subscribe(function(place_list) {
    requestAnimationFrame(function() {
        place_list.map(x => placeCircle([x[0].latitude, x[0].longitude], x[0].name, x[1]).addTo(placeMarkerList));
    });
});


app.ports.drawTrafficLinePort.subscribe(function(traffic_list){
    requestAnimationFrame(function() {
        traffic_list.map(function(x){
            let p1position = [x[0].traffic[0].latitude, x[0].traffic[0].longitude];
            let p2position = [x[0].traffic[1].latitude, x[0].traffic[1].longitude];
            let p1name = x[0].traffic[0].name;
            let p2name = x[0].traffic[1].name;
            let p1ToP2Count = x[0].count;
            let p2ToP1Count = (x[1].length === 0) ? 0 : x[1][0].count;
            trafficLine(p1position, p2position, p1name, p2name, p1ToP2Count, p2ToP1Count).addTo(trafficLineList);
        });
    });
});


function placeCircle(position, placeName, count) {
    let size = Math.log10(count) * 20  // logarithmic display 
    return L.circle(position, size, {
        color: '#ff3474',
        weight: 3,
        opacity: 0.8,
        fillColor: '#df3474',
        fillOpacity: 0.3
    }).bindPopup(placeName + ": " + count + " unique people");
}


function trafficLine(position1, position2, p1name, p2name, p1ToP2Count, p2ToP1Count) {
    let weight = p1ToP2Count + p2ToP1Count;
    let p1ToP2Str = p1name + " -> " + p2name + ": " + p1ToP2Count + " counts / ";
    let p2ToP1Str = p2name + " -> " + p1name + ": " + p2ToP1Count + " counts";
    return L.polyline([
        position1,
        position2,
    ],{
        "color": "#ff00ff",
        "weight": weight,
        "opacity": 1.0
    }).bindPopup(p1ToP2Str + p2ToP1Str);
}

