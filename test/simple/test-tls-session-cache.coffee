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
doTest = (testOptions, callback) ->
  assert = require("assert")
  tls = require("tls")
  fs = require("fs")
  join = require("path").join
  spawn = require("child_process").spawn
  keyFile = join(common.fixturesDir, "agent.key")
  certFile = join(common.fixturesDir, "agent.crt")
  key = fs.readFileSync(keyFile)
  cert = fs.readFileSync(certFile)
  options =
    key: key
    cert: cert
    ca: [cert]
    requestCert: true

  requestCount = 0
  resumeCount = 0
  session = undefined
  server = tls.createServer(options, (cleartext) ->
    cleartext.on "error", (er) ->
      
      # We're ok with getting ECONNRESET in this test, but it's
      # timing-dependent, and thus unreliable. Any other errors
      # are just failures, though.
      throw er  if er.code isnt "ECONNRESET"
      return

    ++requestCount
    cleartext.end()
    return
  )
  server.on "newSession", (id, data, cb) ->
    
    # Emulate asynchronous store
    setTimeout (->
      assert.ok not session
      session =
        id: id
        data: data

      cb()
      return
    ), 1000
    return

  server.on "resumeSession", (id, callback) ->
    ++resumeCount
    assert.ok session
    assert.equal session.id.toString("hex"), id.toString("hex")
    
    # Just to check that async really works there
    setTimeout (->
      callback null, session.data
      return
    ), 100
    return

  server.listen common.PORT, ->
    client = spawn(common.opensslCli, [
      "s_client"
      "-tls1"
      "-connect"
      "localhost:" + common.PORT
      "-servername"
      "ohgod"
      "-key"
      join(common.fixturesDir, "agent.key")
      "-cert"
      join(common.fixturesDir, "agent.crt")
      "-reconnect"
    ].concat((if testOptions.tickets then [] else "-no_ticket")),
      stdio: [
        0
        1
        "pipe"
      ]
    )
    err = ""
    client.stderr.setEncoding "utf8"
    client.stderr.on "data", (chunk) ->
      err += chunk
      return

    client.on "exit", (code) ->
      console.error "done"
      assert.equal code, 0
      server.close ->
        setTimeout callback, 100
        return

      return

    return

  process.on "exit", ->
    if testOptions.tickets
      assert.equal requestCount, 6
      assert.equal resumeCount, 0
    else
      
      # initial request + reconnect requests (5 times)
      assert.ok session
      assert.equal requestCount, 6
      assert.equal resumeCount, 5
    return

  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
doTest
  tickets: false
, ->
  doTest
    tickets: true
  , ->
    console.error "all done"
    return

  return

