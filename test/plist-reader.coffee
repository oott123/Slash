should = require 'should'

plistReader = require '../coffee/docset/plist-reader'
fs = require 'fs'
Promise = require 'bluebird'

describe 'Plist reader test', ->
    it 'should parse docsets correctly', (done)->
        isDocset = (data)->
            data.should.have.property 'CFBundleIdentifier'
            data.should.have.property 'CFBundleName'
            data.should.have.property 'DocSetPlatformFamily'
            data.should.have.property 'dashIndexFilePath'
            data.should.have.property 'isDashDocset', true
        files = fs.readdirSync 'Docsets'
        promises = []
        for i in files
            docsetDir = "Docsets/#{i}"
            if fs.statSync(docsetDir).isDirectory()
                promises.push new plistReader("#{docsetDir}/Contents/Info.plist").parse()
        Promise.all(promises)
        .then (data)->
            data.map isDocset
            null
        .then done
        .catch (e)->
            throw e