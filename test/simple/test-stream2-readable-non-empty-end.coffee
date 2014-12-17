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
thrower = ->
  throw new Error("this should not happen!")return
next = ->
  
  # now let's make 'end' happen
  test.removeListener "end", thrower
  endEmitted = false
  process.on "exit", ->
    assert endEmitted, "end should be emitted by now"
    return

  test.on "end", ->
    endEmitted = true
    return

  
  # one to get the last byte
  r = test.read()
  assert r
  assert.equal r.length, 1
  r = test.read()
  assert.equal r, null
  return
assert = require("assert")
common = require("../common.js")
Readable = require("_stream_readable")
len = 0
chunks = new Array(10)
i = 1

while i <= 10
  chunks[i - 1] = new Buffer(i)
  len += i
  i++
test = new Readable()
n = 0
test._read = (size) ->
  chunk = chunks[n++]
  setTimeout ->
    test.push (if chunk is `undefined` then null else chunk)
    return

  return

test.on "end", thrower
bytesread = 0
test.on "readable", ->
  b = len - bytesread - 1
  res = test.read(b)
  if res
    bytesread += res.length
    console.error "br=%d len=%d", bytesread, len
    setTimeout next
  test.read 0
  return

test.read 0
