_ = require "lodash"
Redux = require "Redux"
RethinkdbWebsocketClient = require("rethinkdb-websocket-client");
r = RethinkdbWebsocketClient.rethinkdb;
tag = require "./turtles.tag"

# In case you want bluebird, which is bundled with the rethinkdb driver
#Promise = RethinkdbWebsocketClient.Promise;

# TBD: Get this from a global config file (package.json?)
rethinkOptions =
  host: "localhost",       # hostname of the websocket server
  port: 8000,              # port number of the websocket server
  path: "/api?userId=ace32b45-7826-4797-9e1a-2eb88264b737&authToken=asdf", # HTTP path to websocket route
  wsProtocols: ["binary"], # sub-protocols for websocket, required for websockify
  secure: false,           # set true to use secure TLS websockets
  db: "test",              # default database, passed to rethinkdb.connect
  simulatedLatencyMs: 100, # wait 100ms before sending each message (optional)

# Redux Actions

REQUEST_TURTLES = "REQUEST_TURTLES"
RECEIVE_TURTLES = "RECEIVE_TURTLES"
ERROR_TURTLES = "ERROR_TURTLES"

actions =
  getAll: ->
    (dispatch) ->
      dispatch type: REQUEST_TURTLES
      try
        RethinkdbWebsocketClient.connect(rethinkOptions).then (conn) ->
          r.table("turtles").filter(herdId: 'awesomesauce').run conn, (err, cursor) ->
            if err
              dispatch {type: ERROR_TURTLES, err}
            else
              cursor.toArray (err, results) ->
                console.log results
                if err
                  dispatch {type: ERROR_TURTLES, err}
                else
                  dispatch type: RECEIVE_TURTLES, turtles: results
      catch err
        dispatch type: RECEIVE_TURTLES, turtles: results
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
  tag
}