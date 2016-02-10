Redux = require "redux"
routing = require "./routing.coffee"
home = require "./home/home.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports = Redux.combineReducers
  route: routing.reducer
  home: home.reducer
  todos: todos.reducer
  #rdb: rdb.reducer