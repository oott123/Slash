should = require 'should'

plistReader = require '../coffee/docset/plist-reader'
db = require '../coffee/docset/db'
fs = require 'fs'
Promise = require 'bluebird'

# Get the docsets list
docsets = []
files = fs.readdirSync 'Docsets'
for i in files
    docsetDir = "Docsets/#{i}"
    docsets.push docsetDir if fs.statSync(docsetDir).isDirectory()

describe 'Plist reader test', ->
    it 'should parse docsets correctly', (done)->
        isDocset = (data)->
            data.should.have.property 'CFBundleIdentifier'
            data.should.have.property 'CFBundleName'
            data.should.have.property 'DocSetPlatformFamily'
            data.should.have.property 'isDashDocset', true
        files = fs.readdirSync 'Docsets'
        promises = []
        for docsetDir in docsets
            promises.push new plistReader("#{docsetDir}/Contents/Info.plist").parse()
        Promise.all(promises)
        .then (data)->
            data.map isDocset
            null
        .then done
        .catch (e)->
            throw e
describe 'Search index test', ->
    it 'should get search index count correctly', (done)->
        promises = []
        for docsetDir in docsets
            d = new db "#{docsetDir}/Contents/Resources/docSet.dsidx"
            promises.push d.getIndexCount()
        Promise.all promises
        .then (data)->
            data.map (count)->
                count.should.above 0
            null
        .then done