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

# This test verifies that stream.unshift(Buffer(0)) or 
# stream.unshift('') does not set state.reading=false.
Readable = require("stream").Readable
r = new Readable()
nChunks = 10
chunk = new Buffer(10)
chunk.fill "x"
r._read = (n) ->
  setTimeout ->
    r.push (if --nChunks is 0 then null else chunk)
    return

  return

readAll = false
seen = []
r.on "readable", ->
  chunk = undefined
  while chunk = r.read()
    seen.push chunk.toString()
    
    # simulate only reading a certain amount of the data,
    # and then putting the rest of the chunk back into the
    # stream, like a parser might do.  We just fill it with
    # 'y' so that it's easy to see which bits were touched,
    # and which were not.
    putBack = new Buffer((if readAll then 0 else 5))
    putBack.fill "y"
    readAll = not readAll
    r.unshift putBack
  return

expect = [
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
  "xxxxxxxxxx"
  "yyyyy"
]
r.on "end", ->
  assert.deepEqual seen, expect
  console.log "ok"
  return

