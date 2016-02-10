routing = require "./routing.coffee"
home = require "./home/home.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports =
  routing: routing.actions
  home: home.actions
  todos: todos.actions
  #rdb: rdb.actions