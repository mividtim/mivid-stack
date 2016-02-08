_ = require "lodash"
layout = require "./layout/layout.coffee"
layoutActions = require "./layout/layoutActions.coffee"
todos = require "./todos/todos.coffee"
todosActions = require "./todos/todosActions.coffee"
Redux = require "Redux"
riot = require "riot"
homeTag = require "./home/home.tag"
layoutTag = require "./layout/layout.tag"
todosTag = require "./todos/todos.tag"

actions = _.assign {}, layoutActions, todosActions

ContextMixin =
  init: ->
    if not @store?
      ob = @
      ob = ob.parent while ob.parent?
      @store = ob.opts.store
      @actions = actions

SubscribeMixin =
  init: ->
    ContextMixin.init.call @
    @on "mount", ->
      @unsubscribe = @store.subscribe => riot.mount @root, store: @store
    @on "unmount", ->
      @unsubscribe()

route = (state = "", action) ->
  if action.type is layoutActions.ROUTE
    action.route
  else state

rootReducer = Redux.combineReducers
  route: route
  layout: layout
  todos: todos

riot.mixin "context", ContextMixin
riot.mixin "subscribe", SubscribeMixin
devTools = if window?.devToolsExtension? then window.devToolsExtension() else undefined
store = Redux.createStore rootReducer, undefined, devTools
riot.mount layoutTag, store: store
riot.route (r) ->
  store.dispatch layoutActions.route r
riot.route.start(true)
currentTag = null
store.subscribe ->
  state = store.getState()
  tag = switch state.route
    when "" then homeTag
    when "todos" then todosTag
  if tag?
    currentTag = riot.mount "section.main", tag,
      store: store,
      actions: actions
    if currentTag?
      if currentTag.length > 0
        currentTag = currentTag[0]
      else
        currentTag = null
  else currentTag?.unmount()
