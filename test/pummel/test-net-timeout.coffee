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
net = require("net")
exchanges = 0
starttime = null
timeouttime = null
timeout = 1000
echo_server = net.createServer((socket) ->
  socket.setTimeout timeout
  socket.on "timeout", ->
    console.log "server timeout"
    timeouttime = new Date
    console.dir timeouttime
    socket.destroy()
    return

  socket.on "error", (e) ->
    throw new Error("Server side socket should not get error. " + "We disconnect willingly.")return

  socket.on "data", (d) ->
    console.log d
    socket.write d
    return

  socket.on "end", ->
    socket.end()
    return

  return
)
echo_server.listen common.PORT, ->
  console.log "server listening at " + common.PORT
  client = net.createConnection(common.PORT)
  client.setEncoding "UTF8"
  client.setTimeout 0 # disable the timeout for client
  client.on "connect", ->
    console.log "client connected."
    client.write "hello\r\n"
    return

  client.on "data", (chunk) ->
    assert.equal "hello\r\n", chunk
    if exchanges++ < 5
      setTimeout (->
        console.log "client write \"hello\""
        client.write "hello\r\n"
        return
      ), 500
      if exchanges is 5
        console.log "wait for timeout - should come in " + timeout + " ms"
        starttime = new Date
        console.dir starttime
    return

  client.on "timeout", ->
    throw new Error("client timeout - this shouldn't happen")return

  client.on "end", ->
    console.log "client end"
    client.end()
    return

  client.on "close", ->
    console.log "client disconnect"
    echo_server.close()
    return

  return

process.on "exit", ->
  assert.ok starttime?
  assert.ok timeouttime?
  diff = timeouttime - starttime
  console.log "diff = " + diff
  assert.ok timeout < diff
  
  # Allow for 800 milliseconds more
  assert.ok diff < timeout + 800
  return

