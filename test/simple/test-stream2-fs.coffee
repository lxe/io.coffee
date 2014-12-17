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
TestWriter = ->
  Stream.apply this
  @buffer = []
  @length = 0
  return
common = require("../common.js")
R = require("_stream_readable")
assert = require("assert")
fs = require("fs")
FSReadable = fs.ReadStream
path = require("path")
file = path.resolve(common.fixturesDir, "x1024.txt")
size = fs.statSync(file).size
expectLengths = [1024]
util = require("util")
Stream = require("stream")
util.inherits TestWriter, Stream
TestWriter::write = (c) ->
  @buffer.push c.toString()
  @length += c.length
  true

TestWriter::end = (c) ->
  @buffer.push c.toString()  if c
  @emit "results", @buffer
  return

r = new FSReadable(file)
w = new TestWriter()
w.on "results", (res) ->
  console.error res, w.length
  assert.equal w.length, size
  l = 0
  assert.deepEqual res.map((c) ->
    c.length
  ), expectLengths
  console.log "ok"
  return

r.pipe w
