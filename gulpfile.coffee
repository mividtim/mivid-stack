browserify = require "browserify"
buffer = require "vinyl-buffer"
coffee = require "gulp-coffee"
coffeeify = require "coffeeify"
del = require "del"
gulp = require "gulp"
inject = require "gulp-inject-string"
jade = require "gulp-jade"
livereload = require "livereload"
nodemon = require "nodemon"
process = require "process"
riotify = require "riotify"
source = require "vinyl-source-stream"
sourcemaps = require "gulp-sourcemaps"
spawn = require("child_process").spawn
stylus = require "gulp-stylus"
util = require "gulp-util"
watchify = require "watchify"

port = process.env.PORT || 8000

paths =
  destination: "./build"
  clientBase: "./src/client"
  clientStatic: "./static/**/*"
  serviceBase: "./src/service"
  herokuStatic: "./heroku/**/*"

Object.assign paths,
  clientDestination: "#{paths.destination}/client"
  clientEntry: "#{paths.clientBase}/index.coffee"
  clientStyles: "#{paths.clientBase}/**/*.styl"
  clientTemplates: "#{paths.clientBase}/**/*.jade"
  serviceDestination: paths.destination
  serviceScripts: "#{paths.serviceBase}/**/*.coffee"
  serviceEntry: "#{paths.destination}/app.js"

urls =
  appEntry: "http://localhost:#{port}"
  herokuDev: "https://git.heroku.com/mivid-stack.git"

browserifyOpts =
  entries: paths.clientEntry
  debug: yes

run = (command, args, cwd = ".") ->
  runningCommand = spawn command, args, cwd: cwd
  runningCommand.stdout.on "data", (data) ->
    process.stdout.write "#{command}: #{data}"
  runningCommand.stderr.on "data", (data) ->
    process.stderr.write "#{command}: #{data}"
  runningCommand.on "exit", (code) ->
    process.stdout.write "#{command} exited with code #{code}"

clean = -> del "build"

buildServiceScripts = ->
  gulp.src paths.serviceScripts
    .pipe sourcemaps.init loadMaps: yes
    .pipe coffee(bare: yes).on "error", util.log
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.serviceDestination

buildService = -> buildServiceScripts()

copyClientStatic = ->
  gulp.src paths.clientStatic
    .pipe gulp.dest paths.clientDestination

buildClientScripts = (cb, watch = no) ->
  opts = browserifyOpts
  if watch then opts = Object.assign {}, watchify.args, opts
  bundler = browserify opts
  if watch
    bundler = watchify bundler
    bundler.on "log", util.log
  bundler.transform coffeeify
  bundler.transform riotify,
    template: "jade"
    type: "coffeescript"
    style: "stylus"
  if watch
    bundler.on "update", ->
      bundle.bind null, bundler
      util.log "Rebundle..."
  bundle = ->
    bundler.bundle()
      .on "error", util.log.bind util, "Browserify Error"
      .pipe source "bundle.js"
      .pipe buffer()
      .pipe sourcemaps.init loadMaps: yes
      .pipe sourcemaps.write "./"
      .pipe gulp.dest paths.clientDestination
  bundle(bundler)

buildClientStyles = ->
  gulp.src paths.clientStyles
    .pipe sourcemaps.init loadMaps: yes
    .pipe stylus()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.clientDestination

buildClientTemplates = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade pretty: yes
    .pipe inject.append "<script>document.write('<script src=\"http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1\"></' + 'script>')</script>"
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.clientDestination

buildClientTemplatesProd = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade()
    .pipe sourcemaps.write "."

buildClient = gulp.parallel(
  copyClientStatic
  buildClientScripts
  buildClientStyles
  buildClientTemplates
)

build = gulp.parallel buildService, buildClient

rebuild = gulp.series clean, build

prod = gulp.parallel(
  buildServiceScripts
  copyClientStatic
  buildClientScripts
  buildClientStyles
  buildClientTemplatesProd
)

copyHeroku = ->
  gulp.src paths.herokuStatic
    .pipe gulp.dest paths.destination

heroku = gulp.series clean, prod, copyHeroku,
  -> run "cd", ["build"]
  -> run "git", ["init"]
  -> run "git", ["add", "."]
  -> run "git", ["commit", "-m", "deploy"]
  -> run "git", ["remote", "add", "heroku", urls.herokuDev]
  -> run "git", ["push", "-u", "heroku", "master", "--force"]

watchClientScripts = -> buildClientScripts yes

watchOthers = ->
  gulp.watch paths.serviceScripts, buildServiceScripts
  gulp.watch paths.clientStyles, buildClientStyles
  gulp.watch paths.clientTemplates, buildClientTemplates
  gulp.watch paths.clientStatic, copyClientStatic

watch = gulp.parallel watchClientScripts, watchOthers

startDB = -> #run "mongodb", ["--dbpath", "./data"]

startApp = ->
  run "node", ["app.js"], paths.serviceDestination

monitorApp = ->
  nodemon script: paths.serviceEntry, watch: paths.serviceDestination

start = gulp.parallel startDB, monitorApp

startProd = gulp.parallel startDB, startApp

liveReload = -> livereload.createServer().watch paths.destination

open = ->
  setTimeout (-> run "open", [urls.appEntry]), 1000

dev = gulp.series rebuild, gulp.parallel watch, liveReload, start, open

gulp.task "clean", clean
gulp.task "service", buildService
gulp.task "client", buildClient
gulp.task "build", build
gulp.task "rebuild", rebuild
gulp.task "prod", prod
gulp.task "watch", watch
gulp.task "start", start
gulp.task "prod", startProd
gulp.task "heroku", heroku
gulp.task "db", startDB
gulp.task "app", startApp
gulp.task "monitor", monitorApp
gulp.task "live", liveReload
gulp.task "dev", dev
gulp.task "default", dev

