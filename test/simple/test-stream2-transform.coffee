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
    ok: assert
    end: ->
      count--
      run()
      return

  return
assert = require("assert")
common = require("../common.js")
PassThrough = require("_stream_passthrough")
Transform = require("_stream_transform")
tests = []
count = 0

# ensure all tests have run
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run

#///
test "writable side consumption", (t) ->
  tx = new Transform(highWaterMark: 10)
  transformed = 0
  tx._transform = (chunk, encoding, cb) ->
    transformed += chunk.length
    tx.push chunk
    cb()
    return

  i = 1

  while i <= 10
    tx.write new Buffer(i)
    i++
  tx.end()
  t.equal tx._readableState.length, 10
  t.equal transformed, 10
  t.equal tx._transformState.writechunk.length, 5
  t.same tx._writableState.buffer.map((c) ->
    c.chunk.length
  ), [
    6
    7
    8
    9
    10
  ]
  t.end()
  return

test "passthrough", (t) ->
  pt = new PassThrough()
  pt.write new Buffer("foog")
  pt.write new Buffer("bark")
  pt.write new Buffer("bazy")
  pt.write new Buffer("kuel")
  pt.end()
  t.equal pt.read(5).toString(), "foogb"
  t.equal pt.read(5).toString(), "arkba"
  t.equal pt.read(5).toString(), "zykue"
  t.equal pt.read(5).toString(), "l"
  t.end()
  return

test "object passthrough", (t) ->
  pt = new PassThrough(objectMode: true)
  pt.write 1
  pt.write true
  pt.write false
  pt.write 0
  pt.write "foo"
  pt.write ""
  pt.write a: "b"
  pt.end()
  t.equal pt.read(), 1
  t.equal pt.read(), true
  t.equal pt.read(), false
  t.equal pt.read(), 0
  t.equal pt.read(), "foo"
  t.equal pt.read(), ""
  t.same pt.read(),
    a: "b"

  t.end()
  return

test "simple transform", (t) ->
  pt = new Transform
  pt._transform = (c, e, cb) ->
    ret = new Buffer(c.length)
    ret.fill "x"
    pt.push ret
    cb()
    return

  pt.write new Buffer("foog")
  pt.write new Buffer("bark")
  pt.write new Buffer("bazy")
  pt.write new Buffer("kuel")
  pt.end()
  t.equal pt.read(5).toString(), "xxxxx"
  t.equal pt.read(5).toString(), "xxxxx"
  t.equal pt.read(5).toString(), "xxxxx"
  t.equal pt.read(5).toString(), "x"
  t.end()
  return

test "simple object transform", (t) ->
  pt = new Transform(objectMode: true)
  pt._transform = (c, e, cb) ->
    pt.push JSON.stringify(c)
    cb()
    return

  pt.write 1
  pt.write true
  pt.write false
  pt.write 0
  pt.write "foo"
  pt.write ""
  pt.write a: "b"
  pt.end()
  t.equal pt.read(), "1"
  t.equal pt.read(), "true"
  t.equal pt.read(), "false"
  t.equal pt.read(), "0"
  t.equal pt.read(), "\"foo\""
  t.equal pt.read(), "\"\""
  t.equal pt.read(), "{\"a\":\"b\"}"
  t.end()
  return

test "async passthrough", (t) ->
  pt = new Transform
  pt._transform = (chunk, encoding, cb) ->
    setTimeout (->
      pt.push chunk
      cb()
      return
    ), 10
    return

  pt.write new Buffer("foog")
  pt.write new Buffer("bark")
  pt.write new Buffer("bazy")
  pt.write new Buffer("kuel")
  pt.end()
  pt.on "finish", ->
    t.equal pt.read(5).toString(), "foogb"
    t.equal pt.read(5).toString(), "arkba"
    t.equal pt.read(5).toString(), "zykue"
    t.equal pt.read(5).toString(), "l"
    t.end()
    return

  return

test "assymetric transform (expand)", (t) ->
  pt = new Transform
  
  # emit each chunk 2 times.
  pt._transform = (chunk, encoding, cb) ->
    setTimeout (->
      pt.push chunk
      setTimeout (->
        pt.push chunk
        cb()
        return
      ), 10
      return
    ), 10
    return

  pt.write new Buffer("foog")
  pt.write new Buffer("bark")
  pt.write new Buffer("bazy")
  pt.write new Buffer("kuel")
  pt.end()
  pt.on "finish", ->
    t.equal pt.read(5).toString(), "foogf"
    t.equal pt.read(5).toString(), "oogba"
    t.equal pt.read(5).toString(), "rkbar"
    t.equal pt.read(5).toString(), "kbazy"
    t.equal pt.read(5).toString(), "bazyk"
    t.equal pt.read(5).toString(), "uelku"
    t.equal pt.read(5).toString(), "el"
    t.end()
    return

  return

test "assymetric transform (compress)", (t) ->
  pt = new Transform
  
  # each output is the first char of 3 consecutive chunks,
  # or whatever's left.
  pt.state = ""
  pt._transform = (chunk, encoding, cb) ->
    chunk = ""  unless chunk
    s = chunk.toString()
    setTimeout (->
      @state += s.charAt(0)
      if @state.length is 3
        pt.push new Buffer(@state)
        @state = ""
      cb()
      return
    ).bind(this), 10
    return

  pt._flush = (cb) ->
    
    # just output whatever we have.
    pt.push new Buffer(@state)
    @state = ""
    cb()
    return

  pt.write new Buffer("aaaa")
  pt.write new Buffer("bbbb")
  pt.write new Buffer("cccc")
  pt.write new Buffer("dddd")
  pt.write new Buffer("eeee")
  pt.write new Buffer("aaaa")
  pt.write new Buffer("bbbb")
  pt.write new Buffer("cccc")
  pt.write new Buffer("dddd")
  pt.write new Buffer("eeee")
  pt.write new Buffer("aaaa")
  pt.write new Buffer("bbbb")
  pt.write new Buffer("cccc")
  pt.write new Buffer("dddd")
  pt.end()
  
  # 'abcdeabcdeabcd'
  pt.on "finish", ->
    t.equal pt.read(5).toString(), "abcde"
    t.equal pt.read(5).toString(), "abcde"
    t.equal pt.read(5).toString(), "abcd"
    t.end()
    return

  return


# this tests for a stall when data is written to a full stream
# that has empty transforms.
test "complex transform", (t) ->
  count = 0
  saved = null
  pt = new Transform(highWaterMark: 3)
  pt._transform = (c, e, cb) ->
    if count++ is 1
      saved = c
    else
      if saved
        pt.push saved
        saved = null
      pt.push c
    cb()
    return

  pt.once "readable", ->
    process.nextTick ->
      pt.write new Buffer("d")
      pt.write new Buffer("ef"), ->
        pt.end()
        t.end()
        return

      t.equal pt.read().toString(), "abcdef"
      t.equal pt.read(), null
      return

    return

  pt.write new Buffer("abc")
  return

test "passthrough event emission", (t) ->
  pt = new PassThrough()
  emits = 0
  pt.on "readable", ->
    state = pt._readableState
    console.error ">>> emit readable %d", emits
    emits++
    return

  i = 0
  pt.write new Buffer("foog")
  console.error "need emit 0"
  pt.write new Buffer("bark")
  console.error "should have emitted readable now 1 === %d", emits
  t.equal emits, 1
  t.equal pt.read(5).toString(), "foogb"
  t.equal pt.read(5) + "", "null"
  console.error "need emit 1"
  pt.write new Buffer("bazy")
  console.error "should have emitted, but not again"
  pt.write new Buffer("kuel")
  console.error "should have emitted readable now 2 === %d", emits
  t.equal emits, 2
  t.equal pt.read(5).toString(), "arkba"
  t.equal pt.read(5).toString(), "zykue"
  t.equal pt.read(5), null
  console.error "need emit 2"
  pt.end()
  t.equal emits, 3
  t.equal pt.read(5).toString(), "l"
  t.equal pt.read(5), null
  console.error "should not have emitted again"
  t.equal emits, 3
  t.end()
  return

test "passthrough event emission reordered", (t) ->
  pt = new PassThrough
  emits = 0
  pt.on "readable", ->
    console.error "emit readable", emits
    emits++
    return

  pt.write new Buffer("foog")
  console.error "need emit 0"
  pt.write new Buffer("bark")
  console.error "should have emitted readable now 1 === %d", emits
  t.equal emits, 1
  t.equal pt.read(5).toString(), "foogb"
  t.equal pt.read(5), null
  console.error "need emit 1"
  pt.once "readable", ->
    t.equal pt.read(5).toString(), "arkba"
    t.equal pt.read(5), null
    console.error "need emit 2"
    pt.once "readable", ->
      t.equal pt.read(5).toString(), "zykue"
      t.equal pt.read(5), null
      pt.once "readable", ->
        t.equal pt.read(5).toString(), "l"
        t.equal pt.read(5), null
        t.equal emits, 4
        t.end()
        return

      pt.end()
      return

    pt.write new Buffer("kuel")
    return

  pt.write new Buffer("bazy")
  return

test "passthrough facaded", (t) ->
  console.error "passthrough facaded"
  pt = new PassThrough
  datas = []
  pt.on "data", (chunk) ->
    datas.push chunk.toString()
    return

  pt.on "end", ->
    t.same datas, [
      "foog"
      "bark"
      "bazy"
      "kuel"
    ]
    t.end()
    return

  pt.write new Buffer("foog")
  setTimeout (->
    pt.write new Buffer("bark")
    setTimeout (->
      pt.write new Buffer("bazy")
      setTimeout (->
        pt.write new Buffer("kuel")
        setTimeout (->
          pt.end()
          return
        ), 10
        return
      ), 10
      return
    ), 10
    return
  ), 10
  return

test "object transform (json parse)", (t) ->
  console.error "json parse stream"
  jp = new Transform(objectMode: true)
  jp._transform = (data, encoding, cb) ->
    try
      jp.push JSON.parse(data)
      cb()
    catch er
      cb er
    return

  
  # anything except null/undefined is fine.
  # those are "magic" in the stream API, because they signal EOF.
  objects = [
    {
      foo: "bar"
    }
    100
    "string"
    {
      nested:
        things: [
          {
            foo: "bar"
          }
          100
          "string"
        ]
    }
  ]
  ended = false
  jp.on "end", ->
    ended = true
    return

  objects.forEach (obj) ->
    jp.write JSON.stringify(obj)
    res = jp.read()
    t.same res, obj
    return

  jp.end()
  
  # read one more time to get the 'end' event
  jp.read()
  process.nextTick ->
    t.ok ended
    t.end()
    return

  return

test "object transform (json stringify)", (t) ->
  console.error "json parse stream"
  js = new Transform(objectMode: true)
  js._transform = (data, encoding, cb) ->
    try
      js.push JSON.stringify(data)
      cb()
    catch er
      cb er
    return

  
  # anything except null/undefined is fine.
  # those are "magic" in the stream API, because they signal EOF.
  objects = [
    {
      foo: "bar"
    }
    100
    "string"
    {
      nested:
        things: [
          {
            foo: "bar"
          }
          100
          "string"
        ]
    }
  ]
  ended = false
  js.on "end", ->
    ended = true
    return

  objects.forEach (obj) ->
    js.write obj
    res = js.read()
    t.equal res, JSON.stringify(obj)
    return

  js.end()
  
  # read one more time to get the 'end' event
  js.read()
  process.nextTick ->
    t.ok ended
    t.end()
    return

  return

