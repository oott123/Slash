args = require './args'
path = require 'path'
fs = require 'fs'

bmkFile = path.join args.profiledir, 'bookmarks.json'
bookmarks = []
try
    bookmarks = fs.readFileSync bmkFile
catch
    bookmarks = [
        {
            title: 'Slash Project'
            subItems: [
                {
                    title: 'GitHub'
                    url: 'https://github.com/oott123/Slash'
                }
                {
                    title: 'Issues'
                    url: 'https://github.com/oott123/Slash/issues'
                }
            ]
        }
    ]
exports.bookmarks = bookmarks
exports.save = ->
    fs.writeFileSync bmkFile, JSON.stringify(bookmarks, null, '\t')