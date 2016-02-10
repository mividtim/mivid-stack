express = require "express"
http = require "http"
Promise = require "bluebird"
RethinkdbWebsocketServer = require "rethinkdb-websocket-server"

r = RethinkdbWebsocketServer.r
RP = RethinkdbWebsocketServer.RP

options =
  dbHost: "localhost"
  dbPort: 28015

rethinkConn = Promise.promisify(r.connect)(
  host: options.dbHost
  port: options.dbPort
  db: "test"
)

runQuery = (query) ->
  rethinkConn.then (conn) ->
    query.run conn

options.sessionCreator = (qs) ->
  runQuery(r.table("users").get qs.userId).then (user) ->
    if user?.authToken is qs.authToken
      curHerdId: user.herdId
    else
      Promise.reject "Invalid auth token"

options.queryWhitelist = [
  r.table "turtles"
    .filter herdId: RP.ref "herdId"
    .opt "db", r.db "test"
    .validate (refs, session) ->
      session.curHerdId is refs.herdId
  r.table "turtles"
    .insert
      herdId: RP.ref "herdId"
      name: RP.check (actual) ->
        typeof actual is "string" and actual.trim()
    .opt "db", r.db "test"
    .validate ([herdId]) ->
      if typeof herdId is "string"
        validHerdQuery = r.table("herds").get(herdId).ne null
        runQuery validHerdQuery
      else
        false
]

app = express()

# Get port from environment if available
app.set "port", process.env.PORT or 8000

# Serve the static files to the client
app.use "/", express.static "#{__dirname}/client"

# Listen
server = http.createServer app
options.httpServer = server
options.httpPath = "/api"

RethinkdbWebsocketServer.listen options
server.listen app.get("port"), ->
  console.log "Listening on port #{server.address().port}"
