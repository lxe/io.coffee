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
common = require("../common")
assert = require("assert")
Transform = require("stream").Transform
parser = new Transform(readableObjectMode: true)
assert parser._readableState.objectMode
assert not parser._writableState.objectMode
assert parser._readableState.highWaterMark is 16
assert parser._writableState.highWaterMark is (16 * 1024)
parser._transform = (chunk, enc, callback) ->
  callback null,
    val: chunk[0]

  return

parsed = undefined
parser.on "data", (obj) ->
  parsed = obj
  return

parser.end new Buffer([42])
process.on "exit", ->
  assert parsed.val is 42
  return

serializer = new Transform(writableObjectMode: true)
assert not serializer._readableState.objectMode
assert serializer._writableState.objectMode
assert serializer._readableState.highWaterMark is (16 * 1024)
assert serializer._writableState.highWaterMark is 16
serializer._transform = (obj, _, callback) ->
  callback null, new Buffer([obj.val])
  return

serialized = undefined
serializer.on "data", (chunk) ->
  serialized = chunk
  return

serializer.write val: 42
process.on "exit", ->
  assert serialized[0] is 42
  return

