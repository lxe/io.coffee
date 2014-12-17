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

# If everything aligns so that you do a read(n) of exactly the
# remaining buffer, then make sure that 'end' still emits.
push = ->
  return  if pushes > PUSHCOUNT
  if pushes++ is PUSHCOUNT
    console.error "   push(EOF)"
    return r.push(null)
  console.error "   push #%d", pushes
  setTimeout push  if r.push(new Buffer(PUSHSIZE))
  return
common = require("../common.js")
assert = require("assert")
READSIZE = 100
PUSHSIZE = 20
PUSHCOUNT = 1000
HWM = 50
Readable = require("stream").Readable
r = new Readable(highWaterMark: HWM)
rs = r._readableState
r._read = push
r.on "readable", ->
  console.error ">> readable"
  loop
    console.error "  > read(%d)", READSIZE
    ret = r.read(READSIZE)
    console.error "  < %j (%d remain)", ret and ret.length, rs.length
    break unless ret and ret.length is READSIZE
  console.error "<< after read()", ret and ret.length, rs.needReadable, rs.length
  return

endEmitted = false
r.on "end", ->
  endEmitted = true
  console.error "end"
  return

pushes = 0

# start the flow
ret = r.read(0)
process.on "exit", ->
  assert.equal pushes, PUSHCOUNT + 1
  assert endEmitted
  return

