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
expectedHeaders =
  DELETE: [
    "host"
    "connection"
  ]
  GET: [
    "host"
    "connection"
  ]
  HEAD: [
    "host"
    "connection"
  ]
  OPTIONS: [
    "host"
    "connection"
  ]
  POST: [
    "host"
    "connection"
    "transfer-encoding"
  ]
  PUT: [
    "host"
    "connection"
    "transfer-encoding"
  ]

expectedMethods = Object.keys(expectedHeaders)
requestCount = 0
server = http.createServer((req, res) ->
  requestCount++
  res.end()
  assert expectedHeaders.hasOwnProperty(req.method), req.method + " was an unexpected method"
  requestHeaders = Object.keys(req.headers)
  requestHeaders.forEach (header) ->
    assert expectedHeaders[req.method].indexOf(header.toLowerCase()) isnt -1, header + " shoud not exist for method " + req.method
    return

  assert requestHeaders.length is expectedHeaders[req.method].length, "some headers were missing for method: " + req.method
  server.close()  if expectedMethods.length is requestCount
  return
)
server.listen common.PORT, ->
  expectedMethods.forEach (method) ->
    http.request(
      method: method
      port: common.PORT
    ).end()
    return

  return

