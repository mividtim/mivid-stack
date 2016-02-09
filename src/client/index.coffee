Redux = require "Redux"
riot = require "riot"
actions = require "./actions.coffee"
reducer = require "./reducer.coffee"
routing = require "./routing.coffee"
layoutTag = require "./tags/layout.tag"
require "./mixins.coffee"
require "./tags.coffee"

devTools = window?.devToolsExtension?()

store = Redux.createStore reducer, undefined, devTools
riot.mount layoutTag, store: store
routing.startRouter store, actions