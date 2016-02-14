_ = require "lodash"
routes = require "../routes/**/*.coffee", mode: "list"
module.exports = _.reduce routes,
  ((actions, route) -> actions[route.name.split('/')[0]] = route.module.actions; actions),
  {}