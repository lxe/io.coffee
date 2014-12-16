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
Console = (stdout, stderr) ->
  return new Console(stdout, stderr)  unless this instanceof Console
  throw new TypeError("Console expects a writable stream instance")  if not stdout or not util.isFunction(stdout.write)
  stderr = stdout  unless stderr
  prop =
    writable: true
    enumerable: false
    configurable: true

  prop.value = stdout
  Object.defineProperty this, "_stdout", prop
  prop.value = stderr
  Object.defineProperty this, "_stderr", prop
  prop.value = {}
  Object.defineProperty this, "_times", prop
  
  # bind the prototype functions to this Console instance
  keys = Object.keys(Console::)
  v = 0

  while v < keys.length
    k = keys[v]
    this[k] = this[k].bind(this)
    v++
  return
"use strict"
util = require("util")
Console::log = ->
  @_stdout.write util.format.apply(this, arguments) + "\n"
  return

Console::info = Console::log
Console::warn = ->
  @_stderr.write util.format.apply(this, arguments) + "\n"
  return

Console::error = Console::warn
Console::dir = (object, options) ->
  @_stdout.write util.inspect(object, util._extend(
    customInspect: false
  , options)) + "\n"
  return

Console::time = (label) ->
  @_times[label] = Date.now()
  return

Console::timeEnd = (label) ->
  time = @_times[label]
  throw new Error("No such label: " + label)  unless time
  duration = Date.now() - time
  @log "%s: %dms", label, duration
  return

Console::trace = trace = ->
  
  # TODO probably can to do this better with V8's debug object once that is
  # exposed.
  err = new Error
  err.name = "Trace"
  err.message = util.format.apply(this, arguments)
  Error.captureStackTrace err, trace
  @error err.stack
  return

Console::assert = (expression) ->
  unless expression
    arr = Array::slice.call(arguments, 1)
    require("assert").ok false, util.format.apply(this, arr)
  return

module.exports = new Console(process.stdout, process.stderr)
module.exports.Console = Console
