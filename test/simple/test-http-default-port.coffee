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
http = require("http")
https = require("https")
PORT = common.PORT
SSLPORT = common.PORT + 1
assert = require("assert")
hostExpect = "localhost"
fs = require("fs")
path = require("path")
fixtures = path.resolve(__dirname, "../fixtures/keys")
options =
  key: fs.readFileSync(fixtures + "/agent1-key.pem")
  cert: fs.readFileSync(fixtures + "/agent1-cert.pem")

gotHttpsResp = false
gotHttpResp = false
process.on "exit", ->
  assert gotHttpsResp
  assert gotHttpResp
  console.log "ok"
  return

http.globalAgent.defaultPort = PORT
https.globalAgent.defaultPort = SSLPORT
http.createServer((req, res) ->
  assert.equal req.headers.host, hostExpect
  assert.equal req.headers["x-port"], PORT
  res.writeHead 200
  res.end "ok"
  @close()
  return
).listen PORT, ->
  http.get
    host: "localhost"
    headers:
      "x-port": PORT
  , (res) ->
    gotHttpResp = true
    res.resume()
    return

  return

https.createServer(options, (req, res) ->
  assert.equal req.headers.host, hostExpect
  assert.equal req.headers["x-port"], SSLPORT
  res.writeHead 200
  res.end "ok"
  @close()
  return
).listen SSLPORT, ->
  req = https.get(
    host: "localhost"
    rejectUnauthorized: false
    headers:
      "x-port": SSLPORT
  , (res) ->
    gotHttpsResp = true
    res.resume()
    return
  )
  return

