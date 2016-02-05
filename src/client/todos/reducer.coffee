_ = require "lodash"
actions = require "./actions.coffee"
Redux = require "Redux"

todoReducer = (state, action) ->
  switch action.type
    when actions.ADD_TODO
      id: action.id
      text: action.text
      completed: no
    when actions.TOGGLE_TODO
      if state.id is action.id
        _.assign {}, state, completed: !state.completed
      else state
    else state

todosReducer = (state = [], action) ->
  switch action.type
    when actions.ADD_TODO then [
      state...
      todoReducer undefined, action
    ]
    when actions.TOGGLE_TODO
      state.map (todo) -> todoReducer todo, action
    else state

todosFilterReducer = (state = "SHOW_ALL", action) ->
  switch action.type
    when actions.SET_TODOS_FILTER
      action.filter
    else state

module.exports = Redux.combineReducers
  todos: todosReducer
  todosFilter: todosFilterReducer
