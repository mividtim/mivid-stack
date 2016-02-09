browserify = require "browserify"
buffer = require "vinyl-buffer"
coffee = require "gulp-coffee"
coffeeify = require "coffeeify"
del = require "del"
gulp = require "gulp"
inject = require "gulp-inject-string"
jade = require "gulp-jade"
livereload = require "gulp-livereload"
nodemon = require "nodemon"
notify = require "gulp-notify"
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
  herokuGit: "https://git.heroku.com/mivid-stack.git"
  herokuEntry: "http://mivid-stack.herokuapp.com"

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
    if code isnt 0
      process.stdout.write "#{command} exited with code #{code}\n"

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
    .pipe livereload()

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
      bundle()
      util.log "Rebundle..."
  bundle = ->
    bundler.bundle()
      .on "error", util.log.bind util, "Browserify Error"
      .pipe source "bundle.js"
      .pipe buffer()
      .pipe sourcemaps.init loadMaps: yes
      .pipe sourcemaps.write "./"
      .pipe gulp.dest paths.clientDestination
      .pipe livereload()
  bundle()

buildClientStyles = ->
  gulp.src paths.clientStyles
    .pipe sourcemaps.init loadMaps: yes
    .pipe stylus()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.clientDestination
    .pipe livereload()

buildClientTemplates = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade pretty: yes
    .pipe inject.append "<script>document.write('<script src=\"http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1\"></' + 'script>')</script>"
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.clientDestination
    .pipe livereload()

buildClientTemplatesProd = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.clientDestination
    .pipe livereload()

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
  -> run "git", ["init"], paths.destination
  -> run "git", ["add", "."], paths.destination
  -> run "git", ["commit", "-m", "deploy"], paths.destination
  -> run "git", ["remote", "add", "heroku", urls.herokuGit], paths.destination
  -> run "git", ["push", "-u", "heroku", "master", "--force"], paths.destination
  -> run "open", [urls.herokuEntry]

watchClientScripts = -> buildClientScripts null, yes

watchOthers = ->
  gulp.watch paths.serviceScripts, gulp.series buildServiceScripts
  gulp.watch paths.clientStyles, gulp.series buildClientStyles
  gulp.watch paths.clientTemplates, gulp.series buildClientTemplates
  gulp.watch paths.clientStatic, gulp.series copyClientStatic

watch = gulp.parallel watchClientScripts, watchOthers

startDB = -> #run "mongodb", ["--dbpath", "./data"]

startApp = ->
  run "node", ["app.js"], paths.serviceDestination

monitorApp = ->
  nodemon script: paths.serviceEntry
    .on "restart", ->
      gulp.src "build/app.js"
        .pipe notify "Reloading page..."
        .pipe livereload()

start = gulp.parallel startDB, monitorApp

startProd = gulp.parallel startDB, startApp

liveReload = -> livereload.listen()

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

