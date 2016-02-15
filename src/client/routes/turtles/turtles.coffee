_ = require "lodash"
#fs = require "fs"
Redux = require "Redux"
RethinkdbWebsocketClient = require "rethinkdb-websocket-client"
r = RethinkdbWebsocketClient.rethinkdb

secure = window.location.protocol is "https:"
port = window.location.port
if port.length < 1 then port = if secure then 443 else 80
rethinkOptions =
  host: window.location.hostname
  port: port
  db: "test"
  secure: secure
  path: "/api?userId=ace32b45-7826-4797-9e1a-2eb88264b737&authToken=asdf"
  wsProtocols: ["binary"]

# Redux Actions

REQUEST_TURTLES = "REQUEST_TURTLES"
RECEIVE_TURTLES = "RECEIVE_TURTLES"
ERROR_TURTLES = "ERROR_TURTLES"

actions =
  getAll: ->
    (dispatch) ->
      if err
        dispatch {type: ERROR_TURTLES, err}
      dispatch type: REQUEST_TURTLES
      try
        RethinkdbWebsocketClient.connect(rethinkOptions).then (conn) ->
          r.table("turtles").filter(herdId: 'awesomesauce').run conn, (err, cursor) ->
            if err
              dispatch {type: ERROR_TURTLES, err}
            else
              cursor.toArray (err, results) ->
                if err
                  dispatch {type: ERROR_TURTLES, err}
                else
                  dispatch type: RECEIVE_TURTLES, turtles: results
      catch err
        dispatch {type: ERROR_TURTLES, err}
  set: (turtles) ->
    type: RECEIVE_TURTLES
    turtles
    receivedAt: Date.now()

# Redux Reducers

initialState =
  isFetching: no
  didInvalidate: no
  lastError: null
  items: []
reducer = (state = initialState, action) ->
  switch action.type
    when REQUEST_TURTLES
      _.assign {}, state,
        isFetching: yes
        didInvalidate: no
    when RECEIVE_TURTLES
      _.assign {}, state,
        isFetching: no
        didInvalidate: no
        items: action.turtles
        lastUpdated: action.receivedAt
    when ERROR_TURTLES
      _.assign {}, state
        isFetching: no
        didInvalidate: no
        lastError: action.err
    else state

module.exports = {
  actions
  reducer
}