remote = require 'remote'
cfg = remote.require './config'
config = cfg.config
window.Vue = Vue or require './bower_components/vue/dist/vue.js'
window.vm = new Vue
    el: 'body'
    data:
        configItems: [
            {type: 'separator', title: 'Application Settings'}
            {type: 'int', key: 'maxItem', title: 'Max search result will display', value: 100}
            {type: 'int', key: 'searchDelay', title: 'Search delay when entering keyword', value: 300}
            {type: 'separator', title: 'Shortcut Settings (will affect after restart Slash)'}
            {type: 'text', key: 'shortCut', title: 'Global shortcut', value: 'Ctrl+A'}
        ]
        configNotChanged: true
    methods:
        setValue: (data) ->
            i = 0
            while i < @$data.configItems.length
                datum = @$data.configItems[i]
                if datum.key
                    if data[datum.key]
                        datum.value = data[datum.key]
                i++
            vm.$watch 'configItems', ->
                @$data.configNotChanged = false
        closeWindow: ->
            top.closeConfig()
        saveConfig: ->
            data = {}
            i = 0
            while i < @$data.configItems.length
                datum = @$data.configItems[i]
                if datum.type is 'int'
                    data[datum.key] = parseInt(datum.value)
                else if datum.type is 'number'
                    data[datum.key] = parseNum(datum.value)
                else
                    data[datum.key] = datum.value
                i++
            cfg.config = data
            cfg.save()
            @$data.configNotChanged = true
        saveAndClose: ->
            @saveConfig()
            @closeWindow()
Vue.nextTick ->
    vm.setValue config
window.onbeforeunload = ->
    if !vm.$data.configNotChanged
        confirm "Close without saving changes?"