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
common = require("../common.js")
assert = require("assert")
util = require("util")
stream = require("stream")
Read = ->
  stream.Readable.call this
  return

util.inherits Read, stream.Readable
Read::_read = (size) ->
  @push "x"
  @push null
  return

Write = ->
  stream.Writable.call this
  return

util.inherits Write, stream.Writable
Write::_write = (buffer, encoding, cb) ->
  @emit "error", new Error("boom")
  @emit "alldone"
  return

read = new Read()
write = new Write()
write.once "error", (err) ->

write.once "alldone", (err) ->
  console.log "ok"
  return

process.on "exit", (c) ->
  console.error "error thrown even with listener"
  return

read.pipe write
