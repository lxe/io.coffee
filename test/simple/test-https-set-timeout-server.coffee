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
test = (fn) ->
  process.nextTick run  unless tests.length
  tests.push fn
  return
run = ->
  fn = tests.shift()
  if fn
    console.log "# %s", fn.name
    fn run
  else
    console.log "ok"
  return
common = require("../common.js")
assert = require("assert")
https = require("https")
tls = require("tls")
fs = require("fs")
tests = []
serverOptions =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

test serverTimeout = (cb) ->
  caughtTimeout = false
  process.on "exit", ->
    assert caughtTimeout
    return

  server = https.createServer(serverOptions, (req, res) ->
  )
  
  # just do nothing, we should get a timeout event.
  server.listen common.PORT
  server.setTimeout 50, (socket) ->
    caughtTimeout = true
    socket.destroy()
    server.close()
    cb()
    return

  https.get(
    port: common.PORT
    rejectUnauthorized: false
  ).on "error", ->

  return

test serverRequestTimeout = (cb) ->
  caughtTimeout = false
  process.on "exit", ->
    assert caughtTimeout
    return

  server = https.createServer(serverOptions, (req, res) ->
    
    # just do nothing, we should get a timeout event.
    req.setTimeout 50, ->
      caughtTimeout = true
      req.socket.destroy()
      server.close()
      cb()
      return

    return
  )
  server.listen common.PORT
  req = https.request(
    port: common.PORT
    method: "POST"
    rejectUnauthorized: false
  )
  req.on "error", ->

  req.write "Hello"
  return


# req is in progress
test serverResponseTimeout = (cb) ->
  caughtTimeout = false
  process.on "exit", ->
    assert caughtTimeout
    return

  server = https.createServer(serverOptions, (req, res) ->
    
    # just do nothing, we should get a timeout event.
    res.setTimeout 50, ->
      caughtTimeout = true
      res.socket.destroy()
      server.close()
      cb()
      return

    return
  )
  server.listen common.PORT
  https.get(
    port: common.PORT
    rejectUnauthorized: false
  ).on "error", ->

  return

test serverRequestNotTimeoutAfterEnd = (cb) ->
  caughtTimeoutOnRequest = false
  caughtTimeoutOnResponse = false
  process.on "exit", ->
    assert not caughtTimeoutOnRequest
    assert caughtTimeoutOnResponse
    return

  server = https.createServer(serverOptions, (req, res) ->
    
    # just do nothing, we should get a timeout event.
    req.setTimeout 50, (socket) ->
      caughtTimeoutOnRequest = true
      return

    res.on "timeout", (socket) ->
      caughtTimeoutOnResponse = true
      return

    return
  )
  server.on "timeout", (socket) ->
    socket.destroy()
    server.close()
    cb()
    return

  server.listen common.PORT
  https.get(
    port: common.PORT
    rejectUnauthorized: false
  ).on "error", ->

  return

test serverResponseTimeoutWithPipeline = (cb) ->
  caughtTimeout = ""
  process.on "exit", ->
    assert.equal caughtTimeout, "/2"
    return

  server = https.createServer(serverOptions, (req, res) ->
    res.setTimeout 50, ->
      caughtTimeout += req.url
      return

    res.end()  if req.url is "/1"
    return
  )
  server.on "timeout", (socket) ->
    socket.destroy()
    server.close()
    cb()
    return

  server.listen common.PORT
  options =
    port: common.PORT
    allowHalfOpen: true
    rejectUnauthorized: false

  c = tls.connect(options, ->
    c.write "GET /1 HTTP/1.1\r\nHost: localhost\r\n\r\n"
    c.write "GET /2 HTTP/1.1\r\nHost: localhost\r\n\r\n"
    c.write "GET /3 HTTP/1.1\r\nHost: localhost\r\n\r\n"
    return
  )
  return

test idleTimeout = (cb) ->
  caughtTimeoutOnRequest = false
  caughtTimeoutOnResponse = false
  caughtTimeoutOnServer = false
  process.on "exit", ->
    assert not caughtTimeoutOnRequest
    assert not caughtTimeoutOnResponse
    assert caughtTimeoutOnServer
    return

  server = https.createServer(serverOptions, (req, res) ->
    req.on "timeout", (socket) ->
      caughtTimeoutOnRequest = true
      return

    res.on "timeout", (socket) ->
      caughtTimeoutOnResponse = true
      return

    res.end()
    return
  )
  server.setTimeout 50, (socket) ->
    caughtTimeoutOnServer = true
    socket.destroy()
    server.close()
    cb()
    return

  server.listen common.PORT
  options =
    port: common.PORT
    allowHalfOpen: true
    rejectUnauthorized: false

  tls.connect options, ->
    @write "GET /1 HTTP/1.1\r\nHost: localhost\r\n\r\n"
    return

  return


# Keep-Alive
