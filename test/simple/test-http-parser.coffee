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

# The purpose of this test is not to check HTTP compliance but to test the
# binding. Tests for pathological http messages should be submitted
# upstream to https://github.com/joyent/http-parser for inclusion into
# deps/http-parser/test.c
newParser = (type) ->
  parser = new HTTPParser(type)
  parser.headers = []
  parser.url = ""
  parser[kOnHeaders] = (headers, url) ->
    parser.headers = parser.headers.concat(headers)
    parser.url += url
    return

  parser[kOnHeadersComplete] = (info) ->

  parser[kOnBody] = (b, start, len) ->
    assert.ok false, "Function should not be called."
    return

  parser[kOnMessageComplete] = ->

  parser
mustCall = (f, times) ->
  actual = 0
  process.setMaxListeners 256
  process.on "exit", ->
    assert.equal actual, times or 1
    return

  ->
    actual++
    f.apply this, Array::slice.call(arguments)
expectBody = (expected) ->
  mustCall (buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, expected
    return

common = require("../common")
assert = require("assert")
HTTPParser = process.binding("http_parser").HTTPParser
CRLF = "\r\n"
REQUEST = HTTPParser.REQUEST
RESPONSE = HTTPParser.RESPONSE
methods = HTTPParser.methods
kOnHeaders = HTTPParser.kOnHeaders | 0
kOnHeadersComplete = HTTPParser.kOnHeadersComplete | 0
kOnBody = HTTPParser.kOnBody | 0
kOnMessageComplete = HTTPParser.kOnMessageComplete | 0

#
# Simple request test.
#
(->
  request = Buffer("GET /hello HTTP/1.1" + CRLF + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("GET")
    assert.equal info.url or parser.url, "/hello"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    return
  )
  parser.execute request, 0, request.length
  
  #
  # Check that if we throw an error in the callbacks that error will be
  # thrown from parser.execute()
  #
  parser[kOnHeadersComplete] = (info) ->
    throw new Error("hello world")return

  parser.reinitialize HTTPParser.REQUEST
  assert.throws (->
    parser.execute request, 0, request.length
    return
  ), Error, "hello world"
  return
)()

#
# Simple response test.
#
(->
  request = Buffer("HTTP/1.1 200 OK" + CRLF + "Content-Type: text/plain" + CRLF + "Content-Length: 4" + CRLF + CRLF + "pong")
  parser = newParser(RESPONSE)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, `undefined`
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    assert.equal info.statusCode, 200
    assert.equal info.statusMessage, "OK"
    return
  )
  parser[kOnBody] = mustCall((buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, "pong"
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Response with no headers.
#
(->
  request = Buffer("HTTP/1.0 200 Connection established" + CRLF + CRLF)
  parser = newParser(RESPONSE)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, `undefined`
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 0
    assert.equal info.statusCode, 200
    assert.equal info.statusMessage, "Connection established"
    assert.deepEqual info.headers or parser.headers, []
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Trailing headers.
#
(->
  onHeaders = (headers, url) ->
    assert.ok seen_body # trailers should come after the body
    assert.deepEqual headers, [
      "Vary"
      "*"
      "Content-Type"
      "text/plain"
    ]
    return
  request = Buffer("POST /it HTTP/1.1" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "4" + CRLF + "ping" + CRLF + "0" + CRLF + "Vary: *" + CRLF + "Content-Type: text/plain" + CRLF + CRLF)
  seen_body = false
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url or parser.url, "/it"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    
    # expect to see trailing headers now
    parser[kOnHeaders] = mustCall(onHeaders)
    return
  )
  parser[kOnBody] = mustCall((buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, "ping"
    seen_body = true
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Test header ordering.
#
(->
  request = Buffer("GET / HTTP/1.0" + CRLF + "X-Filler: 1337" + CRLF + "X-Filler:   42" + CRLF + "X-Filler2:  42" + CRLF + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("GET")
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 0
    assert.deepEqual info.headers or parser.headers, [
      "X-Filler"
      "1337"
      "X-Filler"
      "42"
      "X-Filler2"
      "42"
    ]
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Test large number of headers
#
(->
  
  # 256 X-Filler headers
  lots_of_headers = "X-Filler: 42" + CRLF
  i = 0

  while i < 8
    lots_of_headers += lots_of_headers
    ++i
  request = Buffer("GET /foo/bar/baz?quux=42#1337 HTTP/1.0" + CRLF + lots_of_headers + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("GET")
    assert.equal info.url or parser.url, "/foo/bar/baz?quux=42#1337"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 0
    headers = info.headers or parser.headers
    assert.equal headers.length, 2 * 256 # 256 key/value pairs
    i = 0

    while i < headers.length
      assert.equal headers[i], "X-Filler"
      assert.equal headers[i + 1], "42"
      i += 2
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Test request body
#
(->
  request = Buffer("POST /it HTTP/1.1" + CRLF + "Content-Type: application/x-www-form-urlencoded" + CRLF + "Content-Length: 15" + CRLF + CRLF + "foo=42&bar=1337")
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url or parser.url, "/it"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    return
  )
  parser[kOnBody] = mustCall((buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, "foo=42&bar=1337"
    return
  )
  parser.execute request, 0, request.length
  return
)()

#
# Test chunked request body
#
(->
  onBody = (buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, body_parts[body_part++]
    return
  request = Buffer("POST /it HTTP/1.1" + CRLF + "Content-Type: text/plain" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "3" + CRLF + "123" + CRLF + "6" + CRLF + "123456" + CRLF + "A" + CRLF + "1234567890" + CRLF + "0" + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url or parser.url, "/it"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    return
  )
  body_part = 0
  body_parts = [
    "123"
    "123456"
    "1234567890"
  ]
  parser[kOnBody] = mustCall(onBody, body_parts.length)
  parser.execute request, 0, request.length
  return
)()

#
# Test chunked request body spread over multiple buffers (packets)
#
(->
  onBody = (buf, start, len) ->
    body = "" + buf.slice(start, start + len)
    assert.equal body, body_parts[body_part++]
    return
  request = Buffer("POST /it HTTP/1.1" + CRLF + "Content-Type: text/plain" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "3" + CRLF + "123" + CRLF + "6" + CRLF + "123456" + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url or parser.url, "/it"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    return
  )
  body_part = 0
  body_parts = [
    "123"
    "123456"
    "123456789"
    "123456789ABC"
    "123456789ABCDEF"
  ]
  parser[kOnBody] = mustCall(onBody, body_parts.length)
  parser.execute request, 0, request.length
  request = Buffer("9" + CRLF + "123456789" + CRLF + "C" + CRLF + "123456789ABC" + CRLF + "F" + CRLF + "123456789ABCDEF" + CRLF + "0" + CRLF)
  parser.execute request, 0, request.length
  return
)()

#
# Stress test.
#
(->
  test = (a, b) ->
    parser = newParser(REQUEST)
    parser[kOnHeadersComplete] = mustCall((info) ->
      assert.equal info.method, methods.indexOf("POST")
      assert.equal info.url or parser.url, "/helpme"
      assert.equal info.versionMajor, 1
      assert.equal info.versionMinor, 1
      return
    )
    expected_body = "123123456123456789123456789ABC123456789ABCDEF"
    parser[kOnBody] = (buf, start, len) ->
      chunk = "" + buf.slice(start, start + len)
      assert.equal expected_body.indexOf(chunk), 0
      expected_body = expected_body.slice(chunk.length)
      return

    parser.execute a, 0, a.length
    parser.execute b, 0, b.length
    assert.equal expected_body, ""
    return
  request = Buffer("POST /helpme HTTP/1.1" + CRLF + "Content-Type: text/plain" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "3" + CRLF + "123" + CRLF + "6" + CRLF + "123456" + CRLF + "9" + CRLF + "123456789" + CRLF + "C" + CRLF + "123456789ABC" + CRLF + "F" + CRLF + "123456789ABCDEF" + CRLF + "0" + CRLF)
  i = 1

  while i < request.length - 1
    a = request.slice(0, i)
    console.error "request.slice(0, " + i + ") = ", JSON.stringify(a.toString())
    b = request.slice(i)
    console.error "request.slice(" + i + ") = ", JSON.stringify(b.toString())
    test a, b
    ++i
  return
)()

#
# Byte by byte test.
#
(->
  request = Buffer("POST /it HTTP/1.1" + CRLF + "Content-Type: text/plain" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "3" + CRLF + "123" + CRLF + "6" + CRLF + "123456" + CRLF + "9" + CRLF + "123456789" + CRLF + "C" + CRLF + "123456789ABC" + CRLF + "F" + CRLF + "123456789ABCDEF" + CRLF + "0" + CRLF)
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = mustCall((info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url or parser.url, "/it"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    assert.deepEqual info.headers or parser.headers, [
      "Content-Type"
      "text/plain"
      "Transfer-Encoding"
      "chunked"
    ]
    return
  )
  expected_body = "123123456123456789123456789ABC123456789ABCDEF"
  parser[kOnBody] = (buf, start, len) ->
    chunk = "" + buf.slice(start, start + len)
    assert.equal expected_body.indexOf(chunk), 0
    expected_body = expected_body.slice(chunk.length)
    return

  i = 0

  while i < request.length
    parser.execute request, i, 1
    ++i
  assert.equal expected_body, ""
  return
)()

#
# Test parser reinit sequence.
#
(->
  onHeadersComplete1 = (info) ->
    assert.equal info.method, methods.indexOf("PUT")
    assert.equal info.url, "/this"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 1
    assert.deepEqual info.headers, [
      "Content-Type"
      "text/plain"
      "Transfer-Encoding"
      "chunked"
    ]
    return
  onHeadersComplete2 = (info) ->
    assert.equal info.method, methods.indexOf("POST")
    assert.equal info.url, "/that"
    assert.equal info.versionMajor, 1
    assert.equal info.versionMinor, 0
    assert.deepEqual info.headers, [
      "Content-Type"
      "text/plain"
      "Content-Length"
      "4"
    ]
    return
  req1 = Buffer("PUT /this HTTP/1.1" + CRLF + "Content-Type: text/plain" + CRLF + "Transfer-Encoding: chunked" + CRLF + CRLF + "4" + CRLF + "ping" + CRLF + "0" + CRLF)
  req2 = Buffer("POST /that HTTP/1.0" + CRLF + "Content-Type: text/plain" + CRLF + "Content-Length: 4" + CRLF + CRLF + "pong")
  parser = newParser(REQUEST)
  parser[kOnHeadersComplete] = onHeadersComplete1
  parser[kOnBody] = expectBody("ping")
  parser.execute req1, 0, req1.length
  parser.reinitialize REQUEST
  parser[kOnBody] = expectBody("pong")
  parser[kOnHeadersComplete] = onHeadersComplete2
  parser.execute req2, 0, req2.length
  return
)()

# Test parser 'this' safety
# https://github.com/joyent/node/issues/6690
assert.throws (->
  request = Buffer("GET /hello HTTP/1.1" + CRLF + CRLF)
  parser = newParser(REQUEST)
  notparser = execute: parser.execute
  notparser.execute request, 0, request.length
  return
), TypeError
