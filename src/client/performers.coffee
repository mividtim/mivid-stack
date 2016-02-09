routing = require "./routing.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports =
  routing: routing.performers
  todos: todos.performers
  #rdb: rdb.performers