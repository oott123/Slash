app = require 'app'
browserWindow = require 'browser-window'
path = require 'path'
fs = require 'fs'
dialog = require 'dialog'
ipc = require 'ipc'
menu = require 'menu'
tray = require 'tray'

mainWindow = null

app.on 'ready', ->
    require './js/search'
    mainWindow = new browserWindow
        width: 1000
        height: 710
        "web-preferences":
            "direct-write": true
            "overlay-scrollbars": false
    mainWindow.loadUrl 'file://' + __dirname + '/browser/index.html'