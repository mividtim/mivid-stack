express = require "express"
fs = require "fs"
http = require "http"
Promise = require "bluebird"
RethinkdbWebsocketServer = require "rethinkdb-websocket-server"
r = RethinkdbWebsocketServer.r
RP = RethinkdbWebsocketServer.RP

launchServer = (caCert) ->

  options =
    dbHost: process.env.DB_HOST or "localhost"
    dbPort: process.env.DB_PORT or 28015
    dbAuthKey: process.env.DB_AUTH_KEY

  rethinkOptions =
    host: options.dbHost
    port: options.dbPort
    db: process.env.DB_NAME or "test"
    authKey: options.dbAuthKey
  if caCert?
    rethinkOptions.ssl = ca: caCert
    
  rethinkConn = Promise.promisify(r.connect) rethinkOptions

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

  # Create web server
  server = http.createServer app
  options.httpServer = server
  options.httpPath = "/api"
  # Listen
  server.listen app.get("port"), ->
    console.log "Listening on port #{server.address().port}"
  # And allow upgrades to Websocket
  RethinkdbWebsocketServer.listen options

if process.env.DB_CACERT is "yes"
  # Read the CA file for Compose.io
  fs.readFile "#{__dirname}/ca.cert", (err, caCert) ->
    if err then throw err
    launchServer caCert
else
  launchServer()