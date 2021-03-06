path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'

browserSync = require 'browser-sync'

watchedTasks = {}
destinations = []

source = (src) ->
  switch typeof src
    when 'string' then gulp.src src
    when 'function' then src()
    else src

pipe = (stream, pipes, dest) ->
  stream = stream.pipe step() for step in pipes
  stream.pipe gulp.dest dest

exports.task = (name, src, pipes..., dest) ->
  if Array.isArray src
    gulp.task name, src, dest
  else
    gulp.task name, ->
      pipe source(src), pipes, dest

exports.watch = (name, src, pipes..., dest, files) ->
  watchedTasks[name] = src
  destinations.push path.join dest, files if files
  gulp.task name, ->
    stream = source src
      .pipe cache name
    stream = pipe stream, pipes, dest
    stream.pipe notify 'Compiled <%= file.relative %>' if files

exports.serve = (baseDir = './') ->
  browserSync.init destinations,
    server: {baseDir}
    notify: false
  for task, path of watchedTasks
    gulp.watch path, [task]

