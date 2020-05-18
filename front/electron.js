const express = require('express');
const expressApp = express();

const request = require('request');

const electron = require('electron');
const electronApp = electron.app;


const BrowserWindow = electron.BrowserWindow;

expressApp.use('/static', express.static(__dirname + '/static'));
expressApp.all('/api/*', function(req, res) {
    const apiServerUrl = 'http://localhost:8000' + req.url;
    request(apiServerUrl).pipe(res);
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
