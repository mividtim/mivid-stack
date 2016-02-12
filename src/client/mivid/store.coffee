Redux = require "Redux"
thunk = require "redux-thunk"
reducer = require "./reducer.coffee"

devTools = window?.devToolsExtension?() or (f) -> f
middlewares = Redux.compose Redux.applyMiddleware(thunk), devTools
module.exports = Redux.createStore reducer, undefined, middlewares