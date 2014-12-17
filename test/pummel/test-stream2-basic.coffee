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
TestReader = (n) ->
  R.apply this
  @_buffer = new Buffer(n or 100)
  @_buffer.fill "x"
  @_pos = 0
  @_bufs = 10
  return

# simulate the read buffer filling up with some more bytes some time
# in the future.

# read them all!

# now we have more.
# kinda cheating by calling _read, but whatever,
# it's just fake anyway.

#///
TestWriter = ->
  EE.apply this
  @received = []
  @flush = false
  return

#//////

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
    ok: assert
    equal: assert.equal
    end: ->
      count--
      run()
      return

  return
common = require("../common.js")
R = require("_stream_readable")
assert = require("assert")
util = require("util")
EE = require("events").EventEmitter
util.inherits TestReader, R
TestReader::_read = (n) ->
  max = @_buffer.length - @_pos
  n = Math.max(n, 0)
  toRead = Math.min(n, max)
  if toRead is 0
    setTimeout (->
      @_pos = 0
      @_bufs -= 1
      if @_bufs <= 0
        @push null  unless @ended
      else
        @_read n
      return
    ).bind(this), 10
    return
  ret = @_buffer.slice(@_pos, @_pos + toRead)
  @_pos += toRead
  @push ret
  return

util.inherits TestWriter, EE
TestWriter::write = (c) ->
  @received.push c.toString()
  @emit "write", c
  true

TestWriter::end = (c) ->
  @write c  if c
  @emit "end", @received
  return

tests = []
count = 0

# ensure all tests have run
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run
test "a most basic test", (t) ->
  flow = ->
    res = undefined
    reads.push res.toString()  while null isnt (res = r.read(readSize++))
    r.once "readable", flow
    return
  r = new TestReader(20)
  reads = []
  expect = [
    "x"
    "xx"
    "xxx"
    "xxxx"
    "xxxxx"
    "xxxxxxxxx"
    "xxxxxxxxxx"
    "xxxxxxxxxxxx"
    "xxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxxxxxxxx"
    "xxxxxxxxxxxxxxxxxxxxx"
  ]
  r.on "end", ->
    t.same reads, expect
    t.end()
    return

  readSize = 1
  flow()
  return

test "pipe", (t) ->
  r = new TestReader(5)
  expect = [
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
  ]
  w = new TestWriter
  flush = true
  w.on "end", (received) ->
    t.same received, expect
    t.end()
    return

  r.pipe w
  return

[
  1
  2
  3
  4
  5
  6
  7
  8
  9
].forEach (SPLIT) ->
  test "unpipe", (t) ->
    r = new TestReader(5)
    
    # unpipe after 3 writes, then write to another stream instead.
    expect = [
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
    ]
    expect = [
      expect.slice(0, SPLIT)
      expect.slice(SPLIT)
    ]
    w = [
      new TestWriter()
      new TestWriter()
    ]
    writes = SPLIT
    w[0].on "write", ->
      if --writes is 0
        r.unpipe()
        t.equal r._readableState.pipes, null
        w[0].end()
        r.pipe w[1]
        t.equal r._readableState.pipes, w[1]
      return

    ended = 0
    ended0 = false
    ended1 = false
    w[0].on "end", (results) ->
      t.equal ended0, false
      ended0 = true
      ended++
      t.same results, expect[0]
      return

    w[1].on "end", (results) ->
      t.equal ended1, false
      ended1 = true
      ended++
      t.equal ended, 2
      t.same results, expect[1]
      t.end()
      return

    r.pipe w[0]
    return

  return


# both writers should get the same exact data.
test "multipipe", (t) ->
  r = new TestReader(5)
  w = [
    new TestWriter
    new TestWriter
  ]
  expect = [
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
    "xxxxx"
  ]
  c = 2
  w[0].on "end", (received) ->
    t.same received, expect, "first"
    t.end()  if --c is 0
    return

  w[1].on "end", (received) ->
    t.same received, expect, "second"
    t.end()  if --c is 0
    return

  r.pipe w[0]
  r.pipe w[1]
  return

[
  1
  2
  3
  4
  5
  6
  7
  8
  9
].forEach (SPLIT) ->
  test "multi-unpipe", (t) ->
    r = new TestReader(5)
    
    # unpipe after 3 writes, then write to another stream instead.
    expect = [
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
      "xxxxx"
    ]
    expect = [
      expect.slice(0, SPLIT)
      expect.slice(SPLIT)
    ]
    w = [
      new TestWriter()
      new TestWriter()
      new TestWriter()
    ]
    writes = SPLIT
    w[0].on "write", ->
      if --writes is 0
        r.unpipe()
        w[0].end()
        r.pipe w[1]
      return

    ended = 0
    w[0].on "end", (results) ->
      ended++
      t.same results, expect[0]
      return

    w[1].on "end", (results) ->
      ended++
      t.equal ended, 2
      t.same results, expect[1]
      t.end()
      return

    r.pipe w[0]
    r.pipe w[2]
    return

  return

test "back pressure respected", (t) ->
  noop = ->
  r = new R(objectMode: true)
  r._read = noop
  counter = 0
  r.push ["one"]
  r.push ["two"]
  r.push ["three"]
  r.push ["four"]
  r.push null
  w1 = new R()
  w1.write = (chunk) ->
    console.error "w1.emit(\"close\")"
    assert.equal chunk[0], "one"
    w1.emit "close"
    process.nextTick ->
      r.pipe w2
      r.pipe w3
      return

    return

  w1.end = noop
  r.pipe w1
  expected = [
    "two"
    "two"
    "three"
    "three"
    "four"
    "four"
  ]
  w2 = new R()
  w2.write = (chunk) ->
    console.error "w2 write", chunk, counter
    assert.equal chunk[0], expected.shift()
    assert.equal counter, 0
    counter++
    return true  if chunk[0] is "four"
    setTimeout (->
      counter--
      console.error "w2 drain"
      w2.emit "drain"
      return
    ), 10
    false

  w2.end = noop
  w3 = new R()
  w3.write = (chunk) ->
    console.error "w3 write", chunk, counter
    assert.equal chunk[0], expected.shift()
    assert.equal counter, 1
    counter++
    return true  if chunk[0] is "four"
    setTimeout (->
      counter--
      console.error "w3 drain"
      w3.emit "drain"
      return
    ), 50
    false

  w3.end = ->
    assert.equal counter, 2
    assert.equal expected.length, 0
    t.end()
    return

  return

test "read(0) for ended streams", (t) ->
  r = new R()
  written = false
  ended = false
  r._read = (n) ->

  r.push new Buffer("foo")
  r.push null
  v = r.read(0)
  assert.equal v, null
  w = new R()
  w.write = (buffer) ->
    written = true
    assert.equal ended, false
    assert.equal buffer.toString(), "foo"
    return

  w.end = ->
    ended = true
    assert.equal written, true
    t.end()
    return

  r.pipe w
  return

test "sync _read ending", (t) ->
  r = new R()
  called = false
  r._read = (n) ->
    r.push null
    return

  r.once "end", ->
    called = true
    return

  r.read()
  process.nextTick ->
    assert.equal called, true
    t.end()
    return

  return

test "adding readable triggers data flow", (t) ->
  r = new R(highWaterMark: 5)
  onReadable = false
  readCalled = 0
  r._read = (n) ->
    if readCalled++ is 2
      r.push null
    else
      r.push new Buffer("asdf")
    return

  called = false
  r.on "readable", ->
    onReadable = true
    r.read()
    return

  r.on "end", ->
    t.equal readCalled, 3
    t.ok onReadable
    t.end()
    return

  return

test "chainable", (t) ->
  r = new R()
  r._read = ->

  r2 = r.setEncoding("utf8").pause().resume().pause()
  t.equal r, r2
  t.end()
  return

