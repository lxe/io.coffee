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
PassThrough = ->
  stream.Transform.call this
  return
TestStream = ->
  stream.Transform.call this
  return
common = require("../common")
assert = require("assert")
util = require("util")
stream = require("stream")
passed = false
util.inherits PassThrough, stream.Transform
PassThrough::_transform = (chunk, encoding, done) ->
  @push chunk
  done()
  return

util.inherits TestStream, stream.Transform
TestStream::_transform = (chunk, encoding, done) ->
  
  # Char 'a' only exists in the last write
  passed = chunk.toString().indexOf("a") >= 0  unless passed
  done()
  return

s1 = new PassThrough()
s2 = new PassThrough()
s3 = new TestStream()
s1.pipe s3

# Don't let s2 auto close which may close s3
s2.pipe s3,
  end: false


# We must write a buffer larger than highWaterMark
big = new Buffer(s1._writableState.highWaterMark + 1)
big.fill "x"

# Since big is larger than highWaterMark, it will be buffered internally.
assert not s1.write(big)

# 'tiny' is small enough to pass through internal buffer.
assert s2.write("tiny")

# Write some small data in next IO loop, which will never be written to s3
# Because 'drain' event is not emitted from s1 and s1 is still paused
setImmediate s1.write.bind(s1), "later"

# Assert after two IO loops when all operations have been done.
process.on "exit", ->
  assert passed, "Large buffer is not handled properly by Writable Stream"
  return

