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
server = http.createServer((request, response) ->
  
  # removed headers should stay removed, even if node automatically adds them
  # to the output:
  response.removeHeader "connection"
  response.removeHeader "transfer-encoding"
  
  # make sure that removing and then setting still works:
  response.removeHeader "date"
  response.setHeader "date", "coffee o clock"
  response.end "beep boop\n"
  @close()
  return
)
response = ""
process.on "exit", ->
  assert.equal "beep boop\n", response
  console.log "ok"
  return

server.listen common.PORT, ->
  http.get
    port: common.PORT
  , (res) ->
    assert.equal 200, res.statusCode
    assert.deepEqual res.headers,
      date: "coffee o clock"

    res.setEncoding "ascii"
    res.on "data", (chunk) ->
      response += chunk
      return

    return

  return

