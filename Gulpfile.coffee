# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
runSequence = require 'run-sequence'

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

cleanDir = (dir, cb) ->
  fs = require 'fs'

  if fs.existsSync dir
    gulp.src("#{ dir }/*", read: false)
      .pipe($.plumber errorHandler: alertError)
      .pipe $.clean force: true
      .end cb
  else
    fs.mkdir dir, cb

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', cleanDir.bind null, 'lib'

# ------------------------------------------------------------------------------
# Compile
# ------------------------------------------------------------------------------
gulp.task 'compile', ->
  gulp.src('src/**.coffee')
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed 'lib')
    .pipe($.coffee bare: true)
    .pipe(gulp.dest 'lib')

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  gulp.watch 'src/**', ['compile']
  cb()

# ------------------------------------------------------------------------------
# Bump
# ------------------------------------------------------------------------------
(->
  bump = (type) ->
    ->
      gulp.src('./package.json')
        .pipe($.bump type: type)
        .pipe(gulp.dest './')

  gulp.task 'bump', bump 'patch'
  gulp.task 'bump:prerelease', bump 'prerelease'
  gulp.task 'bump:patch', bump 'patch'
  gulp.task 'bump:minor', bump 'minor'
  gulp.task 'bump:major', bump 'minor'
)()

# ------------------------------------------------------------------------------
# Publish
# ------------------------------------------------------------------------------
gulp.task 'publish', (cb) ->
  spawn = require('child_process').spawn
  spawn('npm', ['publish'], stdio: 'inherit').on 'close', cb

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'clean', 'compile', 'watch'
