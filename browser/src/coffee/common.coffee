window.S = window.S or {}
window.ipc = require 'ipc'
window.Vue = require './bower_components/vue/dist/vue.js'
window.$ = require './bower_components/jquery/dist/jquery.js'
remote = require 'remote'
S.ds = remote.require './docset'
S.cwd = remote.process.cwd()
S.docPort = remote.require('./server/doc-server').docPort
_ = require 'lodash'

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
        lazySearch: ->
            _.debounce(this.search, 300).apply(this, arguments)
        search: (e)->
            return e.preventDefault() if [40, 38].indexOf(e.which) >= 0
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
            @.webContentSrc = "http://localhost:#{S.docPort}/" +
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
        openInBrowser: ->
            require('shell').openExternal(@webContentSrc)
            $('.bars').blur()
        refreshBrowser: (e)->
            $('#web-content')[0].reloadIgnoringCache()
            $('.bars').blur()
$('document').ready ->
    $('input#search').keydown (e)->
        next = false
        if e.which is 40
            # down
            next = $('ul#doc-list li.active').next()
        else if e.which is 38
            # up
            next = $('ul#doc-list li.active').prev()
        if next.length
            next.click()
            st = next.parent().parent().scrollTop()
            next.parent().parent().scrollTop(st + next.offset().top - 300)
            e.stopPropagation()
            e.preventDefault()
            return false