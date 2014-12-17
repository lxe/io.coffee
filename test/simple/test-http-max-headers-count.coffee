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
requests = 0
responses = 0
headers = {}
N = 2000
i = 0

while i < N
  headers["key" + i] = i
  ++i
maxAndExpected = [ # for server
  [
    50
    50
  ]
  [
    1500
    1500
  ]
  [ # Host and Connection
    0
    N + 2
  ]
]
max = maxAndExpected[requests][0]
expected = maxAndExpected[requests][1]
server = http.createServer((req, res) ->
  assert.equal Object.keys(req.headers).length, expected
  if ++requests < maxAndExpected.length
    max = maxAndExpected[requests][0]
    expected = maxAndExpected[requests][1]
    server.maxHeadersCount = max
  res.writeHead 200, headers
  res.end()
  return
)
server.maxHeadersCount = max
server.listen common.PORT, ->
  # for client
  # Connection, Date and Transfer-Encoding
  doRequest = ->
    max = maxAndExpected[responses][0]
    expected = maxAndExpected[responses][1]
    req = http.request(
      port: common.PORT
      headers: headers
    , (res) ->
      assert.equal Object.keys(res.headers).length, expected
      res.on "end", ->
        if ++responses < maxAndExpected.length
          doRequest()
        else
          server.close()
        return

      res.resume()
      return
    )
    req.maxHeadersCount = max
    req.end()
    return
  maxAndExpected = [
    [
      20
      20
    ]
    [
      1200
      1200
    ]
    [
      0
      N + 3
    ]
  ]
  doRequest()
  return

process.on "exit", ->
  assert.equal requests, maxAndExpected.length
  assert.equal responses, maxAndExpected.length
  return

