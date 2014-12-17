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
stream = require("stream")
(testErrorListenerCatches = ->
  count = 1000
  source = new stream.Readable()
  source._read = (n) ->
    n = Math.min(count, n)
    count -= n
    source.push new Buffer(n)
    return

  unpipedDest = undefined
  source.unpipe = (dest) ->
    unpipedDest = dest
    stream.Readable::unpipe.call this, dest
    return

  dest = new stream.Writable()
  dest._write = (chunk, encoding, cb) ->
    cb()
    return

  source.pipe dest
  gotErr = null
  dest.on "error", (err) ->
    gotErr = err
    return

  unpipedSource = undefined
  dest.on "unpipe", (src) ->
    unpipedSource = src
    return

  err = new Error("This stream turned into bacon.")
  dest.emit "error", err
  assert.strictEqual gotErr, err
  assert.strictEqual unpipedSource, source
  assert.strictEqual unpipedDest, dest
  return
)()
(testErrorWithoutListenerThrows = ->
  count = 1000
  source = new stream.Readable()
  source._read = (n) ->
    n = Math.min(count, n)
    count -= n
    source.push new Buffer(n)
    return

  unpipedDest = undefined
  source.unpipe = (dest) ->
    unpipedDest = dest
    stream.Readable::unpipe.call this, dest
    return

  dest = new stream.Writable()
  dest._write = (chunk, encoding, cb) ->
    cb()
    return

  source.pipe dest
  unpipedSource = undefined
  dest.on "unpipe", (src) ->
    unpipedSource = src
    return

  err = new Error("This stream turned into bacon.")
  gotErr = null
  try
    dest.emit "error", err
  catch e
    gotErr = e
  assert.strictEqual gotErr, err
  assert.strictEqual unpipedSource, source
  assert.strictEqual unpipedDest, dest
  return
)()
