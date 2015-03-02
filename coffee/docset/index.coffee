db = require './db'
plistReader = require './plist-reader'
fs = require 'fs'
Promise = require 'bluebird'

docsets = []

getDocsets = (forceUpdate = false)->
    if !forceUpdate and docsets.length > 0
        new Promise (reslove)->
            reslove(docsets)
    else
        docsets = []
        promises = []
        files = fs.readdirSync 'Docsets'
        for i in files
            ((i)->
                docsetDir = "Docsets/#{i}"
                if fs.statSync(docsetDir).isDirectory()
                    promises.push(
                        new plistReader("#{docsetDir}/Contents/Info.plist").parse()
                        .then (meta)->
                            docset =
                                name: i
                                docsetDir: docsetDir
                                meta: meta
                                db: new db "#{docsetDir}/Contents/Resources/docSet.dsidx"
                            docsets.push docset
                            docset
                    )
            )(i)
        Promise.all(promises)
class module.exports extends require('events').EventEmitter
    constructor: (@keyword)->
    match: ->
        that = this
        promises = []
        getDocsets()
        .then (docsets)->
            for method in ['matchExactly', 'matchHead', 'matchTail', 'matchMiddle', 'matchDeep']
                for docset in docsets
                    promises.push (docset.db[method](that.keyword)
                        .then (data)->
                            that.emit 'result',
                                result: data
                                keyword: that.keyword
                                method: method
                                docset: docset
                    )
            null
        .then ->
            Promise.all promises
        .then ->
            that.emit 'finish'
        .catch (err)->
            that.emit 'error', err
