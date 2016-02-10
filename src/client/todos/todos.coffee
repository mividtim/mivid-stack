_ = require "lodash"
Redux = require "Redux"
tag = require "./todos.tag"

nextID = 0

actions =
  ADD_TODO: "ADD_TODO"
  SET_TODOS_FILTER: "SET_TODOS_FILTER"
  TOGGLE_TODO: "TOGGLE_TODO"

performers =
  addTodo: (text) ->
    type: actions.ADD_TODO
    id: nextID++
    text: text
  setTodosFilter: (filter) ->
    type: actions.SET_TODOS_FILTER
    filter: filter
  toggleTodo: (id) ->
    type: actions.TOGGLE_TODO
    id: id

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

list = (state = [], action) ->
  switch action.type
    when actions.ADD_TODO then [
      state...
      todo undefined, action
    ]
    when actions.TOGGLE_TODO
      state.map (t) -> todo t, action
    else state

filter = (state = "SHOW_ALL", action) ->
  switch action.type
    when actions.SET_TODOS_FILTER
      action.filter
    else state

reducer = Redux.combineReducers
  list: list
  filter: filter

module.exports =
  actions: actions
  performers: performers
  reducer: reducer
  tag: tag