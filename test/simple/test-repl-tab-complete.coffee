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

# A stream to push an array into a REPL
ArrayStream = ->
  @run = (data) ->
    self = this
    data.forEach (line) ->
      self.emit "data", line + "\n"
      return

    return

  return
common = require("../common")
assert = require("assert")
util = require("util")
repl = require("repl")
util.inherits ArrayStream, require("stream").Stream
ArrayStream::readable = true
ArrayStream::writable = true
ArrayStream::resume = ->

ArrayStream::write = ->

works = [
  ["inner.one"]
  "inner.o"
]
doesNotBreak = [
  []
  "inner.o"
]
putIn = new ArrayStream()
testMe = repl.start("", putIn)

# Tab Complete will not break in an object literal
putIn.run [".clear"]
putIn.run [
  "var inner = {"
  "one:1"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

testMe.complete "console.lo", (error, data) ->
  assert.deepEqual data, [
    ["console.log"]
    "console.lo"
  ]
  return


# Tab Complete will return globaly scoped variables
putIn.run ["};"]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return

putIn.run [".clear"]

# Tab Complete will not break in an ternary operator with ()
putIn.run [
  "var inner = ( true "
  "?"
  "{one: 1} : "
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

putIn.run [".clear"]

# Tab Complete will return a simple local variable
putIn.run [
  "var top = function () {"
  "var inner = {one:1};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return


# When you close the function scope tab complete will not return the
# locally scoped variable
putIn.run ["};"]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

putIn.run [".clear"]

# Tab Complete will return a complex local variable
putIn.run [
  "var top = function () {"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return

putIn.run [".clear"]

# Tab Complete will return a complex local variable even if the function
# has parameters
putIn.run [
  "var top = function (one, two) {"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return

putIn.run [".clear"]

# Tab Complete will return a complex local variable even if the
# scope is nested inside an immediately executed function
putIn.run [
  "var top = function () {"
  "(function test () {"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, works
  return

putIn.run [".clear"]

# currently does not work, but should not break note the inner function
# def has the params and { on a separate line
putIn.run [
  "var top = function () {"
  "r = function test ("
  " one, two) {"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

putIn.run [".clear"]

# currently does not work, but should not break, not the {
putIn.run [
  "var top = function () {"
  "r = function test ()"
  "{"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

putIn.run [".clear"]

# currently does not work, but should not break
putIn.run [
  "var top = function () {"
  "r = function test ("
  ")"
  "{"
  "var inner = {"
  " one:1"
  "};"
]
testMe.complete "inner.o", (error, data) ->
  assert.deepEqual data, doesNotBreak
  return

putIn.run [".clear"]

# make sure tab completion works on non-Objects
putIn.run ["var str = \"test\";"]
testMe.complete "str.len", (error, data) ->
  assert.deepEqual data, [
    ["str.length"]
    "str.len"
  ]
  return

putIn.run [".clear"]

# tab completion should not break on spaces
spaceTimeout = setTimeout(->
  throw new Error("timeout")return
, 1000)
testMe.complete " ", (error, data) ->
  assert.deepEqual data, [
    []
    `undefined`
  ]
  clearTimeout spaceTimeout
  return


# tab completion should pick up the global "toString" object, and
# any other properties up the "global" object's prototype chain
testMe.complete "toSt", (error, data) ->
  assert.deepEqual data, [
    ["toString"]
    "toSt"
  ]
  return


# Tab complete provides built in libs for require()
putIn.run [".clear"]
testMe.complete "require('", (error, data) ->
  assert.strictEqual error, null
  repl._builtinLibs.forEach (lib) ->
    assert.notStrictEqual data[0].indexOf(lib), -1, lib + " not found"
    return

  return

testMe.complete "require('n", (error, data) ->
  assert.strictEqual error, null
  assert.deepEqual data, [
    ["net"]
    "n"
  ]
  return

