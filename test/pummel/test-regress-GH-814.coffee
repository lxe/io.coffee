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

# Flags: --expose_gc
newBuffer = (size, value) ->
  buffer = new Buffer(size)
  buffer[size] = value  while size--
  
  #buffer[buffer.length-2]= 0x0d;
  buffer[buffer.length - 1] = 0x0a
  buffer
#0x2e === '.'
tailCB = (data) ->
  PASS = data.toString().indexOf(".") < 0
  return
#Test during no more than this seconds.
cb = (err, written) ->
  throw err  if err
  return
common = require("../common")
fs = require("fs")
testFileName = require("path").join(common.tmpDir, "GH-814_testFile.txt")
testFileFD = fs.openSync(testFileName, "w")
console.log testFileName
kBufSize = 128 * 1024
PASS = true
neverWrittenBuffer = newBuffer(kBufSize, 0x2e)
bufPool = []
tail = require("child_process").spawn("tail", [
  "-f"
  testFileName
])
tail.stdout.on "data", tailCB
timeToQuit = Date.now() + 8e3
(main = ->
  if PASS
    fs.write testFileFD, newBuffer(kBufSize, 0x61), 0, kBufSize, -1, cb
    gc()
    nuBuf = new Buffer(kBufSize)
    neverWrittenBuffer.copy nuBuf
    bufPool.length = 0  if bufPool.push(nuBuf) > 100
  else
    throw Error("Buffer GC'ed test -> FAIL")
  if Date.now() < timeToQuit
    process.nextTick main
  else
    tail.kill()
    console.log "Buffer GC'ed test -> PASS (OK)"
  return
)()
