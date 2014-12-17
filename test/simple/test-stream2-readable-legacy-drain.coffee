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
drain = ->
  assert buffered <= 3
  buffered = 0
  w.emit "drain"
  return
common = require("../common")
assert = require("assert")
Stream = require("stream")
Readable = Stream.Readable
r = new Readable()
N = 256
reads = 0
r._read = (n) ->
  r.push (if ++reads is N then null else new Buffer(1))

rended = false
r.on "end", ->
  rended = true
  return

w = new Stream()
w.writable = true
writes = 0
buffered = 0
w.write = (c) ->
  writes += c.length
  buffered += c.length
  process.nextTick drain
  false

wended = false
w.end = ->
  wended = true
  return


# Just for kicks, let's mess with the drain count.
# This verifies that even if it gets negative in the
# pipe() cleanup function, we'll still function properly.
r.on "readable", ->
  w.emit "drain"
  return

r.pipe w
process.on "exit", ->
  assert rended
  assert wended
  console.error "ok"
  return

