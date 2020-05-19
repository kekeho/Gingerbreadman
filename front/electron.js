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


const express = require('express');
const url = require('url')
const request = require('request');

const expressApp = express();
const electron = require('electron');
const electronApp = electron.app;


const BrowserWindow = electron.BrowserWindow;

expressApp.use('/static', express.static(__dirname + '/static'));
expressApp.all('/api/*', function(req, res) {
    const apiServerUrl = url.parse('http://localhost:8000' + req.url).href;
    const proxy = request[req.method.toLowerCase()](apiServerUrl)
    req.pipe(proxy);
    proxy.pipe(res);
});
expressApp.get('/', function(req, res) {
    res.sendFile(__dirname + '/index.html');
});
expressApp.listen(9999);



let mainWindow = null;
electronApp.on('ready', () => {
    mainWindow = new BrowserWindow({ width: 600, height: 400 });
    mainWindow.loadURL('http://localhost:9999/');

    mainWindow.on('closed', function () {
            mainWindow = null;
        });
});

electronApp.on('window-all-closed', () => {
    electronApp.quit();
});
