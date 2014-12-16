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

# backwards-compat
ReadStream = (fd, options) ->
  return new ReadStream(fd, options)  unless this instanceof ReadStream
  options = util._extend(
    highWaterMark: 0
    readable: true
    writable: false
    handle: new TTY(fd, true)
  , options)
  net.Socket.call this, options
  @isRaw = false
  @isTTY = true
  return
WriteStream = (fd) ->
  return new WriteStream(fd)  unless this instanceof WriteStream
  net.Socket.call this,
    handle: new TTY(fd, false)
    readable: false
    writable: true

  winSize = []
  err = @_handle.getWindowSize(winSize)
  unless err
    @columns = winSize[0]
    @rows = winSize[1]
  return
"use strict"
inherits = require("util").inherits
net = require("net")
TTY = process.binding("tty_wrap").TTY
isTTY = process.binding("tty_wrap").isTTY
util = require("util")
errnoException = util._errnoException
exports.isatty = (fd) ->
  isTTY fd

exports.setRawMode = util.deprecate((flag) ->
  throw new Error("can't set raw mode on non-tty")  unless process.stdin.isTTY
  process.stdin.setRawMode flag
  return
, "tty.setRawMode: Use `process.stdin.setRawMode()` instead.")
inherits ReadStream, net.Socket
exports.ReadStream = ReadStream
ReadStream::setRawMode = (flag) ->
  flag = !!flag
  @_handle.setRawMode flag
  @isRaw = flag
  return

inherits WriteStream, net.Socket
exports.WriteStream = WriteStream
WriteStream::isTTY = true
WriteStream::_refreshSize = ->
  oldCols = @columns
  oldRows = @rows
  winSize = []
  err = @_handle.getWindowSize(winSize)
  if err
    @emit "error", errnoException(err, "getWindowSize")
    return
  newCols = winSize[0]
  newRows = winSize[1]
  if oldCols isnt newCols or oldRows isnt newRows
    @columns = newCols
    @rows = newRows
    @emit "resize"
  return


# backwards-compat
WriteStream::cursorTo = (x, y) ->
  require("readline").cursorTo this, x, y
  return

WriteStream::moveCursor = (dx, dy) ->
  require("readline").moveCursor this, dx, dy
  return

WriteStream::clearLine = (dir) ->
  require("readline").clearLine this, dir
  return

WriteStream::clearScreenDown = ->
  require("readline").clearScreenDown this
  return

WriteStream::getWindowSize = ->
  [
    this.columns
    this.rows
  ]
