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
http = require("http")
assert = require("assert")
N = 20
responses = 0
maxQueued = 0
agent = http.globalAgent
agent.maxSockets = 10
server = http.createServer((req, res) ->
  res.writeHead 200
  res.end "Hello World\n"
  return
)
addrString = agent.getName(
  host: "127.0.0.1"
  port: common.PORT
)
server.listen common.PORT, "127.0.0.1", ->
  i = 0

  while i < N
    options =
      host: "127.0.0.1"
      port: common.PORT

    req = http.get(options, (res) ->
      server.close()  if ++responses is N
      res.resume()
      return
    )
    assert.equal req.agent, agent
    console.log "Socket: " + agent.sockets[addrString].length + "/" + agent.maxSockets + " queued: " + ((if agent.requests[addrString] then agent.requests[addrString].length else 0))
    agentRequests = (if agent.requests[addrString] then agent.requests[addrString].length else 0)
    maxQueued = agentRequests  if maxQueued < agentRequests
    i++
  return

process.on "exit", ->
  assert.ok responses is N
  assert.ok maxQueued <= 10
  return

