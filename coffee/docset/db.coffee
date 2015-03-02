Promise = require 'bluebird'
knex = require 'knex'

class module.exports
    constructor: (@fileName) ->
        @k = knex
            client: 'sqlite3'
            connection:
                filename: @fileName
    getIndexCount: ->
        @k('searchIndex').count 'name'
        .then (rows)->
            rows[0]['count("name")']