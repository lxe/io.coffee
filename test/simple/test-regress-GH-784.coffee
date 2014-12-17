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

# Regression test for GH-784
# https://github.com/joyent/node/issues/784
#
# The test works by making a total of 8 requests to the server.  The first
# two are made with the server off - they should come back as ECONNREFUSED.
# The next two are made with server on - they should come back successful.
# The next two are made with the server off - and so on.  Without the fix
# we were experiencing parse errors and instead of ECONNREFUSED.
serverOn = ->
  console.error "Server ON"
  server.listen common.PORT
  return
serverOff = ->
  console.error "Server OFF"
  server.close()
  pingping()
  return
afterPing = (result) ->
  responses.push result
  console.error "afterPing. responses.length = " + responses.length
  switch responses.length
    when 2
      assert.ok /ECONNREFUSED/.test(responses[0])
      assert.ok /ECONNREFUSED/.test(responses[1])
      serverOn()
    when 4
      assert.ok /success/.test(responses[2])
      assert.ok /success/.test(responses[3])
      serverOff()
    when 6
      assert.ok /ECONNREFUSED/.test(responses[4])
      assert.ok /ECONNREFUSED/.test(responses[5])
      serverOn()
    when 8
      assert.ok /success/.test(responses[6])
      assert.ok /success/.test(responses[7])
      server.close()

# we should go to process.on('exit') from here.
ping = ->
  console.error "making req"
  opt =
    port: common.PORT
    path: "/ping"
    method: "POST"

  req = http.request(opt, (res) ->
    body = ""
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      body += chunk
      return

    res.on "end", ->
      assert.equal "PONG", body
      assert.ok not hadError
      gotEnd = true
      afterPing "success"
      return

    return
  )
  req.end "PING"
  gotEnd = false
  hadError = false
  req.on "error", (error) ->
    console.log "Error making ping req: " + error
    hadError = true
    assert.ok not gotEnd
    afterPing error.message
    return

  return
pingping = ->
  ping()
  ping()
  return
common = require("../common")
http = require("http")
assert = require("assert")
server = http.createServer((req, res) ->
  body = ""
  req.setEncoding "utf8"
  req.on "data", (chunk) ->
    body += chunk
    return

  req.on "end", ->
    assert.equal "PING", body
    res.writeHead 200
    res.end "PONG"
    return

  return
)
server.on "listening", pingping
responses = []
pingping()
process.on "exit", ->
  console.error "process.on('exit')"
  console.error responses
  assert.equal 8, responses.length
  return

