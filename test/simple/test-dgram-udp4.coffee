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
fs = require("fs")
dgram = require("dgram")
server = undefined
client = undefined
server_port = 20989
message_to_send = "A message to send"
timer = undefined
server = dgram.createSocket("udp4")
server.on "message", (msg, rinfo) ->
  console.log "server got: " + msg + " from " + rinfo.address + ":" + rinfo.port
  assert.strictEqual rinfo.address, "127.0.0.1"
  assert.strictEqual msg.toString(), message_to_send.toString()
  server.send msg, 0, msg.length, rinfo.port, rinfo.address
  return

server.on "listening", ->
  address = server.address()
  console.log "server is listening on " + address.address + ":" + address.port
  client = dgram.createSocket("udp4")
  client.on "message", (msg, rinfo) ->
    console.log "client got: " + msg + " from " + rinfo.address + ":" + address.port
    assert.strictEqual rinfo.address, "127.0.0.1"
    assert.strictEqual rinfo.port, server_port
    assert.strictEqual msg.toString(), message_to_send.toString()
    client.close()
    server.close()
    return

  client.send message_to_send, 0, message_to_send.length, server_port, "localhost", (err) ->
    if err
      console.log "Caught error in client send."
      throw err
    return

  client.on "close", ->
    clearTimeout timer  if server.fd is null
    return

  return

server.on "close", ->
  clearTimeout timer  if client.fd is null
  return

server.bind server_port
timer = setTimeout(->
  throw new Error("Timeout")return
, 200)
