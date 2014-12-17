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
test = (httpVersion, callback) ->
  process.on "exit", ->
    assert gotExpected
    return

  server = net.createServer((conn) ->
    reply = "HTTP/" + httpVersion + " 200 OK\r\n\r\n" + expected[httpVersion]
    conn.end reply
    return
  )
  server.listen common.PORT, "127.0.0.1", ->
    options =
      host: "127.0.0.1"
      port: common.PORT

    req = http.get(options, (res) ->
      body = ""
      res.on "data", (data) ->
        body += data
        return

      res.on "end", ->
        assert.equal body, expected[httpVersion]
        gotExpected = true
        server.close()
        process.nextTick callback  if callback
        return

      return
    )
    req.on "error", (err) ->
      throw errreturn

    return

  return
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
expected =
  "0.9": "I AM THE WALRUS"
  "1.0": "I AM THE WALRUS"
  "1.1": ""

gotExpected = false
test "0.9", ->
  test "1.0", ->
    test "1.1"
    return

  return

