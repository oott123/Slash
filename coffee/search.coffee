ipc = require 'ipc'
ds = require './docset/index'

dsStorage = {}

console.log 'loading search module'

ipc.on 'searchRequest', (e, data)->
    console.log 'ipc: received search request', data
    handle = new ds data.keyword
    handle.on 'result', (data)->
        e.sender.send 'searchResult',
            id: data.id
            result: data
    handle.on 'error', (err)->
        console.log err
        e.sender.send 'searchError',
            id: data.id
            error: err
    handle.on 'finish', ->
        e.sender.send 'searchFinish',
            id: data.id
    handle.on 'finally', ->
        delete dsStorage[data.id]
    handle.match()
    dsStorage[data.id] = handle
ipc.on 'searchAbort', (e, id)->
    dsStorage[id]?.abort()