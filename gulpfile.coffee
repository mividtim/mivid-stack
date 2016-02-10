browserify = require "browserify"
buffer = require "vinyl-buffer"
iced = require "gulp-iced"
del = require "del"
gulp = require "gulp"
icsify = require "icsify"
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
  clientStatic: "./src/static/**/*"
  serviceBase: "./src/service"
  herokuStatic: ["./package.json", "./src/heroku/**/*"]
  herokuDestination: "./heroku"

Object.assign paths,
  allDestination: "#{paths.destination}/**/*"
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

browserifyOpts =
  entries: paths.clientEntry
  debug: yes

exec = (command, args, cwd = ".") ->
  runningCommand = spawn command, args, cwd: cwd
  runningCommand.stdout.on "data", (data) ->
    process.stdout.write "#{command}: #{data}"
  runningCommand.stderr.on "data", (data) ->
    process.stderr.write "#{command}: #{data}"
  runningCommand.on "exit", (code) ->
    if code isnt 0
      process.stdout.write "#{command} exited with code #{code}\n"

clean = gulp.series(
	  -> del "build"
	  -> del "heroku"
	)

buildServiceScripts = ->
  gulp.src paths.serviceScripts
    .pipe sourcemaps.init loadMaps: yes
    .pipe iced(bare: yes).on "error", util.log
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
  bundler.transform icsify
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

watchClientScripts = -> buildClientScripts null, yes

watchOthers = ->
  gulp.watch paths.serviceScripts, buildServiceScripts
  gulp.watch paths.clientStyles, buildClientStyles
  gulp.watch paths.clientTemplates, buildClientTemplates
  gulp.watch paths.clientStatic, copyClientStatic

watch = gulp.parallel watchClientScripts, watchOthers

monitor = ->
  nodemon script: paths.serviceEntry, ignore: "client/*"
    .on "restart", ->
      gulp.src paths.serviceEntry
        .pipe notify "Reloading page..."
        .pipe livereload()

liveReload = -> livereload.listen()

open = -> exec "open", [urls.appEntry]

dev = gulp.parallel watch, liveReload, monitor, -> setTimeout open, 1000

redev = gulp.series rebuild, dev

prod = gulp.parallel(
  buildServiceScripts
  copyClientStatic
  buildClientScripts
  buildClientStyles
  buildClientTemplatesProd
)

app = -> exec "node", ["app.js"], paths.serviceDestination

copyHerokuStatic = ->
  gulp.src paths.herokuStatic
    .pipe gulp.dest paths.herokuDestination

copyHerokuApp = ->
  gulp.src paths.allDestination
    .pipe gulp.dest paths.herokuDestination

copyHeroku = gulp.series copyHerokuStatic, copyHerokuApp

heroku = gulp.series clean, prod, copyHeroku,
  -> exec "git", ["init"], paths.herokuDestination
  -> exec "git", ["add", "."], paths.herokuDestination
  -> exec "git", ["commit", "-m", "deploy"], paths.herokuDestination
  -> exec "git", ["remote", "add", "heroku", urls.herokuGit],
          paths.herokuDestination
  -> exec "git", ["push", "-u", "heroku", "master", "--force"],
          paths.herokuDestination
  -> exec "heroku", ["open"], paths.herokuDestination

gulp.task "default", dev
gulp.task "clean", clean
gulp.task "service", buildService
gulp.task "client", buildClient
gulp.task "build", build
gulp.task "rebuild", rebuild
gulp.task "watch", watch
gulp.task "monitor", monitor
gulp.task "live", liveReload
gulp.task "open", open
gulp.task "dev", dev
gulp.task "redev", redev
gulp.task "prod", prod
gulp.task "app", app
gulp.task "heroku", heroku
