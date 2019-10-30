Vue.component('simple_modal', {
    template: '#simple_modal',
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
        }
    }
});
