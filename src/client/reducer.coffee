_ = require "lodash"
Redux = require "redux"
routing = require "./routing.coffee"
routes = require "./routes/**/*.coffee", mode: "list"
reducers = _.reduce routes,
  ((reducers, route) -> reducers[route.module.tag] = route.module.reducer; reducers),
  {}
Object.assign reducers, route: routing.reducer
module.exports = Redux.combineReducers reducers