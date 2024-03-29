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
requestGotEnd = false
responseGotEnd = false
server = http.createServer((req, res) ->
  res.writeHead 200
  res.write "a"
  req.on "close", ->
    console.error "request aborted"
    requestGotEnd = true
    return

  res.on "close", ->
    console.error "response aborted"
    responseGotEnd = true
    return

  return
)
server.listen common.PORT
server.on "listening", ->
  console.error "make req"
  http.get
    port: common.PORT
  , (res) ->
    console.error "got res"
    res.on "data", (data) ->
      console.error "destroy res"
      res.destroy()
      server.close()
      return

    return

  return

process.on "exit", ->
  assert.ok requestGotEnd
  assert.ok responseGotEnd
  return

