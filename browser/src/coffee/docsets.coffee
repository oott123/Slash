fs = require 'fs'
path = require 'path'
profileFile = path.join S.profileDir, 'docsets.json'

try
    exports.profile = JSON.parse(fs.readFileSync profileFile)
catch
    exports.profile = {}
    for i in S.docsets
        name = i.name
        exports.profile[name] =
            shortcut: i.name.replace('.docset', '').toLowerCase()
            enable: true
exports.save = (data)->
    fs.writeFileSync profileFile, JSON.stringify(data)
exports.getDocsetByShortcut = (shortcut)->
    shortcut = shortcut.toLowerCase()
    for i of exports.profile
        return i.name if i.shortcut is shortcut
    false
exports.getDisabledDocsets = ->
    result = []
    for i of exports.profile
        result.push i.name unless i.enabled
    result