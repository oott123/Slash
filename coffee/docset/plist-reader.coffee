Promise = require 'bluebird'
xml2js = require 'xml2js'
class reader
    constructor: (@fileName) ->
    parse: ->
        new Promise (reslove, reject)->
            fs.readFile @fileName, (err, res)->
                reject err if err
                reslove res
        .then (fileData)->
            new Promise (reslove, reject)->
                xml2js.parseString fileData, (err, res)->
                    reject err if err
                    reslove res
        .then (xmlData)->
