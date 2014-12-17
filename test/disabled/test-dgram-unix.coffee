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

# TODO use common.tmpDir here
serverPath = "/tmp/dgram_server_sock"
clientPath = "/tmp/dgram_client_sock"
msgToSend = new Buffer("A message to send")
server = dgram.createSocket("unix_dgram")
server.on "message", (msg, rinfo) ->
  console.log "server got: " + msg + " from " + rinfo.address
  assert.strictEqual rinfo.address, clientPath
  assert.strictEqual msg.toString(), msgToSend.toString()
  server.send msg, 0, msg.length, rinfo.address
  return

server.on "listening", ->
  console.log "server is listening"
  client = dgram.createSocket("unix_dgram")
  client.on "message", (msg, rinfo) ->
    console.log "client got: " + msg + " from " + rinfo.address
    assert.strictEqual rinfo.address, serverPath
    assert.strictEqual msg.toString(), msgToSend.toString()
    client.close()
    server.close()
    return

  client.on "listening", ->
    console.log "client is listening"
    client.send msgToSend, 0, msgToSend.length, serverPath, (err, bytes) ->
      if err
        console.log "Caught error in client send."
        throw err
      console.log "client wrote " + bytes + " bytes."
      assert.strictEqual bytes, msgToSend.length
      return

    return

  client.bind clientPath
  return

server.bind serverPath
