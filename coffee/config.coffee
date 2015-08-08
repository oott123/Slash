args = require './args'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
browserWindow = require 'browser-window'
defaultConfig =
    maxItem: 100
    searchDelay: 300
    shortCut: 'Alt+Enter'
configFile = path.join(args.profiledir, 'config.json')
exports.save = ->
    fs.writeFileSync configFile, JSON.stringify(exports.config, null, '\t')

try
    data = fs.readFileSync configFile
    exports.config = _.extend(defaultConfig, JSON.parse(data))
catch e
    exports.config = defaultConfig
exports.configWindow = null
exports.showConfigWindow = ->
    exports.configWindow = new browserWindow
        width: 600
        height: 300
        "web-preferences":
            "direct-write": true
            "overlay-scrollbars": false
        icon: path.join(path.dirname(__dirname), 'Slash.png')
    exports.configWindow.loadUrl 'file://' + __dirname + '/../browser/config.html'
exports.closeConfigWindow = ->
    exports.configWindow.close()