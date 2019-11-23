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
