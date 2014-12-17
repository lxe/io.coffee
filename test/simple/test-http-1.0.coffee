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
test = (handler, request_generator, response_validator) ->
  cleanup = ->
    server.close()
    response_validator server_response, client_got_eof, true
    return
  port = common_port++
  server = http.createServer(handler)
  client_got_eof = false
  server_response =
    data: ""
    chunks: []

  timer = setTimeout(cleanup, 1000)
  process.on "exit", cleanup
  server.listen port
  server.on "listening", ->
    c = net.createConnection(port)
    c.setEncoding "utf8"
    c.on "connect", ->
      c.write request_generator()
      return

    c.on "data", (chunk) ->
      server_response.data += chunk
      server_response.chunks.push chunk
      return

    c.on "end", ->
      client_got_eof = true
      c.end()
      server.close()
      clearTimeout timer
      process.removeListener "exit", cleanup
      response_validator server_response, client_got_eof, false
      return

    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
http = require("http")
body = "hello world\n"
common_port = common.PORT
(->
  handler = (req, res) ->
    assert.equal "1.0", req.httpVersion
    assert.equal 1, req.httpVersionMajor
    assert.equal 0, req.httpVersionMinor
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.end body
    return
  request_generator = ->
    "GET / HTTP/1.0\r\n\r\n"
  response_validator = (server_response, client_got_eof, timed_out) ->
    m = server_response.data.split("\r\n\r\n")
    assert.equal m[1], body
    assert.equal true, client_got_eof
    assert.equal false, timed_out
    return
  test handler, request_generator, response_validator
  return
)()

#
# Don't send HTTP/1.1 status lines to HTTP/1.0 clients.
#
# https://github.com/joyent/node/issues/1234
#
(->
  handler = (req, res) ->
    assert.equal "1.0", req.httpVersion
    assert.equal 1, req.httpVersionMajor
    assert.equal 0, req.httpVersionMinor
    res.sendDate = false
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write "Hello, "
    res._send ""
    res.write "world!"
    res._send ""
    res.end()
    return
  request_generator = ->
    "GET / HTTP/1.0\r\n" + "User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 " + "OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15\r\n" + "Host: 127.0.0.1:1337\r\n" + "Accept: */*\r\n" + "\r\n"
  response_validator = (server_response, client_got_eof, timed_out) ->
    expected_response = ("HTTP/1.1 200 OK\r\n" + "Content-Type: text/plain\r\n" + "Connection: close\r\n" + "\r\n" + "Hello, world!")
    assert.equal expected_response, server_response.data
    assert.equal 1, server_response.chunks.length
    assert.equal true, client_got_eof
    assert.equal false, timed_out
    return
  test handler, request_generator, response_validator
  return
)()
(->
  handler = (req, res) ->
    assert.equal "1.1", req.httpVersion
    assert.equal 1, req.httpVersionMajor
    assert.equal 1, req.httpVersionMinor
    res.sendDate = false
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write "Hello, "
    res._send ""
    res.write "world!"
    res._send ""
    res.end()
    return
  request_generator = ->
    "GET / HTTP/1.1\r\n" + "User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 " + "OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15\r\n" + "Connection: close\r\n" + "Host: 127.0.0.1:1337\r\n" + "Accept: */*\r\n" + "\r\n"
  response_validator = (server_response, client_got_eof, timed_out) ->
    expected_response = ("HTTP/1.1 200 OK\r\n" + "Content-Type: text/plain\r\n" + "Connection: close\r\n" + "Transfer-Encoding: chunked\r\n" + "\r\n" + "7\r\n" + "Hello, \r\n" + "6\r\n" + "world!\r\n" + "0\r\n" + "\r\n")
    assert.equal expected_response, server_response.data
    assert.equal 1, server_response.chunks.length
    assert.equal true, client_got_eof
    assert.equal false, timed_out
    return
  test handler, request_generator, response_validator
  return
)()
