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

# Test that having a bunch of streams piping in parallel
# doesn't break anything.
FakeStream = ->
  Stream.apply this
  @wait = false
  @writable = true
  @readable = true
  return
common = require("../common")
assert = require("assert")
Stream = require("stream").Stream
rr = []
ww = []
cnt = 100
chunks = 1000
chunkSize = 250
data = new Buffer(chunkSize)
wclosed = 0
rclosed = 0
FakeStream:: = Object.create(Stream::)
FakeStream::write = (chunk) ->
  console.error @ID, "write", @wait
  process.nextTick @emit.bind(this, "drain")  if @wait
  @wait = not @wait
  @wait

FakeStream::end = ->
  @emit "end"
  process.nextTick @close.bind(this)
  return


# noop - closes happen automatically on end.
FakeStream::close = ->
  @emit "close"
  return


# expect all streams to close properly.
process.on "exit", ->
  assert.equal cnt, wclosed, "writable streams closed"
  assert.equal cnt, rclosed, "readable streams closed"
  return

i = 0

while i < chunkSize
  chunkSize[i] = i % 256
  i++
i = 0

while i < cnt
  r = new FakeStream()
  r.on "close", ->
    console.error @ID, "read close"
    rclosed++
    return

  rr.push r
  w = new FakeStream()
  w.on "close", ->
    console.error @ID, "write close"
    wclosed++
    return

  ww.push w
  r.ID = w.ID = i
  r.pipe w
  i++

# now start passing through data
# simulate a relatively fast async stream.
rr.forEach (r) ->
  step = ->
    r.emit "data", data
    if --cnt is 0
      r.end()
      return
    return  if paused
    process.nextTick step
    return
  cnt = chunks
  paused = false
  r.on "pause", ->
    paused = true
    return

  r.on "resume", ->
    paused = false
    step()
    return

  process.nextTick step
  return

