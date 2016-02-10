Redux = require "Redux"
RethinkdbWebsocketClient = require("rethinkdb-websocket-client");
r = RethinkdbWebsocketClient.rethinkdb;
tag = require "./rdb.tag"

# In case you want bluebird, which is bundled with the rethinkdb driver
#Promise = RethinkdbWebsocketClient.Promise;

rethinkOptions =
  host: "localhost",       # hostname of the websocket server
  port: 8000,              # port number of the websocket server
  path: "/api?userId=ace32b45-7826-4797-9e1a-2eb88264b737&authToken=asdf",               # HTTP path to websocket route
  wsProtocols: ["binary"], # sub-protocols for websocket, required for websockify
  secure: false,           # set true to use secure TLS websockets
  db: "test",              # default database, passed to rethinkdb.connect
  simulatedLatencyMs: 100, # wait 100ms before sending each message (optional)

getAll = ->
  RethinkdbWebsocketClient.connect(rethinkOptions).then (conn) ->
    r.table("turtles").filter(herdId: 'awesomesauce').run conn, (err, cursor) ->
      console.log err, cursor
      cursor.toArray (err, results) ->
        store.dispatch

actions =
  GET_ALL_TURTLES: "GET_ALL_TURTLES"
  SET_TURTLES: "SET_TURTLES"

performers =
  getAll: ->
    type: actions.GET_ALL_TURTLES
  set: (turtles) ->
    type: actions.SET_TURTLES
    turtles: turtles

# Redux Reducers

turtles = (state = [], action) ->
  switch action.type
    when actions.GET_ALL_TURTLES
      getAll()
      state
    when actions.SET_TURTLES
      action.turtles
    else state

reducer = Redux.combineReducers
  turtles: turtles

module.exports =
  actions: actions
  performers: performers
  reducer: reducer
  tag: tag