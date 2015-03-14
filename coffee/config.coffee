args = require './args'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
defaultConfig =
    maxItem: 100
    searchDelay: 300
    shortCut: 'Alt+Enter'
configFile = path.join(args.profiledir, 'config.json')
exports.save = ->
    fs.writeFileSync configFile, JSON.stringify(exports.config)

try
    data = fs.readFileSync configFile
    exports.config = _.extend(defaultConfig, JSON.parse(data))
catch e
    exports.config = defaultConfig
