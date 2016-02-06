express = require "express"

app = express()

# Get port from environment if available
app.set "port", process.env.PORT or 8000

# Serve the static files to the client
app.use "/", express.static "#{__dirname}/../client"

# Listen
server = app.listen app.get("port"), ->
  console.log "Listening on port #{server.address().port}"
