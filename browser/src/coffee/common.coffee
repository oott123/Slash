window.S = window.S or {}
window.ipc = require 'ipc'
window.Vue = require './bower_components/vue/dist/vue.js'
window.$ = require './bower_components/jquery/dist/jquery.js'
remote = require 'remote'
S.ds = remote.require './js/docset'
S.cwd = remote.process.cwd()

lastDs = undefined

S.vm = new Vue
    el: 'html'
    data:
        results: [
            {name: 'Hello Slash!'}
        ]
        webContentSrc: ''
        title: 'Welcome'
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
                lt = loadedItems[result.docset.name] = loadedItems[result.docset.name] or {}
                for i in result.result
                    if vm.$data.results.length > 100
                        lastDs.abort()
                        return
                    continue if lt[i.id]
                    lt[i.id] = true
                    i.docset = result.docset
                    vm.$data.results.push i
            lastDs.match()
        loadWeb: (e)->
            item = e.targetVM.result
            @$data.webContentSrc = "../Docsets/" +
                encodeURIComponent(item.docset.name) +
                "/Contents/Resources/Documents/#{item.path}"
            $('ul#doc-list li').removeClass 'active'
            $(e.target).addClass 'active'
        updateTitle: (e)->
            @$data.title = e.target.getTitle()