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

# https://github.com/joyent/node/issues/4948
common = require("../common")
http = require("http")
reqCount = 0

# normally the use case would be to call an external site
# does not require connecting locally or to itself to fail

# required, just needs to be in the client response somewhere

# required for test to fail
server = http.createServer((serverReq, serverRes) ->
  if reqCount
    serverRes.end()
    server.close()
    return
  reqCount = 1
  r = http.request(
    hostname: "localhost"
    port: common.PORT
  , (res) ->
    serverRes.end()
    res.on "data", (data) ->

    return
  )
  r.on "error", (e) ->

  r.end()
  serverRes.write "some data"
  return
).listen(common.PORT)

# simulate a client request that closes early
net = require("net")
sock = new net.Socket()
sock.connect common.PORT, "localhost"
sock.on "connect", ->
  sock.write "GET / HTTP/1.1\r\n\r\n"
  sock.end()
  return

