Promise = require 'bluebird'
plist = require 'plist'
fs = require 'fs'
class module.exports
    constructor: (@fileName, @plistData = null) ->
    parse: ->
        that = this
        new Promise (reslove, reject)->
            if that.plistData
                return reslove that.plistData
            fs.readFile that.fileName, (err, res)->
                reject err if err
                reslove res.toString()
        .then (plistData)->
            plist.parse plistData