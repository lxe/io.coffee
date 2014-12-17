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
  W.apply this, arguments
  @buffer = []
  @written = 0
  return

# simulate a small unpredictable latency

# tiny node-tap lookalike.
test = (name, fn) ->
  count++
  tests.push [
    name
    fn
  ]
  return
run = ->
  next = tests.shift()
  return console.error("ok")  unless next
  name = next[0]
  fn = next[1]
  console.log "# %s", name
  fn
    same: assert.deepEqual
    equal: assert.equal
    end: ->
      count--
      run()
      return

  return
common = require("../common.js")
W = require("_stream_writable")
D = require("_stream_duplex")
assert = require("assert")
util = require("util")
util.inherits TestWriter, W
TestWriter::_write = (chunk, encoding, cb) ->
  setTimeout (->
    @buffer.push chunk.toString()
    @written += chunk.length
    cb()
    return
  ).bind(this), Math.floor(Math.random() * 10)
  return

chunks = new Array(50)
i = 0

while i < chunks.length
  chunks[i] = new Array(i + 1).join("x")
  i++
tests = []
count = 0

# ensure all tests have run
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run
test "write fast", (t) ->
  tw = new TestWriter(highWaterMark: 100)
  tw.on "finish", ->
    t.same tw.buffer, chunks, "got chunks in the right order"
    t.end()
    return

  chunks.forEach (chunk) ->
    
    # screw backpressure.  Just buffer it all up.
    tw.write chunk
    return

  tw.end()
  return

test "write slow", (t) ->
  tw = new TestWriter(highWaterMark: 100)
  tw.on "finish", ->
    t.same tw.buffer, chunks, "got chunks in the right order"
    t.end()
    return

  i = 0
  (W = ->
    tw.write chunks[i++]
    if i < chunks.length
      setTimeout W, 10
    else
      tw.end()
    return
  )()
  return

test "write backpressure", (t) ->
  tw = new TestWriter(highWaterMark: 50)
  drains = 0
  tw.on "finish", ->
    t.same tw.buffer, chunks, "got chunks in the right order"
    t.equal drains, 17
    t.end()
    return

  tw.on "drain", ->
    drains++
    return

  i = 0
  (W = ->
    loop
      ret = tw.write(chunks[i++])
      break unless ret isnt false and i < chunks.length
    if i < chunks.length
      assert tw._writableState.length >= 50
      tw.once "drain", W
    else
      tw.end()
    return
  )()
  return

test "write bufferize", (t) ->
  tw = new TestWriter(highWaterMark: 100)
  encodings = [
    "hex"
    "utf8"
    "utf-8"
    "ascii"
    "binary"
    "base64"
    "ucs2"
    "ucs-2"
    "utf16le"
    "utf-16le"
    `undefined`
  ]
  tw.on "finish", ->
    t.same tw.buffer, chunks, "got the expected chunks"
    return

  chunks.forEach (chunk, i) ->
    enc = encodings[i % encodings.length]
    chunk = new Buffer(chunk)
    tw.write chunk.toString(enc), enc
    return

  t.end()
  return

test "write no bufferize", (t) ->
  tw = new TestWriter(
    highWaterMark: 100
    decodeStrings: false
  )
  tw._write = (chunk, encoding, cb) ->
    assert typeof chunk is "string"
    chunk = new Buffer(chunk, encoding)
    TestWriter::_write.call this, chunk, encoding, cb

  encodings = [
    "hex"
    "utf8"
    "utf-8"
    "ascii"
    "binary"
    "base64"
    "ucs2"
    "ucs-2"
    "utf16le"
    "utf-16le"
    `undefined`
  ]
  tw.on "finish", ->
    t.same tw.buffer, chunks, "got the expected chunks"
    return

  chunks.forEach (chunk, i) ->
    enc = encodings[i % encodings.length]
    chunk = new Buffer(chunk)
    tw.write chunk.toString(enc), enc
    return

  t.end()
  return

test "write callbacks", (t) ->
  callbacks = chunks.map((chunk, i) ->
    [
      i
      (er) ->
        callbacks._called[i] = chunk
    ]
  ).reduce((set, x) ->
    set["callback-" + x[0]] = x[1]
    set
  , {})
  callbacks._called = []
  tw = new TestWriter(highWaterMark: 100)
  tw.on "finish", ->
    process.nextTick ->
      t.same tw.buffer, chunks, "got chunks in the right order"
      t.same callbacks._called, chunks, "called all callbacks"
      t.end()
      return

    return

  chunks.forEach (chunk, i) ->
    tw.write chunk, callbacks["callback-" + i]
    return

  tw.end()
  return

test "end callback", (t) ->
  tw = new TestWriter()
  tw.end ->
    t.end()
    return

  return

test "end callback with chunk", (t) ->
  tw = new TestWriter()
  tw.end new Buffer("hello world"), ->
    t.end()
    return

  return

test "end callback with chunk and encoding", (t) ->
  tw = new TestWriter()
  tw.end "hello world", "ascii", ->
    t.end()
    return

  return

test "end callback after .write() call", (t) ->
  tw = new TestWriter()
  tw.write new Buffer("hello world")
  tw.end ->
    t.end()
    return

  return

test "end callback called after write callback", (t) ->
  tw = new TestWriter()
  writeCalledback = false
  tw.write new Buffer("hello world"), ->
    writeCalledback = true
    return

  tw.end ->
    t.equal writeCalledback, true
    t.end()
    return

  return

test "encoding should be ignored for buffers", (t) ->
  tw = new W()
  hex = "018b5e9a8f6236ffe30e31baf80d2cf6eb"
  tw._write = (chunk, encoding, cb) ->
    t.equal chunk.toString("hex"), hex
    t.end()
    return

  buf = new Buffer(hex, "hex")
  tw.write buf, "binary"
  return

test "writables are not pipable", (t) ->
  w = new W()
  w._write = ->

  gotError = false
  w.on "error", (er) ->
    gotError = true
    return

  w.pipe process.stdout
  assert gotError
  t.end()
  return

test "duplexes are pipable", (t) ->
  d = new D()
  d._read = ->

  d._write = ->

  gotError = false
  d.on "error", (er) ->
    gotError = true
    return

  d.pipe process.stdout
  assert not gotError
  t.end()
  return

test "end(chunk) two times is an error", (t) ->
  w = new W()
  w._write = ->

  gotError = false
  w.on "error", (er) ->
    gotError = true
    t.equal er.message, "write after end"
    return

  w.end "this is the end"
  w.end "and so is this"
  process.nextTick ->
    assert gotError
    t.end()
    return

  return

test "dont end while writing", (t) ->
  w = new W()
  wrote = false
  w._write = (chunk, e, cb) ->
    assert not @writing
    wrote = true
    @writing = true
    setTimeout ->
      @writing = false
      cb()
      return

    return

  w.on "finish", ->
    assert wrote
    t.end()
    return

  w.write Buffer(0)
  w.end()
  return

test "finish does not come before write cb", (t) ->
  w = new W()
  writeCb = false
  w._write = (chunk, e, cb) ->
    setTimeout (->
      writeCb = true
      cb()
      return
    ), 10
    return

  w.on "finish", ->
    assert writeCb
    t.end()
    return

  w.write Buffer(0)
  w.end()
  return

test "finish does not come before sync _write cb", (t) ->
  w = new W()
  writeCb = false
  w._write = (chunk, e, cb) ->
    cb()
    return

  w.on "finish", ->
    assert writeCb
    t.end()
    return

  w.write Buffer(0), (er) ->
    writeCb = true
    return

  w.end()
  return

test "finish is emitted if last chunk is empty", (t) ->
  w = new W()
  w._write = (chunk, e, cb) ->
    process.nextTick cb
    return

  w.on "finish", ->
    t.end()
    return

  w.write Buffer(1)
  w.end Buffer(0)
  return

