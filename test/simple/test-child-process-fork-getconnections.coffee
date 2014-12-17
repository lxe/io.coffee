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
assert = require("assert")
common = require("../common")
fork = require("child_process").fork
net = require("net")
count = 12
if process.argv[2] is "child"
  sockets = []
  id = process.argv[3]
  process.on "message", (m, socket) ->
    if m.cmd is "new"
      assert socket
      assert socket instanceof net.Socket, "should be a net.Socket"
      sockets.push socket
      socket.on "end", ->
        throw new Error("[c] closing by accident!")  unless @closingOnPurpose
        return

    if m.cmd is "close"
      assert.equal socket, `undefined`
      sockets[m.id].once "close", ->
        process.send
          id: m.id
          status: "closed"

        return

      sockets[m.id].destroy()
    return

else
  closeSockets = (i) ->
    if i is count
      childKilled = true
      server.close()
      child.kill()
      return
    sent++
    child.send
      id: i
      cmd: "close"

    child.once "message", (m) ->
      assert m.status is "closed"
      server.getConnections (err, num) ->
        closeSockets i + 1
        return

      return

    return
  child = fork(process.argv[1], ["child"])
  child.on "exit", (code, signal) ->
    throw new Error("child died unexpectedly!")  unless childKilled
    return

  server = net.createServer()
  sockets = []
  sent = 0
  server.on "connection", (socket) ->
    child.send
      cmd: "new"
    , socket,
      track: false

    sockets.push socket
    closeSockets 0  if sockets.length is count
    return

  disconnected = 0
  clients = []
  server.on "listening", ->
    j = count
    client = undefined
    while j--
      client = net.connect(common.PORT, "127.0.0.1")
      client.id = j
      client.on "close", ->
        disconnected += 1
        return

      clients.push client
    return

  childKilled = false
  closeEmitted = false
  server.on "close", ->
    closeEmitted = true
    return

  server.listen common.PORT, "127.0.0.1"
  process.on "exit", ->
    assert.equal sent, count
    assert.equal disconnected, count
    assert.ok closeEmitted
    console.log "ok"
    return

