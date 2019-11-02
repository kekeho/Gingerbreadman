Vue.component('simple_modal', {
    template: '#simple_modal',
});

// people components
Vue.component('people', {
    template: '#people',
});


var app = new Vue({
    el: '#app',
    delimiters: ['[[', ']]'],
    data: {
        show_loading_modal: true,
        loading_modal_title: 'Loading',
        loading_modal_message: 'Analyzing and clustering faces',
        grouped_faces: null,
    },

    mounted() {
        this.get_faces();
        this.map();
    },

    methods: {
        get_faces() {
            let get_param = location.search;
            axios.get('/visualizer/grouping' + get_param).then(resp => {
                this.grouped_faces = resp.data;
                this.show_loading_modal = false;
            })
            .catch(err => {
                this.loading_modal_message = 'Cannot loading grouped faces';
                this.loading_modal_title = 'ERROR';
            });
        },
    
        // OSM with OpenLayers
        map() {
            // let map_dom = document.getElementById('map');

            // let client_rect = map_dom.getBoundingClientRect();
            // let height = window.innerHeight - client_rect.top;
            // map_dom.style.height = height + 'px';


            let map = new ol.Map({
                target: 'map',
                layers: [
                    new ol.layer.Tile({
                        source: new ol.source.OSM(),
                    })
                ],
                view: new ol.View({
                    center: ol.proj.fromLonLat([37.41, 8.82]),
                    zoom: 4,
                })
            });
        },
    }
});
