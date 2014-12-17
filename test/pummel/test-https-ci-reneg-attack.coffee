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

# renegotiation limits to test
test = (next) ->
  options =
    cert: fs.readFileSync(common.fixturesDir + "/test_cert.pem")
    key: fs.readFileSync(common.fixturesDir + "/test_key.pem")

  seenError = false
  server = https.createServer(options, (req, res) ->
    conn = req.connection
    conn.on "error", (err) ->
      console.error "Caught exception: " + err
      assert /TLS session renegotiation attack/.test(err)
      conn.destroy()
      seenError = true
      return

    res.end "ok"
    return
  )
  server.listen common.PORT, ->
    
    #child.stdout.pipe(process.stdout);
    #child.stderr.pipe(process.stderr);
    
    # count handshakes, start the attack after the initial handshake is done
    
    # simulate renegotiation attack
    spam = ->
      return  if closed
      child.stdin.write "R\n"
      setTimeout spam, 50
      return
    args = ("s_client -connect 127.0.0.1:" + common.PORT).split(" ")
    child = spawn(common.opensslCli, args)
    child.stdout.resume()
    child.stderr.resume()
    handshakes = 0
    renegs = 0
    child.stderr.on "data", (data) ->
      return  if seenError
      handshakes += (("" + data).match(/verify return:1/g) or []).length
      spam()  if handshakes is 2
      renegs += (("" + data).match(/RENEGOTIATING/g) or []).length
      return

    child.on "exit", ->
      assert.equal renegs, tls.CLIENT_RENEG_LIMIT + 1
      server.close()
      process.nextTick next
      return

    closed = false
    child.stdin.on "error", (err) ->
      switch err.code
        when "ECONNRESET", "EPIPE"
        else
          assert.equal err.code, "ECONNRESET"
      closed = true
      return

    child.stdin.on "close", ->
      closed = true
      return

    return

  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
tls = require("tls")
https = require("https")
fs = require("fs")
unless common.opensslCli
  console.error "Skipping because node compiled without OpenSSL CLI."
  process.exit 0
LIMITS = [
  0
  1
  2
  3
  5
  10
  16
]
(->
  next = ->
    return  if n >= LIMITS.length
    tls.CLIENT_RENEG_LIMIT = LIMITS[n++]
    test next
    return
  n = 0
  next()
  return
)()
