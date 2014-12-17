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

# make 10 requests in parallel,
# then 10 more when they all finish.
makeReqs = (n, cb) ->
  then = (er) ->
    if er
      cb er
    else setTimeout cb, 100  if --n is 0
    return
  i = 0

  while i < n
    makeReq i, then_
    i++
  return
makeReq = (i, cb) ->
  http.request(
    port: common.PORT
    path: "/" + i
    agent: agent
  , (res) ->
    data = ""
    res.setEncoding "ascii"
    res.on "data", (c) ->
      data += c
      return

    res.on "end", ->
      assert.equal data, "/" + i
      cb()
      return

    return
  ).end()
  return

# now make 10 more reqs.
# should use the 2 free reqs from the pool first.
count = (sockets) ->
  Object.keys(sockets).reduce ((n, name) ->
    n + sockets[name].length
  ), 0
common = require("../common")
assert = require("assert")
http = require("http")
serverSockets = []
server = http.createServer((req, res) ->
  serverSockets.push req.socket  if serverSockets.indexOf(req.socket) is -1
  res.end req.url
  return
)
server.listen common.PORT
agent = http.Agent(
  keepAlive: true
  maxSockets: 5
  maxFreeSockets: 2
)
closed = false
makeReqs 10, (er) ->
  assert.ifError er
  assert.equal count(agent.freeSockets), 2
  assert.equal count(agent.sockets), 0
  assert.equal serverSockets.length, 5
  makeReqs 10, (er) ->
    assert.ifError er
    assert.equal count(agent.freeSockets), 2
    assert.equal count(agent.sockets), 0
    assert.equal serverSockets.length, 8
    agent.destroy()
    server.close ->
      closed = true
      return

    return

  return

process.on "exit", ->
  assert closed
  console.log "ok"
  return

