app = require 'app'
browserWindow = require 'browser-window'
path = require 'path'
fs = require 'fs'
dialog = require 'dialog'
ipc = require 'ipc'
menu = require 'menu'
tray = require 'tray'

args = require './args'
defaultDocPort = args.docport or 33300
defaultApiPort = args.apiport or 33400
args.docsetdir = args.docsetdir or path.join(process.cwd(), "Docsets")

mainWindow = null

require('./server/doc-server').run(defaultDocPort, args.docsetdir)
require('./server/api').run(defaultApiPort)

app.on 'ready', ->
    args.mainWindow = mainWindow = new browserWindow
        width: 1000
        height: 710
        "web-preferences":
            "direct-write": true
            "overlay-scrollbars": false
        icon: path.join(path.dirname(__dirname), 'Slash.png')
    mainWindow.openDevTools() if args.debug
    mainWindow.loadUrl 'file://' + __dirname + '/../browser/index.html'
app.on 'window-all-closed', ->
    app.quit()
ipc.on 'showMainWindow', ->
    mainWindow.show()