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
run = ->
  t = queue.pop()
  if t
    test t[0], t[1], t[2], run
  else
    console.log "ok"
  return
test = (decode, uncork, multi, next) ->
  cnt = (msg) ->
    expectCount++
    expect = expectCount
    called = false
    (er) ->
      throw er  if er
      called = true
      counter++
      assert.equal counter, expect
      return
  console.log "# decode=%j uncork=%j multi=%j", decode, uncork, multi
  counter = 0
  expectCount = 0
  w = new stream.Writable(decodeStrings: decode)
  w._write = (chunk, e, cb) ->
    assert false, "Should not call _write"
    return

  expectChunks = (if decode then [
    {
      encoding: "buffer"
      chunk: [
        104
        101
        108
        108
        111
        44
        32
      ]
    }
    {
      encoding: "buffer"
      chunk: [
        119
        111
        114
        108
        100
      ]
    }
    {
      encoding: "buffer"
      chunk: [33]
    }
    {
      encoding: "buffer"
      chunk: [
        10
        97
        110
        100
        32
        116
        104
        101
        110
        46
        46
        46
      ]
    }
    {
      encoding: "buffer"
      chunk: [
        250
        206
        190
        167
        222
        173
        190
        239
        222
        202
        251
        173
      ]
    }
  ] else [
    {
      encoding: "ascii"
      chunk: "hello, "
    }
    {
      encoding: "utf8"
      chunk: "world"
    }
    {
      encoding: "buffer"
      chunk: [33]
    }
    {
      encoding: "binary"
      chunk: "\nand then..."
    }
    {
      encoding: "hex"
      chunk: "facebea7deadbeefdecafbad"
    }
  ])
  actualChunks = undefined
  w._writev = (chunks, cb) ->
    actualChunks = chunks.map((chunk) ->
      encoding: chunk.encoding
      chunk: (if Buffer.isBuffer(chunk.chunk) then Array::slice.call(chunk.chunk) else chunk.chunk)
    )
    cb()
    return

  w.cork()
  w.write "hello, ", "ascii", cnt("hello")
  w.write "world", "utf8", cnt("world")
  w.cork()  if multi
  w.write new Buffer("!"), "buffer", cnt("!")
  w.write "\nand then...", "binary", cnt("and then")
  w.uncork()  if multi
  w.write "facebea7deadbeefdecafbad", "hex", cnt("hex")
  w.uncork()  if uncork
  w.end cnt("end")
  w.on "finish", ->
    
    # make sure finish comes after all the write cb
    cnt("finish")()
    assert.deepEqual expectChunks, actualChunks
    next()
    return

  return
common = require("../common")
assert = require("assert")
stream = require("stream")
queue = []
decode = 0

while decode < 2
  uncork = 0

  while uncork < 2
    multi = 0

    while multi < 2
      queue.push [
        !!decode
        !!uncork
        !!multi
      ]
      multi++
    uncork++
  decode++
run()
