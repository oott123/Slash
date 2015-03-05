db = require './db'
plistReader = require './plist-reader'
fs = require 'fs'
Promise = require 'bluebird'
args = require '../args'

docsets = []

getDocsets = (forceUpdate = false)->
    if !forceUpdate and docsets.length > 0
        Promise.resolve docsets
    else
        docsets = []
        promises = []
        files = fs.readdirSync args.docsetdir
        for i in files
            do (i)->
                docsetDir = "#{args.docsetdir}/#{i}"
                if fs.statSync(docsetDir).isDirectory()
                    return unless fs.statSync("#{docsetDir}/Contents/Info.plist").isFile()
                    return unless fs.statSync("#{docsetDir}/Contents/Resources/docSet.dsidx").isFile()
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
        Promise.all(promises)
class AbortedByUser
class module.exports extends require('events').EventEmitter
    constructor: (@keyword)->
    match: ->
        that = this
        getDocsets()
        .then (docsets)->
            promises = []
            for method in ['matchExactly', 'matchHead', 'matchTail', 'matchMiddle', 'matchDeep']
                for docset in docsets
                    do (method, docset)->
                        promises.push(new Promise (reslove)->
                            reslove docset.db[method](that.keyword)
                        .catch ->
                            []
                        .then (data)->
                            result: data
                            keyword: that.keyword
                            method: method
                            docset: docset
                        )
            Promise.all promises
        .then (allData)->
            that.emit 'finish', allData
        .catch (err)->
            that.emit 'error', err
        .finally ->
            that.emit 'finally'
