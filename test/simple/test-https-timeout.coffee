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
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
fs = require("fs")
exec = require("child_process").exec
https = require("https")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")


# a server that never replies
server = https.createServer(options, ->
  console.log "Got request.  Doing nothing."
  return
).listen(common.PORT, ->
  req = https.request(
    host: "localhost"
    port: common.PORT
    path: "/"
    method: "GET"
    rejectUnauthorized: false
  )
  req.setTimeout 10
  req.end()
  req.on "response", (res) ->
    console.log "got response"
    return

  req.on "socket", ->
    console.log "got a socket"
    req.socket.on "connect", ->
      console.log "socket connected"
      return

    setTimeout (->
      throw new Error("Did not get timeout event")return
    ), 200
    return

  req.on "timeout", ->
    console.log "timeout occurred outside"
    req.destroy()
    server.close()
    process.exit 0
    return

  return
)
