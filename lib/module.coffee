# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# If obj.hasOwnProperty has been overridden, then calling
# obj.hasOwnProperty(prop) will break.
# See: https://github.com/joyent/node/issues/1707
hasOwnProperty = (obj, prop) ->
  Object::hasOwnProperty.call obj, prop
Module = (id, parent) ->
  @id = id
  @exports = {}
  @parent = parent
  parent.children.push this  if parent and parent.children
  @filename = null
  @loaded = false
  @children = []
  return

# Set the environ variable NODE_MODULE_CONTEXTS=1 to make node load all
# modules in their own context.

# We use this alias for the preprocessor that filters it out

# given a module name, and a list of paths to test, returns the first
# matching file in the following precedence.
#
# require("a.<ext>")
#   -> a.<ext>
#
# require("a")
#   -> a
#   -> a.<ext>
#   -> a/index.<ext>
statPath = (path) ->
  try
    return fs.statSync(path)
  false

# check if the directory is a package.json dir
readPackage = (requestPath) ->
  return packageMainCache[requestPath]  if hasOwnProperty(packageMainCache, requestPath)
  try
    jsonPath = path.resolve(requestPath, "package.json")
    json = fs.readFileSync(jsonPath, "utf8")
  catch e
    return false
  try
    pkg = packageMainCache[requestPath] = JSON.parse(json).main
  catch e
    e.path = jsonPath
    e.message = "Error parsing " + jsonPath + ": " + e.message
    throw e
  pkg
tryPackage = (requestPath, exts) ->
  pkg = readPackage(requestPath)
  return false  unless pkg
  filename = path.resolve(requestPath, pkg)
  tryFile(filename, null) or tryExtensions(filename, exts) or tryExtensions(path.resolve(filename, "index"), exts)

# In order to minimize unnecessary lstat() calls,
# this cache is a list of known-real paths.
# Set to an empty object to reset.

# check if the file exists and is not a directory
tryFile = (requestPath, stats) ->
  stats = stats or statPath(requestPath)
  return fs.realpathSync(requestPath, Module._realpathCache)  if stats and not stats.isDirectory()
  false

# given a path check a the file exists with any of the set extensions
tryExtensions = (p, exts) ->
  i = 0
  EL = exts.length

  while i < EL
    filename = tryFile(p + exts[i], null)
    return filename  if filename
    i++
  false

# For each path

# try to join the request to the path

# try it with each of the extensions

# try it with each of the extensions at "index"

# 'from' is the __dirname of the module.

# guarantee that 'from' is absolute.

# note: this approach *only* works when the path is guaranteed
# to be absolute.  Doing a fully-edge-case-correct path.split
# that works on both Windows and Posix is non-trivial.

# don't search in .../node_modules/node_modules

# with --eval, parent.id is not set and parent.filename is null

# make require('./path/to/foo') work - normally the path is taken
# from realpath(__filename) but with eval there is no filename

# Is the parent an index module?
# We can assume the parent has a valid extension,
# as it already has been accepted as a module.

# make sure require('./path') and require('path') get distinct ids, even
# when called from the toplevel js file

# Check the cache for the requested file.
# 1. If a module already exists in the cache: return its exports object.
# 2. If the module is native: call `NativeModule.require()` with the
#    filename and return the result.
# 3. Otherwise, create a new module for the file and save it to the cache.
#    Then have it load  the file contents before returning its exports
#    object.

# REPL is a special case, because it needs the real require.

# look up the filename first, since that's the cache key.

# Given a file name, pass it to the proper extension handler.

# Loads a module at the given file path. Returns that module's
# `exports` property.

# Resolved path to process.argv[1] will be lazily placed here
# (needed for setting breakpoint when called with --debug-brk)

# Run the file contents in the correct scope or sandbox. Expose
# the correct helper variables (require, module, exports) to
# the file.
# Returns exception, if any.

# remove shebang

# Enable support to add extra extension types

# not root module

# root module

# create wrapper function

# we enter the repl if we're not given a filename argument.

# Set breakpoint on module start
stripBOM = (content) ->
  
  # Remove byte order marker. This catches EF BB BF (the UTF-8 BOM)
  # because the buffer-to-string conversion in `fs.readFileSync()`
  # translates it to FEFF, the UTF-16 BOM.
  content = content.slice(1)  if content.charCodeAt(0) is 0xfeff
  content
"use strict"
NativeModule = require("native_module")
util = NativeModule.require("util")
runInThisContext = require("vm").runInThisContext
runInNewContext = require("vm").runInNewContext
assert = require("assert").ok
fs = NativeModule.require("fs")
module.exports = Module
Module._contextLoad = (+process.env["NODE_MODULE_CONTEXTS"] > 0)
Module._cache = {}
Module._pathCache = {}
Module._extensions = {}
modulePaths = []
Module.globalPaths = []
Module.wrapper = NativeModule.wrapper
Module.wrap = NativeModule.wrap
path = NativeModule.require("path")
Module._debug = util.debuglog("module")
debug = Module._debug
packageMainCache = {}
Module._realpathCache = {}
Module._findPath = (request, paths) ->
  exts = Object.keys(Module._extensions)
  paths = [""]  if request.charAt(0) is "/"
  trailingSlash = (request.slice(-1) is "/")
  cacheKey = JSON.stringify(
    request: request
    paths: paths
  )
  return Module._pathCache[cacheKey]  if Module._pathCache[cacheKey]
  i = 0
  PL = paths.length

  while i < PL
    basePath = path.resolve(paths[i], request)
    filename = undefined
    unless trailingSlash
      stats = statPath(basePath)
      filename = tryFile(basePath, stats)
      filename = tryPackage(basePath, exts)  if not filename and stats and stats.isDirectory()
      filename = tryExtensions(basePath, exts)  unless filename
    filename = tryPackage(basePath, exts)  unless filename
    filename = tryExtensions(path.resolve(basePath, "index"), exts)  unless filename
    if filename
      Module._pathCache[cacheKey] = filename
      return filename
    i++
  false

Module._nodeModulePaths = (from) ->
  from = path.resolve(from)
  splitRe = (if process.platform is "win32" then /[\/\\]/ else /\//)
  paths = []
  parts = from.split(splitRe)
  tip = parts.length - 1

  while tip >= 0
    continue  if parts[tip] is "node_modules"
    dir = parts.slice(0, tip + 1).concat("node_modules").join(path.sep)
    paths.push dir
    tip--
  paths

Module._resolveLookupPaths = (request, parent) ->
  if NativeModule.exists(request)
    return [
      request
      []
    ]
  start = request.substring(0, 2)
  if start isnt "./" and start isnt ".."
    paths = modulePaths
    if parent
      parent.paths = []  unless parent.paths
      paths = parent.paths.concat(paths)
    return [
      request
      paths
    ]
  if not parent or not parent.id or not parent.filename
    mainPaths = ["."].concat(modulePaths)
    mainPaths = Module._nodeModulePaths(".").concat(mainPaths)
    return [
      request
      mainPaths
    ]
  isIndex = /^index\.\w+?$/.test(path.basename(parent.filename))
  parentIdPath = (if isIndex then parent.id else path.dirname(parent.id))
  id = path.resolve(parentIdPath, request)
  id = "./" + id  if parentIdPath is "." and id.indexOf("/") is -1
  debug "RELATIVE: requested:" + request + " set ID to: " + id + " from " + parent.id
  [
    id
    [path.dirname(parent.filename)]
  ]

Module._load = (request, parent, isMain) ->
  debug "Module._load REQUEST  " + (request) + " parent: " + parent.id  if parent
  filename = Module._resolveFilename(request, parent)
  cachedModule = Module._cache[filename]
  return cachedModule.exports  if cachedModule
  if NativeModule.exists(filename)
    if filename is "repl"
      replModule = new Module("repl")
      replModule._compile NativeModule.getSource("repl"), "repl.js"
      NativeModule._cache.repl = replModule
      return replModule.exports
    debug "load native module " + request
    return NativeModule.require(filename)
  module = new Module(filename, parent)
  if isMain
    process.mainModule = module
    module.id = "."
  Module._cache[filename] = module
  hadException = true
  try
    module.load filename
    hadException = false
  finally
    delete Module._cache[filename]  if hadException
  module.exports

Module._resolveFilename = (request, parent) ->
  return request  if NativeModule.exists(request)
  resolvedModule = Module._resolveLookupPaths(request, parent)
  id = resolvedModule[0]
  paths = resolvedModule[1]
  debug "looking for " + JSON.stringify(id) + " in " + JSON.stringify(paths)
  filename = Module._findPath(request, paths)
  unless filename
    err = new Error("Cannot find module '" + request + "'")
    err.code = "MODULE_NOT_FOUND"
    throw err
  filename

Module::load = (filename) ->
  debug "load " + JSON.stringify(filename) + " for module " + JSON.stringify(@id)
  assert not @loaded
  @filename = filename
  @paths = Module._nodeModulePaths(path.dirname(filename))
  extension = path.extname(filename) or ".js"
  extension = ".js"  unless Module._extensions[extension]
  Module._extensions[extension] this, filename
  @loaded = true
  return

Module::require = (path) ->
  assert path, "missing path"
  assert util.isString(path), "path must be a string"
  Module._load path, this

resolvedArgv = undefined
Module::_compile = (content, filename) ->
  require = (path) ->
    self.require path
  self = this
  content = content.replace(/^\#\!.*/, "")
  require.resolve = (request) ->
    Module._resolveFilename request, self

  Object.defineProperty require, "paths",
    get: ->
      throw new Error("require.paths is removed. Use " + "node_modules folders, or the NODE_PATH " + "environment variable instead.")return

  require.main = process.mainModule
  require.extensions = Module._extensions
  require.registerExtension = ->
    throw new Error("require.registerExtension() removed. Use " + "require.extensions instead.")return

  require.cache = Module._cache
  dirname = path.dirname(filename)
  if Module._contextLoad
    if self.id isnt "."
      debug "load submodule"
      sandbox = {}
      for k of global
        sandbox[k] = global[k]
      sandbox.require = require
      sandbox.exports = self.exports
      sandbox.__filename = filename
      sandbox.__dirname = dirname
      sandbox.module = self
      sandbox.global = sandbox
      sandbox.root = root
      return runInNewContext(content, sandbox,
        filename: filename
      )
    debug "load root module"
    global.require = require
    global.exports = self.exports
    global.__filename = filename
    global.__dirname = dirname
    global.module = self
    return runInThisContext(content,
      filename: filename
    )
  wrapper = Module.wrap(content)
  compiledWrapper = runInThisContext(wrapper,
    filename: filename
  )
  if global.v8debug
    unless resolvedArgv
      if process.argv[1]
        resolvedArgv = Module._resolveFilename(process.argv[1], null)
      else
        resolvedArgv = "repl"
    global.v8debug.Debug.setBreakPoint compiledWrapper, 0, 0  if filename is resolvedArgv
  args = [
    self.exports
    require
    self
    filename
    dirname
  ]
  compiledWrapper.apply self.exports, args


# Native extension for .js
Module._extensions[".js"] = (module, filename) ->
  content = fs.readFileSync(filename, "utf8")
  module._compile stripBOM(content), filename
  return


# Native extension for .json
Module._extensions[".json"] = (module, filename) ->
  content = fs.readFileSync(filename, "utf8")
  try
    module.exports = JSON.parse(stripBOM(content))
  catch err
    err.message = filename + ": " + err.message
    throw err
  return


#Native extension for .node
Module._extensions[".node"] = process.dlopen

# bootstrap main module.
Module.runMain = ->
  
  # Load the main module--the command line argument.
  Module._load process.argv[1], null, true
  
  # Handle any nextTicks added in the first tick of the program
  process._tickCallback()
  return

Module._initPaths = ->
  isWindows = process.platform is "win32"
  if isWindows
    homeDir = process.env.USERPROFILE
  else
    homeDir = process.env.HOME
  paths = [path.resolve(process.execPath, "..", "..", "lib", "node")]
  if homeDir
    paths.unshift path.resolve(homeDir, ".node_libraries")
    paths.unshift path.resolve(homeDir, ".node_modules")
  nodePath = process.env["NODE_PATH"]
  paths = nodePath.split(path.delimiter).concat(paths)  if nodePath
  modulePaths = paths
  
  # clone as a read-only copy, for introspection.
  Module.globalPaths = modulePaths.slice(0)
  return


# bootstrap repl
Module.requireRepl = ->
  Module._load "repl", "."

Module._initPaths()

# backwards compatibility
Module.Module = Module
