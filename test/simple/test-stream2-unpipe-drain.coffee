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

# super slow write stream (callback never called)
TestReader = (id) ->
  stream.Readable.call this
  @reads = 0
  return
common = require("../common.js")
assert = require("assert")
stream = require("stream")
crypto = require("crypto")
util = require("util")
util.inherits TestWriter, stream.Writable
TestWriter::_write = (buffer, encoding, callback) ->
  console.log "write called"
  return

dest = new TestWriter()
util.inherits TestReader, stream.Readable
TestReader::_read = (size) ->
  @reads += 1
  @push crypto.randomBytes(size)
  return

src1 = new TestReader()
src2 = new TestReader()
src1.pipe dest
src1.once "readable", ->
  process.nextTick ->
    src2.pipe dest
    src2.once "readable", ->
      process.nextTick ->
        src1.unpipe dest
        return

      return

    return

  return

process.on "exit", ->
  assert.equal src1.reads, 2
  assert.equal src2.reads, 2
  return

