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
http = require("http")
body = "hello world\n"
server = http.createServer((req, res) ->
  res.writeHead 200,
    "Content-Length": body.length

  res.write body
  res.end()
  return
)
connectCount = 0
agent = new http.Agent(maxSockets: 1)
headers = connection: "keep-alive"
name = agent.getName(port: common.PORT)
server.listen common.PORT, ->
  http.get
    path: "/"
    headers: headers
    port: common.PORT
    agent: agent
  , (response) ->
    assert.equal agent.sockets[name].length, 1
    assert.equal agent.requests[name].length, 2
    response.resume()
    return

  http.get
    path: "/"
    headers: headers
    port: common.PORT
    agent: agent
  , (response) ->
    assert.equal agent.sockets[name].length, 1
    assert.equal agent.requests[name].length, 1
    response.resume()
    return

  http.get
    path: "/"
    headers: headers
    port: common.PORT
    agent: agent
  , (response) ->
    response.on "end", ->
      assert.equal agent.sockets[name].length, 1
      assert not agent.requests.hasOwnProperty(name)
      server.close()
      return

    response.resume()
    return

  return

process.on "exit", ->
  assert not agent.sockets.hasOwnProperty(name)
  assert not agent.requests.hasOwnProperty(name)
  return

