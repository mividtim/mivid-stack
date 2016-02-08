_ = require "lodash"
actions = require "./todosActions.coffee"
Redux = require "Redux"

todo = (state, action) ->
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

todosList = (state = [], action) ->
  switch action.type
    when actions.ADD_TODO then [
      state...
      todo undefined, action
    ]
    when actions.TOGGLE_TODO
      state.map (t) -> todo t, action
    else state

todosFilter = (state = "SHOW_ALL", action) ->
  switch action.type
    when actions.SET_TODOS_FILTER
      action.filter
    else state

module.exports = Redux.combineReducers
  todosList: todosList
  todosFilter: todosFilter
