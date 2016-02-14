riot = require "riot"
actions = require "./actions.coffee"

module.exports = (store) ->

  ReduxMixin =
    init: ->
      @store = store
      @actions = actions
  riot.mixin "redux", ReduxMixin

  SubscribeMixin =
    init: ->
      ReduxMixin.init.call @
      @on "mount", ->
        @unsubscribe = @store.subscribe => riot.mount @root
      @on "unmount", ->
        @unsubscribe()

  riot.mixin "subscribe", SubscribeMixin
