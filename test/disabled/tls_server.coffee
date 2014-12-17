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
assert = require("assert")
util = require("util")
net = require("net")
fs = require("fs")
crypto = require("crypto")
keyPem = fs.readFileSync(common.fixturesDir + "/cert.pem")
certPem = fs.readFileSync(common.fixturesDir + "/cert.pem")
try
  credentials = crypto.createCredentials(
    key: keyPem
    cert: certPem
  )
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
i = 0
server = net.createServer((connection) ->
  connection.setSecure credentials
  connection.setEncoding "binary"
  connection.on "secure", ->

  
  #console.log('Secure');
  connection.on "data", (chunk) ->
    console.log "recved: " + JSON.stringify(chunk)
    connection.write "HTTP/1.0 200 OK\r\n" + "Content-type: text/plain\r\n" + "Content-length: 9\r\n" + "\r\n" + "OK : " + i + "\r\n\r\n"
    i = i + 1
    connection.end()
    return

  connection.on "end", ->
    connection.end()
    return

  return
)
server.listen 4443
