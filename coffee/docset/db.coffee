Promise = require 'bluebird'
knex = require 'knex'

class module.exports
    constructor: (@fileName) ->
        @k = knex
            client: 'sqlite3'
            connection:
                filename: @fileName
        @s = @k('searchIndex')
    getIndexCount: ->
        @s.count 'name'
        .then (rows)->
            rows[0]['count("name")']
    matchExactly: (key)->
        @s.where 'name', key
    matchHead: (string)->
        @s.where 'name', "#{string}%"
    matchTail: (string)->
        @s.where 'name', "%#{string}"
    matchMiddle: (string)->
        @s.where 'name', "%#{string}%"
    matchDeep: (string, depth)->
        match = ''
        for char, i in string
            match += '%' if i % depth
            match += char
        @s.where 'name', match