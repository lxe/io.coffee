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
verify = ->
  console.log "verify"
  verified = crypto.createVerify("RSA-SHA1").update("Test").verify(certPem, "asdfasdfas", "base64")
  return
common = require("../common")
assert = require("assert")
try
  crypto = require("crypto")
  tls = require("tls")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
crypto.DEFAULT_ENCODING = "buffer"
fs = require("fs")
certPem = fs.readFileSync(common.fixturesDir + "/test_cert.pem", "ascii")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

canSend = true
server = tls.Server(options, (socket) ->
  setImmediate ->
    console.log "sending"
    verify()
    setImmediate ->
      socket.destroy()
      return

    return

  return
)
client = undefined
server.listen common.PORT, ->
  client = tls.connect(
    port: common.PORT
    rejectUnauthorized: false
  , ->
    verify()
    return
  ).on("data", (data) ->
    console.log data
    return
  ).on("error", (err) ->
    throw errreturn
  ).on("close", ->
    server.close()
    return
  ).resume()
  return

server.unref()
