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
net = require("net")
testsComplete = 0
testCases = [
  {
    path: "/200"
    statusMessage: "OK"
    response: "HTTP/1.1 200 OK\r\n\r\n"
  }
  {
    path: "/500"
    statusMessage: "Internal Server Error"
    response: "HTTP/1.1 500 Internal Server Error\r\n\r\n"
  }
  {
    path: "/302"
    statusMessage: "Moved Temporarily"
    response: "HTTP/1.1 302 Moved Temporarily\r\n\r\n"
  }
  {
    path: "/missing"
    statusMessage: ""
    response: "HTTP/1.1 200 \r\n\r\n"
  }
  {
    path: "/missing-no-space"
    statusMessage: ""
    response: "HTTP/1.1 200\r\n\r\n"
  }
]
testCases.findByPath = (path) ->
  matching = @filter((testCase) ->
    testCase.path is path
  )
  throw "failed to find test case with path " + path  if matching.length is 0
  matching[0]

server = net.createServer((connection) ->
  connection.on "data", (data) ->
    path = data.toString().match(/GET (.*) HTTP.1.1/)[1]
    testCase = testCases.findByPath(path)
    connection.write testCase.response
    connection.end()
    return

  return
)
runTest = (testCaseIndex) ->
  testCase = testCases[testCaseIndex]
  http.get
    port: common.PORT
    path: testCase.path
  , (response) ->
    console.log "client: expected status message: " + testCase.statusMessage
    console.log "client: actual status message: " + response.statusMessage
    assert.equal testCase.statusMessage, response.statusMessage
    response.on "end", ->
      testsComplete++
      if testCaseIndex + 1 < testCases.length
        runTest testCaseIndex + 1
      else
        server.close()
      return

    response.resume()
    return

  return

server.listen common.PORT, ->
  runTest 0
  return

process.on "exit", ->
  assert.equal testCases.length, testsComplete
  return

