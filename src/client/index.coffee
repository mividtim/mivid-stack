Redux = require "Redux"
thunk = require "redux-thunk"
riot = require "riot"
reducer = require "./reducer.coffee"
routing = require "./routing.coffee"
require "./mixins.coffee"
require "./tags.coffee"

devTools = window?.devToolsExtension?()
middlewares = Redux.compose Redux.applyMiddleware(thunk), devTools
store = Redux.createStore reducer, undefined, middlewares

riot.mount "layout", store: store

routing.startRouter store