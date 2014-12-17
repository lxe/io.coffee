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
TestReadable = (opt) ->
  return new TestReadable(opt)  unless this instanceof TestReadable
  Readable.call this, opt
  @_ended = false
  return
TestWritable = (opt) ->
  return new TestWritable(opt)  unless this instanceof TestWritable
  Writable.call this, opt
  @_written = []
  return
common = require("../common")
assert = require("assert")
Readable = require("_stream_readable")
Writable = require("_stream_writable")
util = require("util")
util.inherits TestReadable, Readable
TestReadable::_read = (n) ->
  @emit "error", new Error("_read called twice")  if @_ended
  @_ended = true
  @push null
  return

util.inherits TestWritable, Writable
TestWritable::_write = (chunk, encoding, cb) ->
  @_written.push chunk
  cb()
  return


# this one should not emit 'end' until we read() from it later.
ender = new TestReadable()
enderEnded = false

# what happens when you pipe() a Readable that's already ended?
piper = new TestReadable()

# pushes EOF null, and length=0, so this will trigger 'end'
piper.read()
setTimeout ->
  ender.on "end", ->
    enderEnded = true
    return

  assert not enderEnded
  c = ender.read()
  assert.equal c, null
  w = new TestWritable()
  writableFinished = false
  w.on "finish", ->
    writableFinished = true
    return

  piper.pipe w
  process.on "exit", ->
    assert enderEnded
    assert writableFinished
    console.log "ok"
    return

  return

