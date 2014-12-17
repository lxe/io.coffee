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

# This test creates 200 connections to a server and sets the server's
# maxConnections property to 100. The first 100 connections make it through
# and the last 100 connections are rejected.
# TODO: test that the server can accept more connections after it reaches
# its maximum and some are closed.
makeConnection = (index) ->
  c = net.createConnection(common.PORT)
  gotData = false
  c.on "connect", ->
    makeConnection index + 1  if index + 1 < N
    return

  c.on "end", ->
    c.end()
    return

  c.on "data", (b) ->
    gotData = true
    assert.ok 0 < b.length
    return

  c.on "error", (e) ->
    console.error "error %d: %s", index, e
    return

  c.on "close", ->
    console.error "closed %d", index
    closes++
    assert.ok server.maxConnections <= index, index + " was one of the first closed connections " + "but shouldnt have been"  if closes < N / 2
    if closes is N / 2
      cb = undefined
      console.error "calling wait callback."
      cb()  while cb = waits.shift()
      server.close()
    if index < server.maxConnections
      assert.equal true, gotData, index + " didn't get data, but should have"
    else
      assert.equal false, gotData, index + " got data, but shouldn't have"
    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
N = 200
count = 0
closes = 0
waits = []
server = net.createServer((connection) ->
  console.error "connect %d", count++
  connection.write "hello"
  waits.push ->
    connection.end()
    return

  return
)
server.listen common.PORT, ->
  makeConnection 0
  return

server.maxConnections = N / 2
console.error "server.maxConnections = %d", server.maxConnections
process.on "exit", ->
  assert.equal N, closes
  return

