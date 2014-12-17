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

# Simple test of Node's HTTP Client mutable headers
# OutgoingMessage.prototype.setHeader(name, value)
# OutgoingMessage.prototype.getHeader(name)
# OutgoingMessage.prototype.removeHeader(name, value)
# ServerResponse.prototype.statusCode
# <ClientRequest>.method
# <ClientRequest>.path
nextTest = ->
  return s.close()  if test is "end"
  bufferedResponse = ""
  http.get
    port: common.PORT
  , (response) ->
    console.log "TEST: " + test
    console.log "STATUS: " + response.statusCode
    console.log "HEADERS: "
    console.dir response.headers
    switch test
      when "headers"
        assert.equal response.statusCode, 201
        assert.equal response.headers["x-test-header"], "testing"
        assert.equal response.headers["x-test-array-header"], [
          1
          2
          3
        ].join(", ")
        assert.deepEqual cookies, response.headers["set-cookie"]
        assert.equal response.headers["x-test-header2"] isnt `undefined`, false
        
        # Make the next request
        test = "contentLength"
        console.log "foobar"
      when "contentLength"
        assert.equal response.headers["content-length"], content.length
        test = "transferEncoding"
      when "transferEncoding"
        assert.equal response.headers["transfer-encoding"], "chunked"
        test = "writeHead"
      when "writeHead"
        assert.equal response.headers["x-foo"], "bar"
        assert.equal response.headers["x-bar"], "baz"
        assert.equal 200, response.statusCode
        test = "end"
      else
        throw Error("?")
    response.setEncoding "utf8"
    response.on "data", (s) ->
      bufferedResponse += s
      return

    response.on "end", ->
      assert.equal content, bufferedResponse
      testsComplete++
      nextTest()
      return

    return

  return
common = require("../common")
assert = require("assert")
http = require("http")
testsComplete = 0
test = "headers"
content = "hello world\n"
cookies = [
  "session_token=; path=/; expires=Sun, 15-Sep-2030 13:48:52 GMT"
  "prefers_open_id=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT"
]
s = http.createServer((req, res) ->
  switch test
    when "headers"
      assert.throws ->
        res.setHeader()
        return

      assert.throws ->
        res.setHeader "someHeader"
        return

      assert.throws ->
        res.getHeader()
        return

      assert.throws ->
        res.removeHeader()
        return

      res.setHeader "x-test-header", "testing"
      res.setHeader "X-TEST-HEADER2", "testing"
      res.setHeader "set-cookie", cookies
      res.setHeader "x-test-array-header", [
        1
        2
        3
      ]
      val1 = res.getHeader("x-test-header")
      val2 = res.getHeader("x-test-header2")
      assert.equal val1, "testing"
      assert.equal val2, "testing"
      res.removeHeader "x-test-header2"
    when "contentLength"
      res.setHeader "content-length", content.length
      assert.equal content.length, res.getHeader("Content-Length")
    when "transferEncoding"
      res.setHeader "transfer-encoding", "chunked"
      assert.equal res.getHeader("Transfer-Encoding"), "chunked"
    when "writeHead"
      res.statusCode = 404
      res.setHeader "x-foo", "keyboard cat"
      res.writeHead 200,
        "x-foo": "bar"
        "x-bar": "baz"

  res.statusCode = 201
  res.end content
  return
)
s.listen common.PORT, nextTest
process.on "exit", ->
  assert.equal 4, testsComplete
  return

