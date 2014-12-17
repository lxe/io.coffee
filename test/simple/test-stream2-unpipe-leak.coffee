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
  stream.Writable.call this
  return

# Set this high so that we'd trigger a nextTick warning
# and/or RangeError if we do maybeReadMore wrong.
TestReader = ->
  stream.Readable.call this,
    highWaterMark: 0x10000

  return
common = require("../common.js")
assert = require("assert")
stream = require("stream")
chunk = new Buffer("hallo")
util = require("util")
util.inherits TestWriter, stream.Writable
TestWriter::_write = (buffer, encoding, callback) ->
  callback null
  return

dest = new TestWriter()
util.inherits TestReader, stream.Readable
TestReader::_read = (size) ->
  @push chunk
  return

src = new TestReader()
i = 0

while i < 10
  src.pipe dest
  src.unpipe dest
  i++
assert.equal src.listeners("end").length, 0
assert.equal src.listeners("readable").length, 0
assert.equal dest.listeners("unpipe").length, 0
assert.equal dest.listeners("drain").length, 0
assert.equal dest.listeners("error").length, 0
assert.equal dest.listeners("close").length, 0
assert.equal dest.listeners("finish").length, 0
console.error src._readableState
process.on "exit", ->
  src._readableState.buffer.length = 0
  console.error src._readableState
  assert src._readableState.length >= src._readableState.highWaterMark
  console.log "ok"
  return

