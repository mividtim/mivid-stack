_ = require "lodash"
routes = require "./routes/**/*.coffee", mode: "list"
module.exports = _.reduce routes,
  ((actions, route) -> actions[route.module.tag] = route.module.actions; actions),
  {}