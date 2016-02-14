_ = require "lodash"
Redux = require "Redux"

ADD_TODO = "ADD_TODO"
TOGGLE_TODO = "TOGGLE_TODO"
SET_TODOS_FILTER = "SET_TODOS_FILTER"

nextID = 0
actions =
  add: (text) ->
    type: ADD_TODO
    id: nextID++
    text: text
  toggle: (id) ->
    type: TOGGLE_TODO
    id: id
  setFilter: (filter) ->
    type: SET_TODOS_FILTER
    filter: filter

todo = (state, action) ->
  switch action.type
    when ADD_TODO
      id: action.id
      text: action.text
      completed: no
    when TOGGLE_TODO
      if state.id is action.id
        _.assign {}, state, completed: !state.completed
      else state
    else state

list = (state = [], action) ->
  switch action.type
    when ADD_TODO then [
      state...
      todo undefined, action
    ]
    when TOGGLE_TODO
      state.map (t) -> todo t, action
    else state

filter = (state = "SHOW_ALL", action) ->
  switch action.type
    when SET_TODOS_FILTER
      action.filter
    else state

reducer = Redux.combineReducers {
  list
  filter
}

module.exports = {
  actions
  reducer
}