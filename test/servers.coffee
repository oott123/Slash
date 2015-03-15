should = require 'should'
Promise = require 'bluebird'
path = require 'path'

apiServer = require '../coffee/server/api'
docServer = require '../coffee/server/doc-server'

describe 'Servers running', ->
    it 'should start doc server correctly', (done)->
        docServer.run 33300, path.join(__dirname, '../Docsets')
        .then (port)->
            port.should.be.a.Number.which.is.above 33299
            done()
    it 'should start api server correctly', (done)->
        apiServer.run 33400
        .then (port)->
            port.should.be.a.Number.which.is.above 33399
            done()
describe 'Servers running', ->
    @timeout 100000000
    it 'should start api server correctly', (done)->
        #done()