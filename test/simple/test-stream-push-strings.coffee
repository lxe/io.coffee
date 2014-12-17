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
MyStream = (options) ->
  Readable.call this, options
  @_chunks = 3
  return
common = require("../common")
assert = require("assert")
Readable = require("stream").Readable
util = require("util")
util.inherits MyStream, Readable
MyStream::_read = (n) ->
  switch @_chunks--
    when 0
      @push null
    when 1
      setTimeout (->
        @push "last chunk"
        return
      ).bind(this), 100
    when 2
      @push "second to last chunk"
    when 3
      process.nextTick (->
        @push "first chunk"
        return
      ).bind(this)
    else
      throw new Error("?")
  return

ms = new MyStream()
results = []
ms.on "readable", ->
  chunk = undefined
  results.push chunk + ""  while null isnt (chunk = ms.read())
  return

expect = [
  "first chunksecond to last chunk"
  "last chunk"
]
process.on "exit", ->
  assert.equal ms._chunks, -1
  assert.deepEqual results, expect
  console.log "ok"
  return

