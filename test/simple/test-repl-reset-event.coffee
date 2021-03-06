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

# create a dummy stream that does nothing
testReset = (cb) ->
  r = repl.start(
    input: dummy
    output: dummy
    useGlobal: false
  )
  r.context.foo = 42
  r.on "reset", (context) ->
    assert !!context, "REPL did not emit a context with reset event"
    assert.equal context, r.context, "REPL emitted incorrect context"
    assert.equal context.foo, `undefined`, "REPL emitted the previous context, and is not using global as context"
    context.foo = 42
    cb()
    return

  r.resetContext()
  return
testResetGlobal = (cb) ->
  r = repl.start(
    input: dummy
    output: dummy
    useGlobal: true
  )
  r.context.foo = 42
  r.on "reset", (context) ->
    assert.equal context.foo, 42, "\"foo\" property is missing from REPL using global as context"
    cb()
    return

  r.resetContext()
  return
common = require("../common")
common.globalCheck = false
assert = require("assert")
repl = require("repl")
Stream = require("stream")
dummy = new Stream()
dummy.write = dummy.pause = dummy.resume = ->

dummy.readable = dummy.writable = true
timeout = setTimeout(->
  assert.fail "Timeout, REPL did not emit reset events"
  return
, 5000)
testReset ->
  testResetGlobal ->
    clearTimeout timeout
    return

  return

