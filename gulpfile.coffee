assign = require "lodash.assign"
browserify = require "browserify"
buffer = require "vinyl-buffer"
coffeeify = require "coffeeify"
del = require "del"
gulp = require "gulp"
jade = require "gulp-jade"
livereload = require "livereload"
process = require "process"
riotify = require "riotify"
source = require "vinyl-source-stream"
sourcemaps = require "gulp-sourcemaps"
spawn = require("child_process").spawn
stylus = require "gulp-stylus"
util = require "gulp-util"
watchify = require "watchify"

paths =
  clientScripts: "./src/client/index.coffee"
  serviceScripts: "./src/service/app.coffee"
  styles: "./src/**/*.styl"
  templates: "./src/**/*.jade"
  static: "./static/**/*"
  build: "./build"
  clientBuild: "./build/client"
  serviceBuild: "./build/service"

browserifyOpts =
  entries: paths.clientScripts,
  debug: yes
browserifyOpts = assign {}, watchify.args, browserifyOpts

run = (command, args, cwd = ".") ->
  runningCommand = spawn command, args, cwd: cwd
  runningCommand.stdout.on "data", (data) ->
    process.stdout.write "#{command}: #{data}"
  runningCommand.stderr.on "data", (data) ->
    process.stderr.write "#{command}: #{data}"
  runningCommand.on "exit", (code) ->
    process.stdout.write "#{command} exited with code #{code}"

clean = -> del "build"
buildStatic = ->
  gulp.src paths.static
    .pipe gulp.dest paths.build
buildScripts = (watch = no) ->
  bundler = browserify browserifyOpts
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
      .pipe gulp.dest paths.clientBuild
  bundler.on "log", util.log
  bundler.on "update", ->
    rebundle()
    util.log "Rebundle..."
  rebundle()
buildStyles = ->
  gulp.src paths.styles
    .pipe sourcemaps.init()
    .pipe stylus()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.build
buildTemplates = ->
  gulp.src paths.templates
    .pipe sourcemaps.init()
    .pipe jade pretty: yes
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.build
build = gulp.parallel buildStatic, buildScripts, buildStyles, buildTemplates
watchScripts = -> buildScripts yes
watchOthers = ->
  gulp.watch paths.styles, buildStyles
  gulp.watch paths.templates, buildTemplates
  gulp.watch paths.static, buildStatic
watch = gulp.parallel watchScripts, watchOthers
db = -> #run "mongodb", ["--dbpath", "./data"]
app = -> run "python", ["-m", "SimpleHTTPServer"], "build/client"
liveReload = gulp.parallel app, ->
  livereload.createServer().watch paths.clientBuild
start = gulp.parallel db, app
dev = gulp.series clean, build, gulp.parallel watch, liveReload

gulp.task "clean", clean
gulp.task "build", build
gulp.task "watch", watch
gulp.task "start", start
gulp.task "db", db
gulp.task "app", app
gulp.task "live", liveReload
gulp.task "default", dev

