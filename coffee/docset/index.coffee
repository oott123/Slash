db = require './db'
plistReader = require './plist-reader'
fs = require 'fs'
Promise = require 'bluebird'

docsets = []

getDocsets = (forceUpdate = false)->
    if !forceUpdate and docsets.length > 0
        Promise.resolve docsets
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
class AbortedByUser
class module.exports extends require('events').EventEmitter
    constructor: (@keyword)->
    match: ->
        that = this
        @aborted = false
        chain = Promise.resolve true
        getDocsets()
        .then (docsets)->
            for method in ['matchExactly', 'matchHead', 'matchTail', 'matchMiddle', 'matchDeep']
                for docset in docsets
                    do (method, docset)->
                        chain = chain.then ->
                            throw new AbortedByUser if that.aborted
                            docset.db[method](that.keyword)
                        .then (data)->
                            that.emit 'result',
                                result: data
                                keyword: that.keyword
                                method: method
                                docset: docset
            chain
        .then ->
            that.emit 'finish'
        .catch (err)->
            if err instanceof AbortedByUser
                that.emit 'abort'
            else
                that.emit 'error', err
        .finally ->
            that.emit 'finally'
    abort: ->
        @aborted = true
