Promise = require 'bluebird'
knex = require 'knex'

class module.exports
    constructor: (@fileName) ->
        @k = knex
            client: 'sqlite3'
            connection:
                filename: @fileName
        @s = ->
            @k('searchIndex')
    getIndexCount: ->
        @s().count 'name'
        .then (rows)->
            rows[0]['count("name")']
    matchExactly: (key, limit = 1)->
        @s().where('name', 'like', key).limit(limit)
    matchHead: (string, limit = 50)->
        @s().where('name', 'like', "#{string}%").limit(limit)
    matchTail: (string, limit = 50)->
        @s().where('name', 'like', "%#{string}").limit(limit)
    matchMiddle: (string, limit = 50)->
        @s().where('name', 'like', "%#{string}%").limit(limit)
    matchDeep: (string, limit = 50)->
        match = ''
        depth = 1
        for char, i in string
            match += '%' unless i % depth
            match += char
        @s().where('name', 'like', "%#{match}%").limit(limit)