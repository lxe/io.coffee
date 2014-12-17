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

# This test verifies that:
# 1. unshift() does not cause colliding _read() calls.
# 2. unshift() after the 'end' event is an error, but after the EOF
#    signalling null, it is ok, and just creates a new readable chunk.
# 3. push() after the EOF signaling null is an error.
# 4. _read() is not called after pushing the EOF null chunk.

# every third chunk is fast
pushError = ->
  assert.throws ->
    r.push new Buffer(1)
    return

  return
common = require("../common")
assert = require("assert")
stream = require("stream")
hwm = 10
r = stream.Readable(highWaterMark: hwm)
chunks = 10
t = (chunks * 5)
data = new Buffer(chunks * hwm + Math.ceil(hwm / 2))
i = 0

while i < data.length
  c = "asdf".charCodeAt(i % 4)
  data[i] = c
  i++
pos = 0
pushedNull = false
r._read = (n) ->
  push = (fast) ->
    assert not pushedNull, "push() after null push"
    c = (if pos >= data.length then null else data.slice(pos, pos + n))
    pushedNull = c is null
    if fast
      pos += n
      r.push c
      pushError()  if c is null
    else
      setTimeout ->
        pos += n
        r.push c
        pushError()  if c is null
        return

    return
  assert not pushedNull, "_read after null push"
  push not (chunks % 3)
  return

w = stream.Writable()
written = []
w._write = (chunk, encoding, cb) ->
  written.push chunk.toString()
  cb()
  return

ended = false
r.on "end", ->
  assert not ended, "end emitted more than once"
  assert.throws ->
    r.unshift new Buffer(1)
    return

  ended = true
  w.end()
  return

r.on "readable", ->
  chunk = undefined
  while null isnt (chunk = r.read(10))
    w.write chunk
    r.unshift new Buffer("1234")  if chunk.length > 4
  return

finished = false
w.on "finish", ->
  finished = true
  
  # each chunk should start with 1234, and then be asfdasdfasdf...
  # The first got pulled out before the first unshift('1234'), so it's
  # lacking that piece.
  assert.equal written[0], "asdfasdfas"
  asdf = "d"
  console.error "0: %s", written[0]
  i = 1

  while i < written.length
    console.error "%s: %s", i.toString(32), written[i]
    assert.equal written[i].slice(0, 4), "1234"
    j = 4

    while j < written[i].length
      c = written[i].charAt(j)
      assert.equal c, asdf
      switch asdf
        when "a"
          asdf = "s"
        when "s"
          asdf = "d"
        when "d"
          asdf = "f"
        when "f"
          asdf = "a"
      j++
    i++
  return

process.on "exit", ->
  assert.equal written.length, 18
  assert ended, "stream ended"
  assert finished, "stream finished"
  console.log "ok"
  return

