window.S = window.S or {}
window.ipc = require 'ipc'
window.Vue = require './bower_components/vue/dist/vue.js'
window.$ = require './bower_components/jquery/dist/jquery.js'
remote = require 'remote'
S.ds = remote.require './js/docset'

lastDs = undefined

S.vm = new Vue
    el: 'body'
    data:
        results: [
            {name: 'Hello Slash!'}
        ]
    methods:
        search: (e)->
            if lastDs
                lastDs.abort()
            keyword = $(e.target).val()
            return if keyword.length < 2
            lastDs = new S.ds keyword
            vm = this
            vm.$data.results = []
            loadedItems = {}
            lastDs.on 'result', (result)->
                lt = loadedItems[result.docset] = loadedItems[result.docset] or {}
                for i in result.result
                    if vm.$data.results.length > 100
                        lastDs.abort()
                        return
                    continue if lt[i.id]
                    lt[i.id] = true
                    vm.$data.results.push i
            lastDs.match()