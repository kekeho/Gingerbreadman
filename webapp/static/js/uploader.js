// Copyright (c) 2019 Hiroki Takemura (kekeho)
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

file_form = document.getElementById('file_form');
file_form.value = null;  // Init

file_mtimes_form = document.getElementById('file_mtimes');

file_form.onchange = function(ev) {
    let dates = [];
    const files = ev.target.files;
    for (let i = 0; i < files.length; i++) {
        const date = files[i].lastModified;
        dates.push(date);
    }

    file_mtimes_form.value = dates.toString();
};
