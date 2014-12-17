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

# Set up some timing issues where sockets can be destroyed
# via either the req or res.

# in one case, actually send a response in 2 chunks

# Make a bunch of requests pipelined on the same socket
generator = (seeds) ->
  seeds.map((r) ->
    "GET /" + r + " HTTP/1.1\r\n" + "Host: localhost:" + common.PORT + "\r\n" + "\r\n" + "\r\n"
  ).join ""
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
server = http.createServer((req, res) ->
  switch req.url
    when "/1"
      setTimeout ->
        req.socket.destroy()
        server.emit "requestDone"
        return

    when "/2"
      process.nextTick ->
        res.destroy()
        server.emit "requestDone"
        return

    when "/3"
      res.write "hello "
      setTimeout ->
        res.end "world!"
        server.emit "requestDone"
        return

    else
      res.destroy()
      server.emit "requestDone"
  return
)
server.listen common.PORT, ->
  seeds = [
    3
    1
    2
    3
    4
    1
    2
    3
    4
    1
    2
    3
    4
  ]
  client = net.connect(port: common.PORT)
  done = 0
  server.on "requestDone", ->
    server.close()  if ++done is seeds.length
    return

  
  # immediately write the pipelined requests.
  # Some of these will not have a socket to destroy!
  client.write generator(seeds)
  return

process.on "exit", (c) ->
  console.log "ok"  unless c
  return

