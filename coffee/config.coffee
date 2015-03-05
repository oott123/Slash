args = require './args'
fs = require 'fs'
_ = require 'lodash'
defaultConfig =
    maxItem: 100
    searchDelay: 300
    shortCut: 'Alt+Enter'
exports.save = ->
    fs.writeFileSync 'config.json', JSON.stringify(exports.config)

try
    data = fs.readFileSync 'config.json'
    exports.config = _.extend(defaultConfig, JSON.parse(data))
catch e
    exports.config = defaultConfig
