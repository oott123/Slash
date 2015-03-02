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
    matchExactly: (key)->
        @s().where 'name', 'like', key
    matchHead: (string)->
        @s().where 'name', 'like', "#{string}%"
    matchTail: (string)->
        @s().where 'name', 'like', "%#{string}"
    matchMiddle: (string)->
        @s().where 'name', 'like', "%#{string}%"
    matchDeep: (string, depth = 1)->
        match = ''
        for char, i in string
            match += '%' unless i % depth
            match += char
        @s().where 'name', 'like', match