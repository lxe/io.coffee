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

# Check that our HTTP server correctly handles HTTP/1.0 keep-alive requests.
check = (tests) ->
  next = ->
    check tests.slice(1)
    return
  server = (req, res) ->
    @close()  if current + 1 is test.responses.length
    ctx = test.responses[current]
    console.error "<  SERVER SENDING RESPONSE", ctx
    res.writeHead 200, ctx.headers
    ctx.chunks.slice(0, -1).forEach (chunk) ->
      res.write chunk
      return

    res.end ctx.chunks[ctx.chunks.length - 1]
    return
  client = ->
    connected = ->
      onclose = ->
        console.error " > CLIENT CLOSE"
        throw new Error("unexpected close")  unless ctx.expectClose
        client()
        return
      ondata = (s) ->
        console.error " > CLIENT ONDATA %j %j", s.length, s.toString()
        current++
        return  if ctx.expectClose
        conn.removeListener "close", onclose
        conn.removeListener "data", ondata
        connected()
        return
      ctx = test.requests[current]
      console.error " > CLIENT SENDING REQUEST", ctx
      conn.setEncoding "utf8"
      conn.write ctx.data
      conn.on "close", onclose
      conn.on "data", ondata
      return
    return next()  if current is test.requests.length
    conn = net.createConnection(common.PORT, "127.0.0.1", connected)
    return
  test = tests[0]
  http.createServer(server).listen common.PORT, "127.0.0.1", client  if test
  current = 0
  return
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
check [
  {
    name: "keep-alive, no TE header"
    requests: [
      {
        expectClose: true
        data: "POST / HTTP/1.0\r\n" + "Connection: keep-alive\r\n" + "\r\n"
      }
      {
        expectClose: true
        data: "POST / HTTP/1.0\r\n" + "Connection: keep-alive\r\n" + "\r\n"
      }
    ]
    responses: [
      {
        headers:
          Connection: "keep-alive"

        chunks: ["OK"]
      }
      {
        chunks: []
      }
    ]
  }
  {
    name: "keep-alive, with TE: chunked"
    requests: [
      {
        expectClose: false
        data: "POST / HTTP/1.0\r\n" + "Connection: keep-alive\r\n" + "TE: chunked\r\n" + "\r\n"
      }
      {
        expectClose: true
        data: "POST / HTTP/1.0\r\n" + "\r\n"
      }
    ]
    responses: [
      {
        headers:
          Connection: "keep-alive"

        chunks: ["OK"]
      }
      {
        chunks: []
      }
    ]
  }
  {
    name: "keep-alive, with Transfer-Encoding: chunked"
    requests: [
      {
        expectClose: false
        data: "POST / HTTP/1.0\r\n" + "Connection: keep-alive\r\n" + "\r\n"
      }
      {
        expectClose: true
        data: "POST / HTTP/1.0\r\n" + "\r\n"
      }
    ]
    responses: [
      {
        headers:
          Connection: "keep-alive"
          "Transfer-Encoding": "chunked"

        chunks: ["OK"]
      }
      {
        chunks: []
      }
    ]
  }
  {
    name: "keep-alive, with Content-Length"
    requests: [
      {
        expectClose: false
        data: "POST / HTTP/1.0\r\n" + "Connection: keep-alive\r\n" + "\r\n"
      }
      {
        expectClose: true
        data: "POST / HTTP/1.0\r\n" + "\r\n"
      }
    ]
    responses: [
      {
        headers:
          Connection: "keep-alive"
          "Content-Length": "2"

        chunks: ["OK"]
      }
      {
        chunks: []
      }
    ]
  }
]
