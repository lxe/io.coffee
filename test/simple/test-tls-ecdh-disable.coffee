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
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
assert = require("assert")
exec = require("child_process").exec
tls = require("tls")
fs = require("fs")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")
  ciphers: "ECDHE-RSA-RC4-SHA"
  ecdhCurve: false

nconns = 0
process.on "exit", ->
  assert.equal nconns, 0
  return

server = tls.createServer(options, (conn) ->
  conn.end()
  nconns++
  return
)
server.listen common.PORT, "127.0.0.1", ->
  cmd = common.opensslCli + " s_client -cipher " + options.ciphers + " -connect 127.0.0.1:" + common.PORT
  exec cmd, (err, stdout, stderr) ->
    
    # Old versions of openssl will still exit with 0 so we
    # can't just check if err is not null.
    assert.notEqual stderr.indexOf("handshake failure"), -1
    server.close()
    return

  return

