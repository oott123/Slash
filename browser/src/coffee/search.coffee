remote = require 'remote'
_ = require 'lodash'

docSetDir = remote.require('./args').docsetdir.replace(/\\/g, '/')

# register global shortcut
if S.cfg.shortCut
    ret = remote.require('global-shortcut').register S.cfg.shortCut, ->
        ipc.send 'showMainWindow'
        $('input#search').focus()
    window.onbeforeunload = ->
        remote.require('global-shortcut').unregister S.cfg.shortCut
    unless ret
        alert "Failed to register global shortcut #{S.cfg.shortCut}.\nCheck if it was already in use."

window.closeConfig = ->
    S.vm.$data.isConfigShow = false

Vue.component 'bookmark',
    template: '#bookmark-template'
    data: ->
        title: 'Dummy Bookmark'
        url: 'https://github.com/oott123/Slash'
        subItems: []
        status:
            isEditing: false
            isOpen: false
    computed:
        isFolder: ->
            @subItems?.length
        isTop: ->
            @$parent.bookmarks
    methods:
        toggle: ->
            return if @isTop
            if @isFolder
                @status.isOpen = !@status.isOpen
            else
                url = @url.replace 'slash://', "http://localhost:#{S.docPort}/"
                S.vm.webContentSrc = url
                $('.button.bookmark').blur()
        edit: ->
            @status.isEditing = !@status.isEditing
        remove: ->
            if @$parent.subItems?[@$index]
                @$parent.subItems.splice @$index, 1
            else if @$parent.bookmarks?[@$index]
                @$parent.bookmarks.splice @$index, 1
        add: ->
            title = S.vm.title
            url = S.vm.webContentSrc.replace "http://localhost:#{S.docPort}/", 'slash://'
            data =
                title: title
                url: url
                status:
                    isEditing: true
            @subItems = [] unless @subItems
            @subItems.push data
            @status.isOpen = true
S.vm = new Vue
    el: 'html'
    data:
        results: [
            {name: 'Hello Slash!'}
        ]
        webContentSrc: ''
        title: 'Welcome'
        docset: ''
        keyword: ''
        buttons:
            forward: false
            backward: false
            bookmark: true
            options: true
        isConfigShow: false
        bookmarks: S.bookmarks
        configUrl: 'about:blank'
        args: remote.require('./args')
    methods:
        lazySearch: ->
            # check if ":"
            if matches = @keyword.match /^(.*):(.*)$/
                $('#search').val(matches[2]) # changing @keyword won't works
                @docset = matches[1]
            # check if ";"
            if @keyword.match /;/
                $('#search').val('')
            _.debounce(this.search, S.cfg.searchDelay).apply(this, arguments)
        search: ->
            keyword = @keyword
            if keyword.match /^https?:\/\//
                @webContentSrc = keyword
                return
            handle = new S.ds keyword, @docset
            loadedItems = {}
            processResult =  (result)->
                lt = loadedItems[result.docset.name] = loadedItems[result.docset.name] or {}
                for i in result.result
                    return unless result.keyword is S.vm.$data.keyword
                    return if S.vm.$data.results.length > S.cfg.maxItem
                    continue if lt[i.id]
                    lt[i.id] = true
                    i.docset =
                        name: result.docset.name
                    S.vm.$data.results.push i
            handle.on 'finish', (allData)->
                return if allData.length < 1
                return unless allData[0].keyword is S.vm.$data.keyword
                S.vm.$data.results = []
                for res in allData
                    processResult res
                Vue.nextTick ->
                    $('ul#doc-list li:first').click()
            handle.match()
        loadWeb: (e)->
            item = e.targetVM.result
            @webContentSrc = "http://localhost:#{S.docPort}/" +
                encodeURIComponent(item.docset.name) +
                "/Contents/Resources/Documents/#{item.path}"
            $('ul#doc-list li').removeClass 'active'
            $(e.target).addClass 'active'
        contentStartLoading: (e)->
            @title = 'Loading ...'
        contentStopLoading: (e)->
            # update title buttons
            @buttons.backward = e.target.canGoBack()
            @buttons.forward = e.target.canGoForward()
        contentPageTitleSet: (e)->
            @title = e.title
        webNav: (i)->
            $('#web-content')[0].goToOffset(i)
        message: (e)->
            console.log e.message
        openInBrowser: ->
            require('shell').openExternal(@webContentSrc)
            $('.bars').blur()
        refreshBrowser: (e)->
            $('#web-content')[0].reloadIgnoringCache()
        openConfigWindow: ->
            @configUrl = 'config.html'
            @isConfigShow = true
        showDocsetStat: ->
            handle = new S.ds()
            handle.stat().then (data)->
                str = "==== Docsets Index Item Count ====\n\n"
                for i in data
                    str += "#{i.docset}: #{i.data}\n"
                alert(str)
        getBg: (name)->
            "url('#{docSetDir}/" +
                encodeURIComponent(name) +
                "/icon.png')"
        reloadSlash: ->
            location.reload()
        toggleDevTools: ->
            @args.mainWindow.toggleDevTools()
S.vm.$watch 'docset + keyword', S.vm.lazySearch
$('document').ready ->
    lastBackspace = 0
    $('input#search').keydown (e)->
        next = false
        if e.which is 40
            # down
            next = $('ul#doc-list li.active').next()
        else if e.which is 38
            # up
            next = $('ul#doc-list li.active').prev()
        else if e.which is 8
            # backspace
            if $('#search').val() is '' and Date.now() - lastBackspace > 500
                S.vm.$data.docset = ''
                $('#docset').val('')
            lastBackspace = Date.now()
        if next.length
            next.click()
            st = next.parent().parent().scrollTop()
            next.parent().parent().scrollTop(st + next.offset().top - 300)
            e.stopPropagation()
            e.preventDefault()
            return false
    $('.menu.dropdown').click (e)->
        $(this).parent().blur()
    $('.bookmark.button').focus ->
        $('.bookmarks').show()
    .blur ->
        return if isEditing(S.vm.bookmarks)
        $('.bookmarks').hide()
        # save bookmarks
        bmk = require('remote').require('./bookmark')
        bmk.save(JSON.parse(JSON.stringify(S.vm.bookmarks)))
isEditing = (items)->
    for i in items
        return true if i.status?.isEditing
        if i.subItems
            return true if isEditing i.subItems
    return false