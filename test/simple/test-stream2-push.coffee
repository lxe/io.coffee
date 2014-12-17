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

# a mock thing a bit like the net.Socket/tcp_wrap.handle interaction
readStart = ->
  console.error "readStart"
  reading = true
  return
readStop = ->
  console.error "readStop"
  reading = false
  process.nextTick ->
    r = stream.read()
    writer.write r  if r isnt null
    return

  return

# now emit some chunks.
data = ->
  assert reading
  source.emit "data", chunk
  assert reading
  source.emit "data", chunk
  assert reading
  source.emit "data", chunk
  assert reading
  source.emit "data", chunk
  assert not reading
  if set++ < 5
    setTimeout data, 10
  else
    end()
  return
finish = ->
  console.error "finish"
  assert.deepEqual written, expectWritten
  console.log "ok"
  return
end = ->
  source.emit "end"
  assert not reading
  writer.end stream.read()
  setTimeout ->
    assert ended
    return

  return
common = require("../common.js")
stream = require("stream")
Readable = stream.Readable
Writable = stream.Writable
assert = require("assert")
util = require("util")
EE = require("events").EventEmitter
stream = new Readable(
  highWaterMark: 16
  encoding: "utf8"
)
source = new EE
stream._read = ->
  console.error "stream._read"
  readStart()
  return

ended = false
stream.on "end", ->
  ended = true
  return

source.on "data", (chunk) ->
  ret = stream.push(chunk)
  console.error "data", stream._readableState.length
  readStop()  unless ret
  return

source.on "end", ->
  stream.push null
  return

reading = false
writer = new Writable(decodeStrings: false)
written = []
expectWritten = [
  "asdfgasdfgasdfgasdfg"
  "asdfgasdfgasdfgasdfg"
  "asdfgasdfgasdfgasdfg"
  "asdfgasdfgasdfgasdfg"
  "asdfgasdfgasdfgasdfg"
  "asdfgasdfgasdfgasdfg"
]
writer._write = (chunk, encoding, cb) ->
  console.error "WRITE %s", chunk
  written.push chunk
  process.nextTick cb
  return

writer.on "finish", finish
chunk = "asdfg"
set = 0
readStart()
data()
