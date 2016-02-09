routing = require "./routing.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports =
  routing: routing.actions
  todos: todos.actions
  #rdb: rdb.actions