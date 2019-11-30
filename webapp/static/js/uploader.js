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
