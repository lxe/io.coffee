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
runTest = (highWaterMark, objectMode, produce) ->
  flow = ->
    flowing = true
    while flowing and chunks-- > 0
      item = produce()
      expected.push item
      console.log "old.emit", chunks, flowing
      old.emit "data", item
      console.log "after emit", chunks, flowing
    if chunks <= 0
      oldEnded = true
      console.log "old end", chunks, flowing
      old.emit "end"
    return
  performAsserts = ->
    assert ended
    assert oldEnded
    assert.deepEqual written, expected
    return
  testRuns++
  old = new EE
  r = new Readable(
    highWaterMark: highWaterMark
    objectMode: objectMode
  )
  assert.equal r, r.wrap(old)
  ended = false
  r.on "end", ->
    ended = true
    return

  old.pause = ->
    console.error "old.pause()"
    old.emit "pause"
    flowing = false
    return

  old.resume = ->
    console.error "old.resume()"
    old.emit "resume"
    flow()
    return

  flowing = undefined
  chunks = 10
  oldEnded = false
  expected = []
  w = new Writable(
    highWaterMark: highWaterMark * 2
    objectMode: objectMode
  )
  written = []
  w._write = (chunk, encoding, cb) ->
    console.log "_write", chunk
    written.push chunk
    setTimeout cb
    return

  w.on "finish", ->
    completedRuns++
    performAsserts()
    return

  r.pipe w
  flow()
  return
common = require("../common")
assert = require("assert")
Readable = require("_stream_readable")
Writable = require("_stream_writable")
EE = require("events").EventEmitter
testRuns = 0
completedRuns = 0
runTest 100, false, ->
  new Buffer(100)

runTest 10, false, ->
  new Buffer("xxxxxxxxxx")

runTest 1, true, ->
  foo: "bar"

objectChunks = [
  5
  "a"
  false
  0
  ""
  "xyz"
  {
    x: 4
  }
  7
  []
  555
]
runTest 1, true, ->
  objectChunks.shift()

process.on "exit", ->
  assert.equal testRuns, completedRuns
  console.log "ok"
  return

