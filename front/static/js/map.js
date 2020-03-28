// Elm PORT: Initialize Leaflet

var map = null;
var tileLayer = null;
var placeMarkerList = null;
var layers = null;

function initMap (mapId) {
    placeMarkerList = L.layerGroup();
    layers = {'people': placeMarkerList};

    map = L.map('map', layers=[placeMarkerList]).setView([36.575,135.984], 5);    // 日本を中心に設定

    tileLayer = L.tileLayer('http://localhost:8000/mapcache/{s}/{z}/{x}/{y}',{
        attribution: '© <a href="http://osm.org/copyright">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19
    });
    tileLayer.addTo(map);

    L.control.layers(layers).addTo(map);
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
        layers = null;
    }
});


app.ports.drawPlaceCirclePort.subscribe(function(place_list) {
    requestAnimationFrame(function() {
        place_list.map(x => placeCircle([x[0].latitude, x[0].longitude], x[0].name, x[1]).addTo(placeMarkerList));
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

