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

# cache the socket, close it after 100ms
get = (path, callback) ->
  http.get
    host: "localhost"
    port: common.PORT
    agent: agent
    path: path
  , callback
checkDataAndSockets = (body) ->
  assert.equal body.toString(), "hello world"
  assert.equal agent.sockets[name].length, 1
  assert.equal agent.freeSockets[name], `undefined`
  return
second = ->
  
  # request second, use the same socket
  get "/second", (res) ->
    assert.equal res.statusCode, 200
    res.on "data", checkDataAndSockets
    res.on "end", ->
      assert.equal agent.sockets[name].length, 1
      assert.equal agent.freeSockets[name], `undefined`
      process.nextTick ->
        assert.equal agent.sockets[name], `undefined`
        assert.equal agent.freeSockets[name].length, 1
        remoteClose()
        return

      return

    return

  return
remoteClose = ->
  
  # mock remote server close the socket
  get "/remote_close", (res) ->
    assert.deepEqual res.statusCode, 200
    res.on "data", checkDataAndSockets
    res.on "end", ->
      assert.equal agent.sockets[name].length, 1
      assert.equal agent.freeSockets[name], `undefined`
      process.nextTick ->
        assert.equal agent.sockets[name], `undefined`
        assert.equal agent.freeSockets[name].length, 1
        
        # waitting remote server close the socket
        setTimeout (->
          assert.equal agent.sockets[name], `undefined`
          assert.equal agent.freeSockets[name], `undefined`, "freeSockets is not empty"
          remoteError()
          return
        ), 200
        return

      return

    return

  return
remoteError = ->
  
  # remove server will destroy ths socket
  req = get("/error", (res) ->
    throw new Error("should not call this function")return
  )
  req.on "error", (err) ->
    assert.ok err
    assert.equal err.message, "socket hang up"
    assert.equal agent.sockets[name].length, 1
    assert.equal agent.freeSockets[name], `undefined`
    
    # Wait socket 'close' event emit
    setTimeout (->
      assert.equal agent.sockets[name], `undefined`
      assert.equal agent.freeSockets[name], `undefined`
      done()
      return
    ), 1
    return

  return
done = ->
  console.log "http keepalive agent test success."
  process.exit 0
  return
common = require("../common")
assert = require("assert")
http = require("http")
Agent = require("_http_agent").Agent
EventEmitter = require("events").EventEmitter
agent = new Agent(
  keepAlive: true
  keepAliveMsecs: 1000
  maxSockets: 5
  maxFreeSockets: 5
)
server = http.createServer((req, res) ->
  if req.url is "/error"
    res.destroy()
    return
  else if req.url is "/remote_close"
    socket = res.connection
    setTimeout (->
      socket.end()
      return
    ), 100
  res.end "hello world"
  return
)
name = "localhost:" + common.PORT + "::"
server.listen common.PORT, ->
  
  # request first, and keep alive
  get "/first", (res) ->
    assert.equal res.statusCode, 200
    res.on "data", checkDataAndSockets
    res.on "end", ->
      assert.equal agent.sockets[name].length, 1
      assert.equal agent.freeSockets[name], `undefined`
      process.nextTick ->
        assert.equal agent.sockets[name], `undefined`
        assert.equal agent.freeSockets[name].length, 1
        second()
        return

      return

    return

  return

