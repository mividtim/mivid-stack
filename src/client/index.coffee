actions = require "./todos/actions.coffee"
reducer = require "./todos/reducer.coffee"
Redux = require "Redux"
riot = require "riot"
tag = require "./todos/tag.tag"

ContextMixin =
  init: ->
    if not @store?
      console.log "here"
      ob = @
      ob = ob.parent while ob.parent?
      console.log ob
      @store = ob.opts.store
      @actions = actions

SubscribeMixin =
  init: ->
    console.log "here"
    ContextMixin.init.call @
    @on "mount", ->
      @unsubscribe = @store.subscribe => riot.mount @root, store: @store
    @on "unmount", ->
      @unsubscribe()

riot.mixin "context", ContextMixin
riot.mixin "subscribe", SubscribeMixin
riot.mount tag, store: Redux.createStore reducer
