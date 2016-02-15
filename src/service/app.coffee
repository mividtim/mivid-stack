express = require "express"
fs = require "fs"
http = require "http"
https = require "https"
Promise = require "bluebird"
RethinkdbWebsocketServer = require "rethinkdb-websocket-server"
r = RethinkdbWebsocketServer.r
RP = RethinkdbWebsocketServer.RP

websocketOptions =
  dbHost: process.env.DB_HOST or "localhost"
  dbPort: process.env.DB_PORT or 28015
  dbAuthKey: process.env.DB_AUTH_KEY
  dbSsl:
    if process.env.DB_CACERT is "yes"
      ca: fs.readFileSync "#{__dirname}/ca.cert"
    else
      process.env.DB_SECURE is "yes"

rethinkOptions =
  host: websocketOptions.dbHost
  port: websocketOptions.dbPort
  authKey: websocketOptions.dbAuthKey
  ssl: websocketOptions.dbSsl
  db: process.env.DB_NAME or "test"

rethinkConn = Promise.promisify(r.connect) rethinkOptions

runQuery = (query) ->
  rethinkConn.then (conn) ->
    query.run conn

websocketOptions.sessionCreator = (qs) ->
  runQuery(r.table("users").get qs.userId).then (user) ->
    if user?.authToken is qs.authToken
      curHerdId: user.herdId
    else
      Promise.reject "Invalid auth token"

websocketOptions.queryWhitelist = [
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
        runQuery r.table("herds").get(herdId).ne null
      else
        false
]

app = express()

# Get port from environment if available
app.set "port", process.env.PORT or 8000

# Serve the static files to the client
app.use "/", express.static "#{__dirname}/client"

# Create web server
if process.env.EXPRESS_HTTPS
  httpsOptions =
    key: fs.readFileSync "#{__dirname}/server.key"
    cert: fs.readFileSync "#{__dirname}/server.crt"
    requestCert: no
    rejectUnauthorized: no
  server = https.createServer httpsOptions, app
else
  server = http.createServer app
websocketOptions.httpServer = server
websocketOptions.httpPath = "/api"
# Listen
server.listen app.get("port"), ->
  console.log "Listening on port #{server.address().port}"
# And allow upgrades to Websocket
RethinkdbWebsocketServer.listen websocketOptions