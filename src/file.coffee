_ = require 'underscore'
path = require 'path'
fs = require 'fs'

lstat = if process.platform is 'win32' then 'stat' else 'lstat'
lstatSync = fs["#{ lstat }Sync"]

defaults =
  args : []
  postfix : ''
  extension : '.js'
  exclude : []
  parse : (data) -> data

readFile = (file, fileCallback, dirCallback) ->
  return unless fs.existsSync file

  if lstatSync(file).isDirectory()
    readDir file, fileCallback, dirCallback
  else
    fileCallback file

readDir = (dir, fileCallback, dirCallback) ->
  return unless fs.existsSync dir

  fs.readdirSync(dir).forEach (file) ->
    readFile path.join(dir, file), fileCallback, dirCallback

  dirCallback? dir

requireFile = (obj, options, file) ->
  if path.extname(file) is options.extension and
  (key = path.basename file, options.postfix) not in options.exclude
    val = require file

    if _.isFunction(val) and options.args.length
      val = val.apply undefined, options.args

    obj[key] = options.parse val if key

  obj

clean = (file) ->
  return unless fs.existsSync file
  readFile file, fs.unlinkSync, fs.rmdirSync

requireDirectory = (dir, options = {}) ->
  options = _.defaults options, defaults
  obj = {}

  options.postfix += options.extension
  readDir dir, requireFile.bind(undefined, obj, options)

  obj

module.exports =
  readDir: readDir
  readFile: readFile
  clean: clean
  requireDirectory: requireDirectory
