connect = require 'connect'
http = require 'http'
Promise = require 'bluebird'
url = require 'url'

args = require '../args'

exports.apiPort = 0
createServer = (app, port, resolve, reject)->
    console.log "Try to create api server on port #{port}"
    http.createServer(app)
    .once('error', (e)->
        return createServer app, port+1, resolve, reject if e.code is 'EADDRINUSE'
        reject e
    ).once('listening', ->
        exports.apiPort = port
        resolve(port)
    ).listen(port, 'localhost')
exports.run = (port)->
    new Promise (resolve, reject)->
        return resolve exports.apiPort if exports.apiPort
        app = connect()
        app.use (req, res, next)->
            req.urlParams = url.parse req.url, true, true
            res.json = (body, code = 200) ->
                res.writeHead code, {'Content-Type': 'application/json'}
                res.write JSON.stringify(body)
                res.end()
            res.reject = (reason, code = 400) ->
                res.json({error: reason}, code)
            next()
        app.use '/window-search', (req, res)->
            return res.reject 'Missing argument: keyword' unless req.urlParams.query.keyword
            args.mainWindow.webContents.executeJavaScript(
                "S.vm.$data.keyword = #{JSON.stringify(req.urlParams.query.keyword)}")
            if req.urlParams.query.docset
                args.mainWindow.webContents.executeJavaScript(
                    "S.vm.$data.docset = #{JSON.stringify(req.urlParams.query.docset)}")
            args.mainWindow.show()
            args.mainWindow.focus()
            return res.json(true)
        app.use (req, res)->
            res.reject 'Method Not Found'
            res.end()
        createServer app, port, resolve, reject