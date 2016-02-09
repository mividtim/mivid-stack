Redux = require "redux"
routing = require "./routing.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports = Redux.combineReducers
  route: routing.reducer
  todos: todos.reducer
  #rdb: rdb.reducer