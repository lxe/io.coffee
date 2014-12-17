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
#

# simple/test-tls-securepair-client
test1 = ->
  test "agent.key", "agent.crt", null, test2
  return

# simple/test-tls-ext-key-usage
test2 = ->
  check = (pair) ->
    
    # "TLS Web Client Authentication"
    assert.equal pair.cleartext.getPeerCertificate().ext_key_usage.length, 1
    assert.equal pair.cleartext.getPeerCertificate().ext_key_usage[0], "1.3.6.1.5.5.7.3.2"
    return
  test "keys/agent4-key.pem", "keys/agent4-cert.pem", check
  return
test = (keyfn, certfn, check, next) ->
  
  # FIXME: Avoid the common PORT as this test currently hits a C-level
  # assertion error with node_g. The program aborts without HUPing
  # the openssl s_server thus causing many tests to fail with
  # EADDRINUSE.
  
  # Give s_server half a second to start up.
  
  # End the current SSL connection and exit.
  # See s_server(1ssl).
  startClient = ->
    s = new net.Stream()
    sslcontext = tls.createSecureContext(
      key: key
      cert: cert
    )
    sslcontext.context.setCiphers "RC4-SHA:AES128-SHA:AES256-SHA"
    pair = tls.createSecurePair(sslcontext, false)
    assert.ok pair.encrypted.writable
    assert.ok pair.cleartext.writable
    pair.encrypted.pipe s
    s.pipe pair.encrypted
    s.connect PORT
    s.on "connect", ->
      console.log "client connected"
      return

    pair.on "secure", ->
      console.log "client: connected+secure!"
      console.log "client pair.cleartext.getPeerCertificate(): %j", pair.cleartext.getPeerCertificate()
      console.log "client pair.cleartext.getCipher(): %j", pair.cleartext.getCipher()
      check pair  if check
      setTimeout (->
        pair.cleartext.write "hello\r\n", ->
          gotWriteCallback = true
          return

        return
      ), 500
      return

    pair.cleartext.on "data", (d) ->
      console.log "cleartext: %s", d.toString()
      return

    s.on "close", ->
      console.log "client close"
      return

    pair.encrypted.on "error", (err) ->
      console.log "encrypted error: " + err
      return

    s.on "error", (err) ->
      console.log "socket error: " + err
      return

    pair.on "error", (err) ->
      console.log "secure error: " + err
      return

    return
  PORT = common.PORT + 5
  connections = 0
  keyfn = join(common.fixturesDir, keyfn)
  key = fs.readFileSync(keyfn).toString()
  certfn = join(common.fixturesDir, certfn)
  cert = fs.readFileSync(certfn).toString()
  server = spawn(common.opensslCli, [
    "s_server"
    "-accept"
    PORT
    "-cert"
    certfn
    "-key"
    keyfn
  ])
  server.stdout.pipe process.stdout
  server.stderr.pipe process.stdout
  state = "WAIT-ACCEPT"
  serverStdoutBuffer = ""
  server.stdout.setEncoding "utf8"
  server.stdout.on "data", (s) ->
    serverStdoutBuffer += s
    console.error state
    switch state
      when "WAIT-ACCEPT"
        if /ACCEPT/g.test(serverStdoutBuffer)
          setTimeout startClient, 500
          state = "WAIT-HELLO"
      when "WAIT-HELLO"
        if /hello/g.test(serverStdoutBuffer)
          server.stdin.write "Q"
          state = "WAIT-SERVER-CLOSE"
      else

  timeout = setTimeout(->
    server.kill()
    process.exit 1
    return
  , 5000)
  gotWriteCallback = false
  serverExitCode = -1
  server.on "exit", (code) ->
    serverExitCode = code
    clearTimeout timeout
    next()  if next
    return

  process.on "exit", ->
    assert.equal 0, serverExitCode
    assert.equal "WAIT-SERVER-CLOSE", state
    assert.ok gotWriteCallback
    return

  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
join = require("path").join
net = require("net")
assert = require("assert")
fs = require("fs")
crypto = require("crypto")
tls = require("tls")
exec = require("child_process").exec
spawn = require("child_process").spawn
test1()
