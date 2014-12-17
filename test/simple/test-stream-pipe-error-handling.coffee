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
common = require("../common")
assert = require("assert")
Stream = require("stream").Stream
(testErrorListenerCatches = ->
  source = new Stream()
  dest = new Stream()
  source.pipe dest
  gotErr = null
  source.on "error", (err) ->
    gotErr = err
    return

  err = new Error("This stream turned into bacon.")
  source.emit "error", err
  assert.strictEqual gotErr, err
  return
)()
(testErrorWithoutListenerThrows = ->
  source = new Stream()
  dest = new Stream()
  source.pipe dest
  err = new Error("This stream turned into bacon.")
  gotErr = null
  try
    source.emit "error", err
  catch e
    gotErr = e
  assert.strictEqual gotErr, err
  return
)()
(testErrorWithRemovedListenerThrows = ->
  myOnError = (er) ->
    throw new Error("this should not happen")return
  EE = require("events").EventEmitter
  R = Stream.Readable
  W = Stream.Writable
  r = new R
  w = new W
  removed = false
  didTest = false
  process.on "exit", ->
    assert didTest
    console.log "ok"
    return

  r._read = ->
    setTimeout ->
      assert removed
      assert.throws ->
        w.emit "error", new Error("fail")
        return

      didTest = true
      return

    return

  w.on "error", myOnError
  r.pipe w
  w.removeListener "error", myOnError
  removed = true
  return
)()
(testErrorWithRemovedListenerThrows = ->
  
  # Removing some OTHER random listener should not do anything
  myOnError = (er) ->
    assert not caught
    caught = true
    return
  EE = require("events").EventEmitter
  R = Stream.Readable
  W = Stream.Writable
  r = new R
  w = new W
  removed = false
  didTest = false
  caught = false
  process.on "exit", ->
    assert didTest
    console.log "ok"
    return

  r._read = ->
    setTimeout ->
      assert removed
      w.emit "error", new Error("fail")
      didTest = true
      return

    return

  w.on "error", myOnError
  w._write = ->

  r.pipe w
  w.removeListener "error", ->

  removed = true
  return
)()
