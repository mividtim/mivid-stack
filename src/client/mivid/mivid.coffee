store = require "./store.coffee"
routing = require "./routing.coffee"
mixins = require "./mixins.coffee"
require "./tags.coffee"
mixins store
routing.startRouter store