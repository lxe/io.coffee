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

# See test/simple/test-sendfd.js for a complete description of what this
# script is doing and how it fits into the test as a whole.
processData = (s) ->
  return  if receivedData.length is 0 or receivedFDs.length is 0
  fd = receivedFDs.shift()
  d = receivedData.shift()
  
  # Augment our received object before sending it back across the pipe.
  d.pid = process.pid
  
  # Create a stream around the FD that we received and send a serialized
  # version of our modified object back. Clean up when we're done.
  pipeStream = new net.Stream(fd)
  drainFunc = ->
    pipeStream.destroy()
    s.destroy()  if ++numSentMessages is 2
    return

  pipeStream.on "drain", drainFunc
  pipeStream.resume()
  drainFunc()  if pipeStream.write(JSON.stringify(d) + "\n")
  return
net = require("net")
receivedData = []
receivedFDs = []
numSentMessages = 0

# Create a UNIX socket to the path defined by argv[2] and read a file
# descriptor and misc data from it.
s = new net.Stream()
s.on "fd", (fd) ->
  receivedFDs.unshift fd
  processData s
  return

s.on "data", (data) ->
  data.toString("utf8").trim().split("\n").forEach (d) ->
    receivedData.unshift JSON.parse(d)
    return

  processData s
  return

s.connect process.argv[2]

# vim:ts=2 sw=2 et
