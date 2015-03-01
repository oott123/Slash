should = require 'should'

plistReader = require '../coffee/docset/plist-reader'

describe 'Plist reader test', ->
    it 'should parse xml correctly', (done)->
        r = new plistReader 'Docsets/PHP.docset/Contents/Info.plist'
        r.parse().then (data)->
            console.log data
            done()