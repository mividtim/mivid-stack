riot = require "riot"
actions = require "./actions.coffee"
performers = require "./performers.coffee"

ContextMixin =
  init: ->
    if not @store?
      ob = @
      ob = ob.parent while ob.parent?
      @store = ob.opts.store
      @actions = actions
      @performers = performers

SubscribeMixin =
  init: ->
    ContextMixin.init.call @
    @on "mount", ->
      @unsubscribe = @store.subscribe => riot.mount @root, store: @store
    @on "unmount", ->
      @unsubscribe()

riot.mixin "context", ContextMixin
riot.mixin "subscribe", SubscribeMixin