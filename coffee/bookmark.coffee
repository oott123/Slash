args = require './args'
path = require 'path'
fs = require 'fs'

bmkFile = path.join args.profiledir, 'bookmarks.json'
bookmarks = fs.readFileSync bmkFile
exports.bookmarks = bookmarks
exports.save = ->
    fs.writeFileSync bmkFile, JSON.stringify(bookmarks, null, '\t')