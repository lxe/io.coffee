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
tls = require("tls")
fs = require("fs")
fs = require("fs")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/ec-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/ec-cert.pem")

cert = null
server = tls.createServer(options, (conn) ->
  conn.end "ok"
  return
).listen(common.PORT, ->
  c = tls.connect(common.PORT,
    rejectUnauthorized: false
  , ->
    cert = c.getPeerCertificate()
    c.destroy()
    server.close()
    return
  )
  return
)
process.on "exit", ->
  assert cert
  assert.equal cert.subject.C, "US"
  return

