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
loadDHParam = (n) ->
  path = common.fixturesDir
  path += "/keys"  if n isnt "error"
  fs.readFileSync path + "/dh" + n + ".pem"
test = (keylen, expectedCipher, cb) ->
  options =
    key: key
    cert: cert
    dhparam: loadDHParam(keylen)

  server = tls.createServer(options, (conn) ->
    conn.end()
    return
  )
  server.on "close", (err) ->
    assert not err
    cb()  if cb
    return

  server.listen common.PORT, "127.0.0.1", ->
    args = [
      "s_client"
      "-connect"
      "127.0.0.1:" + common.PORT
      "-cipher"
      ciphers
    ]
    client = spawn(common.opensslCli, args)
    out = ""
    client.stdout.setEncoding "utf8"
    client.stdout.on "data", (d) ->
      out += d
      return

    client.stdout.on "end", ->
      
      # DHE key length can be checked -brief option in s_client but it
      # is only supported in openssl 1.0.2 so we cannot check it.
      reg = new RegExp("Cipher    : " + expectedCipher)
      if reg.test(out)
        nsuccess++
        server.close()
      return

    return

  return
test512 = ->
  test 512, "DHE-RSA-AES128-SHA256", test1024
  ntests++
  return
test1024 = ->
  test 1024, "DHE-RSA-AES128-SHA256", test2048
  ntests++
  return
test2048 = ->
  test 2048, "DHE-RSA-AES128-SHA256", testError
  ntests++
  return
testError = ->
  test "error", "ECDHE-RSA-AES128-SHA256", null
  ntests++
  return
common = require("../common")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
assert = require("assert")
spawn = require("child_process").spawn
tls = require("tls")
fs = require("fs")
key = fs.readFileSync(common.fixturesDir + "/keys/agent2-key.pem")
cert = fs.readFileSync(common.fixturesDir + "/keys/agent2-cert.pem")
nsuccess = 0
ntests = 0
ciphers = "DHE-RSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"
test512()
process.on "exit", ->
  assert.equal ntests, nsuccess
  return

