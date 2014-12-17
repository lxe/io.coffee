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

# try to send a 500.  If that fails, oh well.

# Now, an action that has the potential to fail!
# if you request 'baz', then it'll throw a JSON circular ref error.

# this line will throw if you pick an unknown key
next = ->
  makeReq = (p) ->
    requests++
    dom = domain.create()
    dom.on "error", (er) ->
      clientCaught++
      console.log "client error", er
      req.socket.destroy()
      return

    req = http.get(
      host: "localhost"
      port: common.PORT
      path: p
    )
    dom.add req
    req.on "response", (res) ->
      responses++
      console.error "requests=%d responses=%d", requests, responses
      if responses is requests
        console.error "done, closing server"
        
        # no more coming.
        server.close()
      dom.add res
      d = ""
      res.on "data", (c) ->
        d += c
        return

      res.on "end", ->
        console.error "trying to parse json", d
        d = JSON.parse(d)
        console.log "json!", d
        return

      return

    return
  console.log "listening on localhost:%d", common.PORT
  requests = 0
  responses = 0
  makeReq "/"
  makeReq "/foo"
  makeReq "/arr"
  makeReq "/baz"
  makeReq "/num"
  return
domain = require("domain")
http = require("http")
assert = require("assert")
common = require("../common.js")
objects =
  foo: "bar"
  baz: {}
  num: 42
  arr: [
    1
    2
    3
  ]

objects.baz.asdf = objects
serverCaught = 0
clientCaught = 0
disposeEmit = 0
server = http.createServer((req, res) ->
  dom = domain.create()
  req.resume()
  dom.add req
  dom.add res
  dom.on "error", (er) ->
    serverCaught++
    console.log "horray! got a server error", er
    res.writeHead 500,
      "content-type": "text/plain"

    res.end er.stack or er.message or "Unknown error"
    return

  dom.run ->
    data = JSON.stringify(objects[req.url.replace(/[^a-z]/g, "")])
    assert data isnt `undefined`, "Data should not be undefined"
    res.writeHead 200
    res.end data
    return

  return
)
server.listen common.PORT, next
process.on "exit", ->
  assert.equal serverCaught, 2
  assert.equal clientCaught, 2
  console.log "ok"
  return

