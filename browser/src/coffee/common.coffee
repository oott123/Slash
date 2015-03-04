window.S = window.S or {}
window.ipc = require 'ipc'
window.Vue = require './bower_components/vue/dist/vue.js'
window.$ = require './bower_components/jquery/dist/jquery.js'
remote = require 'remote'
S.ds = remote.require './docset'
S.cwd = remote.process.cwd()

S.vm = new Vue
    el: 'html'
    data:
        results: [
            {name: 'Hello Slash!'}
        ]
        webContentSrc: ''
        title: 'Welcome'
        keyword: ''
        buttons:
            forward: false
            backward: false
            bookmark: true
            options: true
    methods:
        search: ->
            keyword = @keyword
            return if keyword.length < 2
            handle = new S.ds keyword
            loadedItems = {}
            processResult =  (result)->
                lt = loadedItems[result.docset.name] = loadedItems[result.docset.name] or {}
                for i in result.result
                    return unless result.keyword is S.vm.$data.keyword
                    return if S.vm.$data.results.length > 100
                    continue if lt[i.id]
                    lt[i.id] = true
                    i.docset =
                        name: result.docset.name
                    S.vm.$data.results.push i
            handle.on 'finish', (allData)->
                return unless allData[0].keyword is S.vm.$data.keyword
                S.vm.$data.results = []
                for res in allData
                    processResult res
                Vue.nextTick ->
                    $('ul#doc-list li:first').click()
            handle.match()
        loadWeb: (e)->
            item = e.targetVM.result
            @$data.webContentSrc = "../Docsets/" +
                encodeURIComponent(item.docset.name) +
                "/Contents/Resources/Documents/#{item.path}"
            $('ul#doc-list li').removeClass 'active'
            $(e.target).addClass 'active'
        updateTitle: (e)->
            @title = e.target.getTitle()
            @buttons.backward = e.target.canGoBack()
            @buttons.forward = e.target.canGoForward()
        webNav: (i)->
            $('#web-content')[0].goToOffset(i)
        message: (e)->
            console.log e.message