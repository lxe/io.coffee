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
createServer = ->
  id = serverCount++
  server = tls.createServer(
    key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
    cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")
    ticketKeys: keys
  , (c) ->
    serverLog.push id
    c.end()
    return
  )
  server

# Create one TCP server and balance sockets to multiple TLS server instances
start = (callback) ->
  connect = ->
    s = tls.connect(common.PORT,
      session: sess
      rejectUnauthorized: false
    , ->
      sess = s.getSession() or sess
      ticketLog.push s.getTLSTicket().toString("hex")
      return
    )
    s.on "close", ->
      if --left is 0
        callback()
      else
        connect()
      return

    return
  sess = null
  left = servers.length
  connect()
  return
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
assert = require("assert")
fs = require("fs")
net = require("net")
tls = require("tls")
crypto = require("crypto")
common = require("../common")
keys = crypto.randomBytes(48)
serverLog = []
ticketLog = []
serverCount = 0
servers = [
  createServer()
  createServer()
  createServer()
  createServer()
  createServer()
  createServer()
]
shared = net.createServer((c) ->
  servers.shift().emit "connection", c
  return
).listen(common.PORT, ->
  start ->
    shared.close()
    return

  return
)
process.on "exit", ->
  assert.equal ticketLog.length, serverLog.length
  i = 0

  while i < serverLog.length - 1
    assert.notEqual serverLog[i], serverLog[i + 1]
    assert.equal ticketLog[i], ticketLog[i + 1]
    i++
  return

