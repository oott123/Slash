connect = require 'connect'
serveStatic = require 'serve-static'
http = require 'http'
Promise = require 'bluebird'
exports.docPort = 0
createServer = (app, port, resolve, reject)->
    console.log "Try to create doc server on port #{port}"
    http.createServer(app)
    .once('error', (e)->
        return createServer app, port+1, resolve, reject if e.code is 'EADDRINUSE'
        reject e
    ).once('listening', ->
        exports.docPort = port
        resolve(port)
    ).listen(port, 'localhost')
exports.run = (port, root)->
    new Promise (resolve, reject)->
        return resolve exports.docPort if exports.docPort
        app = connect()
        app.use serveStatic(root)
        app.use (req, res)->
            res.end()
        createServer app, port, resolve, reject

