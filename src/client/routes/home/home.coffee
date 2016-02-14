Redux = require "Redux"

TOGGLE_DETAILS = "TOGGLE_DETAILS"

actions =
  toggleDetails: ->
    type: TOGGLE_DETAILS

details = (state = "HIDE", action) ->
  switch action.type
    when TOGGLE_DETAILS
      if state is "SHOW" then "HIDE" else "SHOW"
    else state

reducer = Redux.combineReducers {
  details
}

module.exports = {
  actions
  reducer
}