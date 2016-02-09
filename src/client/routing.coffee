riot = require "riot"
tags = require "./tags.coffee"

actions =
  ROUTE: "ROUTE"

performers =
  route: (route) ->
    type: actions.ROUTE
    route: route

reducer = (state = "", action) ->
  if action.type is actions.ROUTE
    action.route
  else state

startRouter = (store, actions) ->
  riot.route (route) ->
    store.dispatch performers.route route
  riot.route.start(true)
  currentTag = null
  store.subscribe ->
    state = store.getState()
    route = state.route
    route = "home" if route is ""
    tag = tags[route]
    if tag?
      currentTag = riot.mount "section.main", tag,
        store: store,
        actions: actions
      if currentTag?
        if currentTag.length > 0
          currentTag = currentTag[0]
        else
          currentTag = null
    else currentTag?.unmount(true)

module.exports =
  actions: actions
  performers: performers
  reducer: reducer
  startRouter: startRouter