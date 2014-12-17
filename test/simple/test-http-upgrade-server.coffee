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
createTestServer = ->
  new testServer()
testServer = ->
  server = this
  http.Server.call server, ->

  server.on "connection", ->
    requests_recv++
    return

  server.on "request", (req, res) ->
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write "okay"
    res.end()
    return

  server.on "upgrade", (req, socket, upgradeHead) ->
    socket.write "HTTP/1.1 101 Web Socket Protocol Handshake\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "\r\n\r\n"
    request_upgradeHead = upgradeHead
    socket.on "data", (d) ->
      data = d.toString("utf8")
      if data is "kill"
        socket.end()
      else
        socket.write data, "utf8"
      return

    return

  return
writeReq = (socket, data, encoding) ->
  requests_sent++
  socket.write data
  return

#-----------------------------------------------
#  connection: Upgrade with listener
#-----------------------------------------------
test_upgrade_with_listener = (_server) ->
  conn = net.createConnection(common.PORT)
  conn.setEncoding "utf8"
  state = 0
  conn.on "connect", ->
    writeReq conn, "GET / HTTP/1.1\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "\r\n" + "WjN}|M(6"
    return

  conn.on "data", (data) ->
    state++
    assert.equal "string", typeof data
    if state is 1
      assert.equal "HTTP/1.1 101", data.substr(0, 12)
      assert.equal "WjN}|M(6", request_upgradeHead.toString("utf8")
      conn.write "test", "utf8"
    else if state is 2
      assert.equal "test", data
      conn.write "kill", "utf8"
    return

  conn.on "end", ->
    assert.equal 2, state
    conn.end()
    _server.removeAllListeners "upgrade"
    test_upgrade_no_listener()
    return

  return

#-----------------------------------------------
#  connection: Upgrade, no listener
#-----------------------------------------------
test_upgrade_no_listener = ->
  conn = net.createConnection(common.PORT)
  conn.setEncoding "utf8"
  conn.on "connect", ->
    writeReq conn, "GET / HTTP/1.1\r\n" + "Upgrade: WebSocket\r\n" + "Connection: Upgrade\r\n" + "\r\n"
    return

  conn.on "end", ->
    test_upgrade_no_listener_ended = true
    conn.end()
    return

  conn.on "close", ->
    test_standard_http()
    return

  return

#-----------------------------------------------
#  connection: normal
#-----------------------------------------------
test_standard_http = ->
  conn = net.createConnection(common.PORT)
  conn.setEncoding "utf8"
  conn.on "connect", ->
    writeReq conn, "GET / HTTP/1.1\r\n\r\n"
    return

  conn.once "data", (data) ->
    assert.equal "string", typeof data
    assert.equal "HTTP/1.1 200", data.substr(0, 12)
    conn.end()
    return

  conn.on "close", ->
    server.close()
    return

  return
common = require("../common")
assert = require("assert")
util = require("util")
net = require("net")
http = require("http")
requests_recv = 0
requests_sent = 0
request_upgradeHead = null
util.inherits testServer, http.Server
test_upgrade_no_listener_ended = false
server = createTestServer()
server.listen common.PORT, ->
  
  # All tests get chained after this:
  test_upgrade_with_listener server
  return


#-----------------------------------------------
#  Fin.
#-----------------------------------------------
process.on "exit", ->
  assert.equal 3, requests_recv
  assert.equal 3, requests_sent
  assert.ok test_upgrade_no_listener_ended
  return

