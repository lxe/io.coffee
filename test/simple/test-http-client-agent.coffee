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
request = (i) ->
  req = http.get(
    port: common.PORT
    path: "/" + i
  , (res) ->
    socket = req.socket
    socket.on "close", ->
      ++count
      if count < max
        assert.equal http.globalAgent.sockets[name].indexOf(socket), -1
      else
        assert not http.globalAgent.sockets.hasOwnProperty(name)
        assert not http.globalAgent.requests.hasOwnProperty(name)
        server.close()
      return

    res.resume()
    return
  )
  return
common = require("../common")
assert = require("assert")
http = require("http")
name = http.globalAgent.getName(port: common.PORT)
max = 3
count = 0
server = http.Server((req, res) ->
  if req.url is "/0"
    setTimeout (->
      res.writeHead 200
      res.end "Hello, World!"
      return
    ), 100
  else
    res.writeHead 200
    res.end "Hello, World!"
  return
)
server.listen common.PORT, ->
  i = 0

  while i < max
    request i
    ++i
  return

process.on "exit", ->
  assert.equal count, max
  return

