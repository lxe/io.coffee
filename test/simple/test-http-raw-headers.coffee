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
common = require("../common")
assert = require("assert")
http = require("http")
http.createServer((req, res) ->
  @close()
  expectRawHeaders = [
    "Host"
    "localhost:" + common.PORT
    "transfer-ENCODING"
    "CHUNKED"
    "x-BaR"
    "yoyoyo"
    "Connection"
    "close"
  ]
  expectHeaders =
    host: "localhost:" + common.PORT
    "transfer-encoding": "CHUNKED"
    "x-bar": "yoyoyo"
    connection: "close"

  expectRawTrailers = [
    "x-bAr"
    "yOyOyOy"
    "x-baR"
    "OyOyOyO"
    "X-bAr"
    "yOyOyOy"
    "X-baR"
    "OyOyOyO"
  ]
  expectTrailers = "x-bar": "yOyOyOy, OyOyOyO, yOyOyOy, OyOyOyO"
  assert.deepEqual req.rawHeaders, expectRawHeaders
  assert.deepEqual req.headers, expectHeaders
  req.on "end", ->
    assert.deepEqual req.rawTrailers, expectRawTrailers
    assert.deepEqual req.trailers, expectTrailers
    return

  req.resume()
  res.addTrailers [
    [
      "x-fOo"
      "xOxOxOx"
    ]
    [
      "x-foO"
      "OxOxOxO"
    ]
    [
      "X-fOo"
      "xOxOxOx"
    ]
    [
      "X-foO"
      "OxOxOxO"
    ]
  ]
  res.end "x f o o"
  return
).listen common.PORT, ->
  expectRawHeaders = [
    "Date"
    "Tue, 06 Aug 2013 01:31:54 GMT"
    "Connection"
    "close"
    "Transfer-Encoding"
    "chunked"
  ]
  req = http.request(
    port: common.PORT
    path: "/"
  )
  req.addTrailers [
    [
      "x-bAr"
      "yOyOyOy"
    ]
    [
      "x-baR"
      "OyOyOyO"
    ]
    [
      "X-bAr"
      "yOyOyOy"
    ]
    [
      "X-baR"
      "OyOyOyO"
    ]
  ]
  req.setHeader "transfer-ENCODING", "CHUNKED"
  req.setHeader "x-BaR", "yoyoyo"
  req.end "y b a r"
  req.on "response", (res) ->
    expectRawHeaders = [
      "Date"
      null
      "Connection"
      "close"
      "Transfer-Encoding"
      "chunked"
    ]
    expectHeaders =
      date: null
      connection: "close"
      "transfer-encoding": "chunked"

    res.rawHeaders[1] = null
    res.headers.date = null
    assert.deepEqual res.rawHeaders, expectRawHeaders
    assert.deepEqual res.headers, expectHeaders
    res.on "end", ->
      expectRawTrailers = [
        "x-fOo"
        "xOxOxOx"
        "x-foO"
        "OxOxOxO"
        "X-fOo"
        "xOxOxOx"
        "X-foO"
        "OxOxOxO"
      ]
      expectTrailers = "x-foo": "xOxOxOx, OxOxOxO, xOxOxOx, OxOxOxO"
      assert.deepEqual res.rawTrailers, expectRawTrailers
      assert.deepEqual res.trailers, expectTrailers
      console.log "ok"
      return

    res.resume()
    return

  return

