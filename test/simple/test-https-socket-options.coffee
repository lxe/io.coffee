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
http = require("http")
https = require("https")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

body = "hello world\n"

# Try first with http server
server_http = http.createServer((req, res) ->
  console.log "got HTTP request"
  res.writeHead 200,
    "content-type": "text/plain"

  res.end body
  return
)
server_http.listen common.PORT, ->
  req = http.request(
    port: common.PORT
    rejectUnauthorized: false
  , (res) ->
    server_http.close()
    res.resume()
    return
  )
  
  # These methods should exist on the request and get passed down to the socket
  req.setNoDelay true
  req.setTimeout 1000, ->

  req.setSocketKeepAlive true, 1000
  req.end()
  return


# Then try https server (requires functions to be mirroed in tls.js's CryptoStream)
server_https = https.createServer(options, (req, res) ->
  console.log "got HTTPS request"
  res.writeHead 200,
    "content-type": "text/plain"

  res.end body
  return
)
server_https.listen common.PORT + 1, ->
  req = https.request(
    port: common.PORT + 1
    rejectUnauthorized: false
  , (res) ->
    server_https.close()
    res.resume()
    return
  )
  
  # These methods should exist on the request and get passed down to the socket
  req.setNoDelay true
  req.setTimeout 1000, ->

  req.setSocketKeepAlive true, 1000
  req.end()
  return

