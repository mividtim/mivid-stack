# Preload some universal tags
require "./tags/disableable_link.tag"
require "./tags/layout.tag"
require "./tags/navigation.tag"

# Export routable tags
module.exports =
  home: require "./tags/home.tag"
  todos: require "./todos/todos.tag"
  rdb: require "./rdb/rdb.tag"
