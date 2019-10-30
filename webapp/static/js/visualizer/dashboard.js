Vue.component('modal', {
    template: '#modal-loading'
});


var app = new Vue({
    el: '#app',
    data: {
        showModal: false
    },

    mounted() {
        this.showModal = true;
    }
});
