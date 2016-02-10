routing = require "./routing.coffee"
home = require "./home/home.coffee"
todos = require "./todos/todos.coffee"
#rdb = require "./rdb/rdb.coffee"

module.exports =
  routing: routing.performers
  home: home.performers
  todos: todos.performers
  #rdb: rdb.performers