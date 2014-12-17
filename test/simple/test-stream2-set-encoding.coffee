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

#///
TestReader = (n, opts) ->
  R.call this, opts
  @pos = 0
  @len = n or 100
  return
common = require("../common.js")
assert = require("assert")
R = require("_stream_readable")
util = require("util")
tests = []
count = 0
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run
util.inherits TestReader, R
TestReader::_read = (n) ->
  
  # double push(null) to test eos handling
  
  # double push(null) to test eos handling
  setTimeout (->
    if @pos >= @len
      @push null
      return @push(null)
    n = Math.min(n, @len - @pos)
    if n <= 0
      @push null
      return @push(null)
    @pos += n
    ret = new Buffer(n)
    ret.fill "a"
    console.log "this.push(ret)", ret
    @push ret
  ).bind(this), 1
  return

test "setEncoding utf8", (t) ->
  tr = new TestReader(100)
  tr.setEncoding "utf8"
  out = []
  expect = [
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "setEncoding hex", (t) ->
  tr = new TestReader(100)
  tr.setEncoding "hex"
  out = []
  expect = [
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "setEncoding hex with read(13)", (t) ->
  tr = new TestReader(100)
  tr.setEncoding "hex"
  out = []
  expect = [
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "16161"
  ]
  tr.on "readable", flow = ->
    console.log "readable once"
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(13))
    return

  tr.on "end", ->
    console.log "END"
    t.same out, expect
    t.end()
    return

  return

test "setEncoding base64", (t) ->
  tr = new TestReader(100)
  tr.setEncoding "base64"
  out = []
  expect = [
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYQ=="
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "encoding: utf8", (t) ->
  tr = new TestReader(100,
    encoding: "utf8"
  )
  out = []
  expect = [
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
    "aaaaaaaaaa"
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "encoding: hex", (t) ->
  tr = new TestReader(100,
    encoding: "hex"
  )
  out = []
  expect = [
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
    "6161616161"
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "encoding: hex with read(13)", (t) ->
  tr = new TestReader(100,
    encoding: "hex"
  )
  out = []
  expect = [
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "1616161616161"
    "6161616161616"
    "16161"
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(13))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "encoding: base64", (t) ->
  tr = new TestReader(100,
    encoding: "base64"
  )
  out = []
  expect = [
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYWFhYWFh"
    "YWFhYWFhYW"
    "FhYQ=="
  ]
  tr.on "readable", flow = ->
    chunk = undefined
    out.push chunk  while null isnt (chunk = tr.read(10))
    return

  tr.on "end", ->
    t.same out, expect
    t.end()
    return

  return

test "chainable", (t) ->
  tr = new TestReader(100)
  t.equal tr.setEncoding("utf8"), tr
  t.end()
  return

