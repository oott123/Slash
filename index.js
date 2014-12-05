var app = require('app');
var browserWindow = require('browser-window');
var path = require('path');
var fs = require('fs');
var dialog = require('dialog');
var ipc = require('ipc');
var menu = require('menu');
var tray = require('tray');

var mainWindow = null;

app.on('ready', function() {
    mainWindow = new browserWindow({
        width: 1000,
        height: 710,
        "web-preferences": {
            "direct-write": true,
            "overlay-scrollbars": false
        },
    });
    mainWindow.toggleDevTools();
    mainWindow.loadUrl('file://' + __dirname + '/browser/index.html');
});