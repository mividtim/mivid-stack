r = require "rethinkdb"

await r.connect {host: "localhost", port: 28015}, defer err, conn
if err then throw err
await r.db("test").tableCreate("tv_shows").run conn, defer err, res
if err then throw err
console.log res
r.table("tv_shows").insert(name: "Star Trek TNG").run conn, defer err, res
if err then throw err
console.log res

