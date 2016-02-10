Redux = require "Redux"
tag = require "./home.tag"

actions =
  TOGGLE_DETAILS: "TOGGLE_DETAILS"

performers =
  toggleDetails: ->
    type: actions.TOGGLE_DETAILS

details = (state = "HIDE", action) ->
  switch action.type
    when actions.TOGGLE_DETAILS
      if state is "SHOW" then "HIDE" else "SHOW"
    else state

reducer = Redux.combineReducers
  details: details

module.exports =
  actions: actions
  performers: performers
  reducer: reducer
  tag: tag