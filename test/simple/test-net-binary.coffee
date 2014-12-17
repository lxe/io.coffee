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
net = require("net")
binaryString = ""
i = 255

while i >= 0
  s = "'\\" + i.toString(8) + "'"
  S = eval(s)
  common.error s + " " + JSON.stringify(S) + " " + JSON.stringify(String.fromCharCode(i)) + " " + S.charCodeAt(0)
  assert.ok S.charCodeAt(0) is i
  assert.ok S is String.fromCharCode(i)
  binaryString += S
  i--

# safe constructor
echoServer = net.Server((connection) ->
  console.error "SERVER got connection"
  connection.setEncoding "binary"
  connection.on "data", (chunk) ->
    common.error "SERVER recved: " + JSON.stringify(chunk)
    connection.write chunk, "binary"
    return

  connection.on "end", ->
    console.error "SERVER ending"
    connection.end()
    return

  return
)
echoServer.listen common.PORT
recv = ""
echoServer.on "listening", ->
  console.error "SERVER listening"
  j = 0
  c = net.createConnection(port: common.PORT)
  c.setEncoding "binary"
  c.on "data", (chunk) ->
    console.error "CLIENT data %j", chunk
    n = j + chunk.length
    while j < n and j < 256
      common.error "CLIENT write " + j
      c.write String.fromCharCode(j), "binary"
      j++
    if j is 256
      console.error "CLIENT ending"
      c.end()
    recv += chunk
    return

  c.on "connect", ->
    console.error "CLIENT connected, writing"
    c.write binaryString, "binary"
    return

  c.on "close", ->
    console.error "CLIENT closed"
    console.dir recv
    echoServer.close()
    return

  c.on "finish", ->
    console.error "CLIENT finished"
    return

  return

process.on "exit", ->
  console.log "recv: " + JSON.stringify(recv)
  assert.equal 2 * 256, recv.length
  a = recv.split("")
  first = a.slice(0, 256).reverse().join("")
  console.log "first: " + JSON.stringify(first)
  second = a.slice(256, 2 * 256).join("")
  console.log "second: " + JSON.stringify(second)
  assert.equal first, second
  return

