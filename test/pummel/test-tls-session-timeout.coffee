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

# This test consists of three TLS requests --
# * The first one should result in a new connection because we don't have
#   a valid session ticket.
# * The second one should result in connection resumption because we used
#   the session ticket we saved from the first connection.
# * The third one should result in a new connection because the ticket
#   that we used has expired by now.
doTest = ->
  assert = require("assert")
  tls = require("tls")
  fs = require("fs")
  join = require("path").join
  spawn = require("child_process").spawn
  SESSION_TIMEOUT = 1
  keyFile = join(common.fixturesDir, "agent.key")
  certFile = join(common.fixturesDir, "agent.crt")
  key = fs.readFileSync(keyFile)
  cert = fs.readFileSync(certFile)
  options =
    key: key
    cert: cert
    ca: [cert]
    sessionTimeout: SESSION_TIMEOUT

  
  # We need to store a sample session ticket in the fixtures directory because
  # `s_client` behaves incorrectly if we do not pass in both the `-sess_in`
  # and the `-sess_out` flags, and the `-sess_in` argument must point to a
  # file containing a proper serialization of a session ticket.
  # To avoid a source control diff, we copy the ticket to a temporary file.
  sessionFileName = (->
    ticketFileName = "tls-session-ticket.txt"
    fixturesPath = join(common.fixturesDir, ticketFileName)
    tmpPath = join(common.tmpDir, ticketFileName)
    fs.writeFileSync tmpPath, fs.readFileSync(fixturesPath)
    tmpPath
  ())
  
  # Expects a callback -- cb(connectionType : enum ['New'|'Reused'])
  Client = (cb) ->
    flags = [
      "s_client"
      "-connect"
      "localhost:" + common.PORT
      "-sess_in"
      sessionFileName
      "-sess_out"
      sessionFileName
    ]
    client = spawn(common.opensslCli, flags,
      stdio: [
        "ignore"
        "pipe"
        "ignore"
      ]
    )
    clientOutput = ""
    client.stdout.on "data", (data) ->
      clientOutput += data.toString()
      return

    client.on "exit", (code) ->
      connectionType = undefined
      grepConnectionType = (line) ->
        matches = line.match(/(New|Reused), /)
        if matches
          connectionType = matches[1]
          true

      lines = clientOutput.split("\n")
      throw new Error("unexpected output from openssl client")  unless lines.some(grepConnectionType)
      cb connectionType
      return

    return

  server = tls.createServer(options, (cleartext) ->
    cleartext.on "error", (er) ->
      throw er  if er.code isnt "ECONNRESET"
      return

    cleartext.end()
    return
  )
  server.listen common.PORT, ->
    Client (connectionType) ->
      assert connectionType is "New"
      Client (connectionType) ->
        assert connectionType is "Reused"
        setTimeout (->
          Client (connectionType) ->
            assert connectionType is "New"
            server.close()
            return

          return
        ), (SESSION_TIMEOUT + 1) * 1000
        return

      return

    return

  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
doTest()
