Promise = require 'bluebird'
xml2js = require 'xml2js'
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
                reslove res
        .then (fileData)->
            new Promise (reslove, reject)->
                xml2js.parseString fileData, (err, res)->
                    reject err if err
                    reslove res
        .then (plistData)->
            dict = plistData.plist.dict[0]
            data = {}
            for k, i in dict.key
                data[k] = dict.string[i] if dict.string[i]
            data