Promise = require 'bluebird'
knex = require 'knex'

config = require('../config').config

class module.exports
    constructor: (@fileName) ->
        @k = knex
            client: 'sqlite3'
            connection:
                filename: @fileName
        @k.schema.hasTable('searchIndex').then (isZDash)=>
            @isZDash = !isZDash
    s: ->
        @k('searchIndex')
    nameLike: (match, limit = config.maxItem / 2)->
        match = match.replace /([%_])/g, '\\$1'
                     .replace /\?/g, '_'
                     .replace /\*/g, '%'
        if @isZDash
            @k.raw '
                SELECT
                    ztoken.z_pk AS id,
                    ztoken.ztokenname AS name,
                    ztokentype.ztypename AS type,
                    printf("%s#%s", zfilepath.zpath, ztokenmetainformation.zanchor) AS path
                FROM ztoken
                JOIN ztokenmetainformation ON ztoken.zmetainformation = ztokenmetainformation.z_pk
                JOIN zfilepath ON ztokenmetainformation.zfile = zfilepath.z_pk
                JOIN ztokentype ON ztoken.ztokentype = ztokentype.z_pk
                WHERE name LIKE ? ESCAPE "\\" COLLATE NOCASE LIMIT ?
                ', [match, limit]
        else
            @s().whereRaw('name LIKE ? ESCAPE "\\" COLLATE NOCASE', match).limit(limit)
    getIndexCount: ->
        if @isZDash
            @k('ztoken').count('ztokenname')
            .then (rows) ->
                rows[0]['count("ztokenname")']
        else
            @s().count('name')
            .then (rows)->
                rows[0]['count("name")']
    matchExactly: (key, limit = 1)->
        @nameLike(key, limit)
    matchHead: (string)->
        @nameLike("#{string}*")
    matchTail: (string)->
        @nameLike("*#{string}")
    matchMiddle: (string)->
        @nameLike("*#{string}*")
    matchDeep: (string)->
        match = ''
        depth = 1
        for char, i in string
            match += '*' unless i % depth
            match += char
        @nameLike("*#{match}*")