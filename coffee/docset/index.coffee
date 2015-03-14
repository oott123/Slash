db = require './db'
plistReader = require './plist-reader'
fs = require 'fs'
Promise = require 'bluebird'
args = require '../args'
path = require 'path'
config = require('../config').config

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
                docsetDir = path.join args.docsetdir, i
                if fs.statSync(docsetDir).isDirectory()
                    return unless i.match /\.docset$/
                    return unless fs.statSync(path.join(docsetDir, "Contents/Info.plist")).isFile()
                    return unless fs.statSync(path.join(docsetDir, "Contents/Resources/docSet.dsidx")).isFile()
                    promises.push(
                        new plistReader(path.join(docsetDir, "Contents/Info.plist")).parse()
                        .then (meta)->
                            docset =
                                name: i
                                docsetDir: docsetDir
                                meta: meta
                                db: new db(path.join(docsetDir, "Contents/Resources/docSet.dsidx"))
                            docsets.push docset
                            docset
                    )
        Promise.all(promises)
class AbortedByUser
class module.exports extends require('events').EventEmitter
    constructor: (@keyword, @docset)->
    match: ->
        that = this
        getDocsets()
        .then (docsets)->
            promises = []
            limitDocset = isGlob = false
            keyword = that.keyword
            if that.docset
                limitDocset = that.docset
                    .replace /([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1"
                    .replace /\\\\?/g, '.'
                    .replace /\\\\*/g, '.*'
                limitDocset = new RegExp limitDocset, 'i'
                console.log "Limited Docset: #{limitDocset}"
            if keyword.indexOf('?') >= 0 or keyword.indexOf('*') >= 0
                console.log 'isGlob'
                isGlob = true
            for method in ['matchExactly', 'matchHead', 'matchTail', 'matchMiddle', 'matchDeep']
                for docset in docsets
                    if limitDocset and !docset.meta.CFBundleName.match limitDocset
                        console.log 'skipped: ' + docset.name
                        continue
                    do (method, docset)->
                        promises.push(new Promise (resolve)->
                            if isGlob
                                return resolve docset.db[method](keyword, config.maxItem)
                            resolve docset.db[method](keyword)
                        .catch (e)->
                            console.log "Error when accessing docset #{docset.name}."
                            console.log e
                            []
                        .then (data)->
                            result: data
                            keyword: that.keyword
                            method: method
                            docset: docset
                        )
                if isGlob
                    break   # let it run just matchExactly
            Promise.all promises
        .then (allData)->
            that.emit 'finish', allData
        .catch (err)->
            that.emit 'error', err
        .finally ->
            that.emit 'finally'
    stat: ->
        getDocsets()
        .then (docsets)->
            promises = []
            for docset in docsets
                do (docset)->
                    promises.push(
                        docset.db.getIndexCount().catch (e)->
                            "Error: #{e.message}"
                        .then (data)->
                            docset: docset.meta.CFBundleName
                            data: data
                    )
            Promise.all promises