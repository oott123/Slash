should = require 'should'

plistReader = require '../coffee/docset/plist-reader'

describe 'Plist reader test', ->
    it 'should parse xml correctly', (done)->
        r = new plistReader 'Docsets/NodeJS_(v0.10.32).docset/Contents/Info.plist'
        r.parse().then (data)->
            data.should.have.property 'CFBundleIdentifier'
            data.should.have.property 'CFBundleName'
            data.should.have.property 'DocSetPlatformFamily'
            data.should.have.property 'dashIndexFilePath'
            done()