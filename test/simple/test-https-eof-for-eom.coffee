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

# I hate HTTP. One way of terminating an HTTP response is to not send
# a content-length header, not send a transfer-encoding: chunked header,
# and simply terminate the TCP connection. That is identity
# transfer-encoding.
#
# This test is to be sure that the https client is handling this case
# correctly.
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
tls = require("tls")
https = require("https")
fs = require("fs")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

server = tls.Server(options, (socket) ->
  console.log "2) Server got request"
  socket.write "HTTP/1.1 200 OK\r\n" + "Date: Tue, 15 Feb 2011 22:14:54 GMT\r\n" + "Expires: -1\r\n" + "Cache-Control: private, max-age=0\r\n" + "Set-Cookie: xyz\r\n" + "Set-Cookie: abc\r\n" + "Server: gws\r\n" + "X-XSS-Protection: 1; mode=block\r\n" + "Connection: close\r\n" + "\r\n"
  socket.write "hello world\n"
  setTimeout (->
    socket.end "hello world\n"
    console.log "4) Server finished response"
    return
  ), 100
  return
)
gotHeaders = false
gotEnd = false
bodyBuffer = ""
server.listen common.PORT, ->
  console.log "1) Making Request"
  req = https.get(
    port: common.PORT
    rejectUnauthorized: false
  , (res) ->
    server.close()
    console.log "3) Client got response headers."
    assert.equal "gws", res.headers.server
    gotHeaders = true
    res.setEncoding "utf8"
    res.on "data", (s) ->
      bodyBuffer += s
      return

    res.on "end", ->
      console.log "5) Client got \"end\" event."
      gotEnd = true
      return

    return
  )
  return

process.on "exit", ->
  assert.ok gotHeaders
  assert.ok gotEnd
  assert.equal "hello world\nhello world\n", bodyBuffer
  return

