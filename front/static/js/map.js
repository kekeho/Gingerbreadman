// Elm PORT: Initialize Leaflet

var map = null;
var tileLayer = null;

function initMap (mapId) {
    map = L.map('map').setView([36.575,135.984], 5);    // 日本を中心に設定

    tileLayer = L.tileLayer('http://localhost:8000/mapcache/{s}/{z}/{x}/{y}',{
        attribution: '© <a href="http://osm.org/copyright">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19
    });
    tileLayer.addTo(map);
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
    }
});
