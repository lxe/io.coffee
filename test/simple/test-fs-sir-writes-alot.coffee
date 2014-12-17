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

# might not exist, that's okay.

# Create a new buffer for each write. Before the write is actually
# executed by the thread pool, the buffer will be collected.
testBuffer = (b) ->
  i = 0

  while i < b.length
    bytesChecked++
    throw new Error("invalid char " + i + "," + b[i])  if b[i] isnt "a".charCodeAt(0) and b[i] isnt "\n".charCodeAt(0)
    i++
  return
common = require("../common")
fs = require("fs")
assert = require("assert")
join = require("path").join
filename = join(common.tmpDir, "out.txt")
try
  fs.unlinkSync filename
fd = fs.openSync(filename, "w")
line = "aaaaaaaaaaaaaaaaaaaaaaaaaaaa\n"
N = 10240
complete = 0
i = 0

while i < N
  buffer = new Buffer(line)
  fs.write fd, buffer, 0, buffer.length, null, (er, written) ->
    complete++
    if complete is N
      fs.closeSync fd
      s = fs.createReadStream(filename)
      s.on "data", testBuffer
    return

  i++
bytesChecked = 0
process.on "exit", ->
  
  # Probably some of the writes are going to overlap, so we can't assume
  # that we get (N * line.length). Let's just make sure we've checked a
  # few...
  assert.ok bytesChecked > 1000
  return

