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

# Backwards-compat with node 0.4.x

# old-style streams.  Note that the pipe method (the only relevant
# part of this class) is overridden in the Readable class.
Stream = ->
  EE.call this
  return
"use strict"
module.exports = Stream
EE = require("events").EventEmitter
util = require("util")
util.inherits Stream, EE
Stream.Readable = require("_stream_readable")
Stream.Writable = require("_stream_writable")
Stream.Duplex = require("_stream_duplex")
Stream.Transform = require("_stream_transform")
Stream.PassThrough = require("_stream_passthrough")
Stream.Stream = Stream
Stream::pipe = (dest, options) ->
  ondata = (chunk) ->
    source.pause()  if false is dest.write(chunk) and source.pause  if dest.writable
    return
  ondrain = ->
    source.resume()  if source.readable and source.resume
    return
  
  # If the 'end' option is not supplied, dest.end() will be called when
  # source gets the 'end' or 'close' events.  Only dest.end() once.
  onend = ->
    return  if didOnEnd
    didOnEnd = true
    dest.end()
    return
  onclose = ->
    return  if didOnEnd
    didOnEnd = true
    dest.destroy()  if util.isFunction(dest.destroy)
    return
  
  # don't leave dangling pipes when there are errors.
  onerror = (er) ->
    cleanup()
    throw er  if EE.listenerCount(this, "error") is 0 # Unhandled stream error in pipe.
    return
  
  # remove all the event listeners that were added.
  cleanup = ->
    source.removeListener "data", ondata
    dest.removeListener "drain", ondrain
    source.removeListener "end", onend
    source.removeListener "close", onclose
    source.removeListener "error", onerror
    dest.removeListener "error", onerror
    source.removeListener "end", cleanup
    source.removeListener "close", cleanup
    dest.removeListener "close", cleanup
    return
  source = this
  source.on "data", ondata
  dest.on "drain", ondrain
  if not dest._isStdio and (not options or options.end isnt false)
    source.on "end", onend
    source.on "close", onclose
  didOnEnd = false
  source.on "error", onerror
  dest.on "error", onerror
  source.on "end", cleanup
  source.on "close", cleanup
  dest.on "close", cleanup
  dest.emit "pipe", source
  
  # Allow for unix-like usage: A.pipe(B).pipe(C)
  dest
