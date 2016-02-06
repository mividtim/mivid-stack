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

paths =
  destination: "./build"
  clientDestination: "./build/client"
  clientScripts: "./src/client/index.coffee"
  clientStyles: "./src/**/*.styl"
  clientTemplates: "./src/**/*.jade"
  clientStatic: "./static/**/*"
  serviceDestination: "./build/service"
  serviceScripts: "./src/service/**/*.coffee"
  serviceEntry: "./build/service/app.js"

browserifyOpts =
  entries: paths.clientScripts,
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

copyClientStatic = ->
  gulp.src paths.clientStatic
    .pipe gulp.dest paths.destination

buildClientScripts = (watch = no) ->
  opts = browserifyOpts
  if watch then opts = Object.assign {}, watchify.args, browserifyOpts
  bundler = browserify opts
  bundler.transform coffeeify
  bundler.transform riotify,
    template: "jade",
    type: "coffeescript",
    style: "stylus"
  if watch then bundler = watchify bundler
  rebundle = ->
    bundler.bundle()
      .on "error", util.log.bind util, "Browserify Error"
      .pipe source "bundle.js"
      .pipe buffer()
      .pipe sourcemaps.init loadMaps: yes
      .pipe sourcemaps.write "./"
      .pipe gulp.dest paths.clientDestination
  bundler.on "log", util.log
  if watch
    bundler.on "update", ->
      rebundle()
      util.log "Rebundle..."
  rebundle()

buildClientStyles = ->
  gulp.src paths.clientStyles
    .pipe sourcemaps.init loadMaps: yes
    .pipe stylus()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.destination

buildClientTemplates = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade pretty: yes
    .pipe inject.append "<script>document.write('<script src=\"http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1\"></' + 'script>')</script>"
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.destination

buildClientTemplatesProd = ->
  gulp.src paths.clientTemplates
    .pipe sourcemaps.init loadMaps: yes
    .pipe jade pretty: yes
    .pipe sourcemaps.write "."

build = gulp.parallel(
  buildServiceScripts,
  copyClientStatic,
  buildClientScripts,
  buildClientStyles,
  buildClientTemplates)

rebuild = gulp.series clean, build

prod = gulp.parallel(
  buildServiceScripts,
  copyClientStatic,
  buildClientScripts,
  buildClientStyles,
  buildClientTemplatesProd)

watchClientScripts = -> buildClientScripts yes

watchOthers = ->
  gulp.watch paths.serviceScripts, buildServiceScripts
  gulp.watch paths.clientStyles, buildClientStyles
  gulp.watch paths.clientTemplates, buildClientTemplates
  gulp.watch paths.clientStatic, copyClientStatic

watch = gulp.parallel watchClientScripts, watchOthers

startDB = -> #run "mongodb", ["--dbpath", "./data"]

startApp = -> #run "python", ["-m", "SimpleHTTPServer"], "build/client"
  run "node", ["app.js"], paths.serviceDestination

monitorApp = ->
  nodemon script: paths.serviceEntry, watch: paths.serviceDestination

start = gulp.parallel startDB, monitorApp

startProd = gulp.parallel startDB, startApp

liveReload = gulp.parallel startApp, ->
  livereload.createServer().watch paths.clientDestination

dev = gulp.series rebuild, gulp.parallel watch, liveReload, start, ->
  setTimeout (-> run "open", ["http://localhost:8000"]), 1000

gulp.task "clean", clean
gulp.task "build", build
gulp.task "rebuild", rebuild
gulp.task "prod", prod
gulp.task "watch", watch
gulp.task "start", start
gulp.task "prod", startProd
gulp.task "db", startDB
gulp.task "app", startApp
gulp.task "live", liveReload
gulp.task "default", dev
