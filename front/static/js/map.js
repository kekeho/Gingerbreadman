// Elm PORT: Initialize Leaflet
app.ports.initMap.subscribe(function (mapId) {
    var map = L.map('map').setView([36.575,135.984], 5);    // 日本を中心に設定

    var tileLayer = L.tileLayer('http://localhost:8000/mapcache/{s}/{z}/{x}/{y}',{
        attribution: '© <a href="http://osm.org/copyright">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19
    });
    tileLayer.addTo(map);
});