app = require 'app'
browserWindow = require 'browser-window'
path = require 'path'
fs = require 'fs'
dialog = require 'dialog'
ipc = require 'ipc'
menu = require 'menu'
tray = require 'tray'

args = require './args'
process.chdir args.workdir if args.workdir

mainWindow = null

app.on 'ready', ->
    mainWindow = new browserWindow
        width: 1000
        height: 710
        "web-preferences":
            "direct-write": true
            "overlay-scrollbars": false
    mainWindow.openDevTools() if args.debug
    mainWindow.loadUrl 'file://' + __dirname + '/../browser/index.html'