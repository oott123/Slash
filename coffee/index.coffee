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
defaultDocPort = args.docport or 33300
args.docsetdir = args.docsetdir or "#{process.cwd()}/Docsets/"

mainWindow = null

require('./server/doc-server').run(defaultDocPort, args.docsetdir)

app.on 'ready', ->
    mainWindow = new browserWindow
        width: 1000
        height: 710
        "web-preferences":
            "direct-write": true
            "overlay-scrollbars": false
        icon: "#{process.cwd()}/Slash.png"
    mainWindow.openDevTools() if args.debug
    mainWindow.loadUrl 'file://' + __dirname + '/../browser/index.html'
ipc.on 'showMainWindow', ->
    mainWindow.show()