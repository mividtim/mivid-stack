nextID = 0
module.exports =
  ADD_TODO: "ADD_TODO"
  SET_TODOS_FILTER: "SET_TODOS_FILTER"
  TOGGLE_TODO: "TOGGLE_TODO"
  addTodo: (text) ->
    type: "ADD_TODO"
    id: nextID++
    text: text
  setTodosFilter: (filter) ->
    type: "SET_TODOS_FILTER"
    filter: filter
  toggleTodo: (id) ->
    type: "TOGGLE_TODO"
    id: id
