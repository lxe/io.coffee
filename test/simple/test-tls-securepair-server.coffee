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
log = (a) ->
  console.error "***server*** " + a
  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
assert = require("assert")
join = require("path").join
net = require("net")
fs = require("fs")
tls = require("tls")
spawn = require("child_process").spawn
connections = 0
key = fs.readFileSync(join(common.fixturesDir, "agent.key")).toString()
cert = fs.readFileSync(join(common.fixturesDir, "agent.crt")).toString()
server = net.createServer((socket) ->
  connections++
  log "connection fd=" + socket.fd
  sslcontext = tls.createSecureContext(
    key: key
    cert: cert
  )
  sslcontext.context.setCiphers "RC4-SHA:AES128-SHA:AES256-SHA"
  pair = tls.createSecurePair(sslcontext, true)
  assert.ok pair.encrypted.writable
  assert.ok pair.cleartext.writable
  pair.encrypted.pipe socket
  socket.pipe pair.encrypted
  log "i set it secure"
  pair.on "secure", ->
    log "connected+secure!"
    pair.cleartext.write "hello\r\n"
    log pair.cleartext.getPeerCertificate()
    log pair.cleartext.getCipher()
    return

  pair.cleartext.on "data", (data) ->
    log "read bytes " + data.length
    pair.cleartext.write data
    return

  socket.on "end", ->
    log "socket end"
    return

  pair.cleartext.on "error", (err) ->
    log "got error: "
    log err
    log err.stack
    socket.destroy()
    return

  pair.encrypted.on "error", (err) ->
    log "encrypted error: "
    log err
    log err.stack
    socket.destroy()
    return

  socket.on "error", (err) ->
    log "socket error: "
    log err
    log err.stack
    socket.destroy()
    return

  socket.on "close", (err) ->
    log "socket closed"
    return

  pair.on "error", (err) ->
    log "secure error: "
    log err
    log err.stack
    socket.destroy()
    return

  return
)
gotHello = false
sentWorld = false
gotWorld = false
opensslExitCode = -1
server.listen common.PORT, ->
  
  # To test use: openssl s_client -connect localhost:8000
  client = spawn(common.opensslCli, [
    "s_client"
    "-connect"
    "127.0.0.1:" + common.PORT
  ])
  out = ""
  client.stdout.setEncoding "utf8"
  client.stdout.on "data", (d) ->
    out += d
    if not gotHello and /hello/.test(out)
      gotHello = true
      client.stdin.write "world\r\n"
      sentWorld = true
    if not gotWorld and /world/.test(out)
      gotWorld = true
      client.stdin.end()
    return

  client.stdout.pipe process.stdout,
    end: false

  client.on "exit", (code) ->
    opensslExitCode = code
    server.close()
    return

  return

process.on "exit", ->
  assert.equal 1, connections
  assert.ok gotHello
  assert.ok sentWorld
  assert.ok gotWorld
  assert.equal 0, opensslExitCode
  return

