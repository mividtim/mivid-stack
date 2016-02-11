riot = require "riot"

ROUTE = "ROUTE"

actions =
  route: (route) ->
    type: ROUTE
    route: route

reducer = (state = "", action) ->
  if action.type is ROUTE
    action.route
  else state

startRouter = (store) ->
  riot.route (route) ->
    store.dispatch actions.route route
  riot.route.start(true)
  currentTag = null
  store.subscribe ->
    state = store.getState()
    route = state.route
    route = "home" if route is ""
    currentTag = riot.mount "section.main", route, store: store
    if currentTag?
      if currentTag.length > 0
        currentTag = currentTag[0]
      else
        currentTag = null
    else currentTag?.unmount(true)

module.exports =
  actions: actions
  reducer: reducer
  startRouter: startRouter
