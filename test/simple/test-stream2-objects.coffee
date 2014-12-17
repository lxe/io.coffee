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

# ensure all tests have run
toArray = (callback) ->
  stream = new Writable(objectMode: true)
  list = []
  stream.write = (chunk) ->
    list.push chunk
    return

  stream.end = ->
    callback list
    return

  stream
fromArray = (list) ->
  r = new Readable(objectMode: true)
  r._read = noop
  list.forEach (chunk) ->
    r.push chunk
    return

  r.push null
  r
noop = ->
common = require("../common.js")
Readable = require("_stream_readable")
Writable = require("_stream_writable")
assert = require("assert")
tests = []
count = 0
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run
test "can read objects from stream", (t) ->
  r = fromArray([
    {
      one: "1"
    }
    {
      two: "2"
    }
  ])
  v1 = r.read()
  v2 = r.read()
  v3 = r.read()
  assert.deepEqual v1,
    one: "1"

  assert.deepEqual v2,
    two: "2"

  assert.deepEqual v3, null
  t.end()
  return

test "can pipe objects into stream", (t) ->
  r = fromArray([
    {
      one: "1"
    }
    {
      two: "2"
    }
  ])
  r.pipe toArray((list) ->
    assert.deepEqual list, [
      {
        one: "1"
      }
      {
        two: "2"
      }
    ]
    t.end()
    return
  )
  return

test "read(n) is ignored", (t) ->
  r = fromArray([
    {
      one: "1"
    }
    {
      two: "2"
    }
  ])
  value = r.read(2)
  assert.deepEqual value,
    one: "1"

  t.end()
  return

test "can read objects from _read (sync)", (t) ->
  r = new Readable(objectMode: true)
  list = [
    {
      one: "1"
    }
    {
      two: "2"
    }
  ]
  r._read = (n) ->
    item = list.shift()
    r.push item or null
    return

  r.pipe toArray((list) ->
    assert.deepEqual list, [
      {
        one: "1"
      }
      {
        two: "2"
      }
    ]
    t.end()
    return
  )
  return

test "can read objects from _read (async)", (t) ->
  r = new Readable(objectMode: true)
  list = [
    {
      one: "1"
    }
    {
      two: "2"
    }
  ]
  r._read = (n) ->
    item = list.shift()
    process.nextTick ->
      r.push item or null
      return

    return

  r.pipe toArray((list) ->
    assert.deepEqual list, [
      {
        one: "1"
      }
      {
        two: "2"
      }
    ]
    t.end()
    return
  )
  return

test "can read strings as objects", (t) ->
  r = new Readable(objectMode: true)
  r._read = noop
  list = [
    "one"
    "two"
    "three"
  ]
  list.forEach (str) ->
    r.push str
    return

  r.push null
  r.pipe toArray((array) ->
    assert.deepEqual array, list
    t.end()
    return
  )
  return

test "read(0) for object streams", (t) ->
  r = new Readable(objectMode: true)
  r._read = noop
  r.push "foobar"
  r.push null
  v = r.read(0)
  r.pipe toArray((array) ->
    assert.deepEqual array, ["foobar"]
    t.end()
    return
  )
  return

test "falsey values", (t) ->
  r = new Readable(objectMode: true)
  r._read = noop
  r.push false
  r.push 0
  r.push ""
  r.push null
  r.pipe toArray((array) ->
    assert.deepEqual array, [
      false
      0
      ""
    ]
    t.end()
    return
  )
  return

test "high watermark _read", (t) ->
  r = new Readable(
    highWaterMark: 6
    objectMode: true
  )
  calls = 0
  list = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
  ]
  r._read = (n) ->
    calls++
    return

  list.forEach (c) ->
    r.push c
    return

  v = r.read()
  assert.equal calls, 0
  assert.equal v, "1"
  v2 = r.read()
  assert.equal v2, "2"
  v3 = r.read()
  assert.equal v3, "3"
  assert.equal calls, 1
  t.end()
  return

test "high watermark push", (t) ->
  r = new Readable(
    highWaterMark: 6
    objectMode: true
  )
  r._read = (n) ->

  i = 0

  while i < 6
    bool = r.push(i)
    assert.equal bool, (if i is 5 then false else true)
    i++
  t.end()
  return

test "can write objects to stream", (t) ->
  w = new Writable(objectMode: true)
  w._write = (chunk, encoding, cb) ->
    assert.deepEqual chunk,
      foo: "bar"

    cb()
    return

  w.on "finish", ->
    t.end()
    return

  w.write foo: "bar"
  w.end()
  return

test "can write multiple objects to stream", (t) ->
  w = new Writable(objectMode: true)
  list = []
  w._write = (chunk, encoding, cb) ->
    list.push chunk
    cb()
    return

  w.on "finish", ->
    assert.deepEqual list, [
      0
      1
      2
      3
      4
    ]
    t.end()
    return

  w.write 0
  w.write 1
  w.write 2
  w.write 3
  w.write 4
  w.end()
  return

test "can write strings as objects", (t) ->
  w = new Writable(objectMode: true)
  list = []
  w._write = (chunk, encoding, cb) ->
    list.push chunk
    process.nextTick cb
    return

  w.on "finish", ->
    assert.deepEqual list, [
      "0"
      "1"
      "2"
      "3"
      "4"
    ]
    t.end()
    return

  w.write "0"
  w.write "1"
  w.write "2"
  w.write "3"
  w.write "4"
  w.end()
  return

test "buffers finish until cb is called", (t) ->
  w = new Writable(objectMode: true)
  called = false
  w._write = (chunk, encoding, cb) ->
    assert.equal chunk, "foo"
    process.nextTick ->
      called = true
      cb()
      return

    return

  w.on "finish", ->
    assert.equal called, true
    t.end()
    return

  w.write "foo"
  w.end()
  return

