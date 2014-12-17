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

# Verify that ECONNRESET is raised when writing to a http request
# where the server has ended the socket.
http = require("http")
net = require("net")
server = http.createServer((req, res) ->
  setImmediate ->
    res.destroy()
    return

  return
)
server.listen common.PORT, ->
  write = ->
    if ++writes is 128
      clearTimeout timer
      req.end()
      test()
    else
      timer = setImmediate(write)
      req.write "hello"
    return
  
  # This is the expected case
  
  # On windows this sometimes manifests as ECONNABORTED
  test = ->
    return  if closed
    server.close()
    closed = true
    console.error "bad happened", req.output, req.outputEncodings  if req.output.length or req.outputEncodings.length
    assert.equal req.output.length, 0
    assert.equal req.outputEncodings, 0
    assert gotError
    assert not sawData
    assert not sawEnd
    console.log "ok"
    return
  req = http.request(
    port: common.PORT
    path: "/"
    method: "POST"
  )
  timer = setImmediate(write)
  writes = 0
  gotError = false
  sawData = false
  sawEnd = false
  req.on "error", (er) ->
    assert not gotError
    gotError = true
    switch er.code
      when "ECONNRESET", "ECONNABORTED"
      else
        assert.strictEqual er.code, "ECONNRESET", "Writing to a torn down client should RESET or ABORT"
    clearTimeout timer
    console.log "ECONNRESET was raised after %d writes", writes
    test()
    return

  req.on "response", (res) ->
    res.on "data", (chunk) ->
      console.error "saw data: " + chunk
      sawData = true
      return

    res.on "end", ->
      console.error "saw end"
      sawEnd = true
      return

    return

  closed = false
  return

