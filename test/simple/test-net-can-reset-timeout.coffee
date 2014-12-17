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
net = require("net")
common = require("../common")
assert = require("assert")
timeoutCount = 0
server = net.createServer((stream) ->
  stream.setTimeout 100
  stream.resume()
  stream.on "timeout", ->
    console.log "timeout"
    
    # try to reset the timeout.
    stream.write "WHAT."
    
    # don't worry, the socket didn't *really* time out, we're just thinking
    # it did.
    timeoutCount += 1
    return

  stream.on "end", ->
    console.log "server side end"
    stream.end()
    return

  return
)
server.listen common.PORT, ->
  c = net.createConnection(common.PORT)
  c.on "data", ->
    c.end()
    return

  c.on "end", ->
    console.log "client side end"
    server.close()
    return

  return

process.on "exit", ->
  assert.equal 1, timeoutCount
  return

