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

# They should all come in on the same server socket.
makeRequest = (n) ->
  if n is 0
    server.close()
    agent.destroy()
    return
  req = http.request(
    port: common.PORT
    agent: agent
    path: "/" + n
  )
  req.end()
  req.on "socket", (sock) ->
    if clientSocket
      assert.equal sock, clientSocket
    else
      clientSocket = sock
    return

  req.on "response", (res) ->
    data = ""
    res.setEncoding "utf8"
    res.on "data", (c) ->
      data += c
      return

    res.on "end", ->
      assert.equal data, "/" + n
      setTimeout (->
        actualRequests++
        makeRequest n - 1
        return
      ), 1
      return

    return

  return
common = require("../common")
assert = require("assert")
http = require("http")
serverSocket = null
server = http.createServer((req, res) ->
  if serverSocket
    assert.equal req.socket, serverSocket
  else
    serverSocket = req.socket
  res.end req.url
  return
)
server.listen common.PORT
agent = http.Agent(keepAlive: true)
clientSocket = null
expectRequests = 10
actualRequests = 0
makeRequest expectRequests
process.on "exit", ->
  assert.equal actualRequests, expectRequests
  console.log "ok"
  return

