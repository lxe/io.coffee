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
mkListener = ->
  receivedMessages = []
  listenSocket = dgram.createSocket("udp4")
  listenSocket.addMembership LOCAL_BROADCAST_HOST
  listenSocket.on "message", (buf, rinfo) ->
    console.error "received %s from %j", util.inspect(buf.toString()), rinfo
    receivedMessages.push buf
    if receivedMessages.length is sendMessages.length
      listenSocket.dropMembership LOCAL_BROADCAST_HOST
      process.nextTick -> # TODO should be changed to below.
        # listenSocket.dropMembership(LOCAL_BROADCAST_HOST, function() {
        listenSocket.close()
        return

    return

  listenSocket.on "close", ->
    console.error "listenSocket closed -- checking received messages"
    count = 0
    receivedMessages.forEach (buf) ->
      i = 0

      while i < sendMessages.length
        if buf.toString() is sendMessages[i].toString()
          count++
          break
        ++i
      return

    console.error "count %d", count
    return

  
  #assert.strictEqual(count, sendMessages.length);
  listenSocket.on "listening", ->
    listenSockets.push listenSocket
    sendSocket.sendNext()  if listenSockets.length is 3
    return

  listenSocket.bind common.PORT
  return
common = require("../common")
assert = require("assert")
dgram = require("dgram")
util = require("util")
assert = require("assert")
Buffer = require("buffer").Buffer
LOCAL_BROADCAST_HOST = "224.0.0.1"
sendMessages = [
  new Buffer("First message to send")
  new Buffer("Second message to send")
  new Buffer("Third message to send")
  new Buffer("Fourth message to send")
]
listenSockets = []
sendSocket = dgram.createSocket("udp4")
sendSocket.on "close", ->
  console.error "sendSocket closed"
  return

sendSocket.setBroadcast true
sendSocket.setMulticastTTL 1
sendSocket.setMulticastLoopback true
i = 0
sendSocket.sendNext = ->
  buf = sendMessages[i++]
  unless buf
    try
      sendSocket.close()
    return
  sendSocket.send buf, 0, buf.length, common.PORT, LOCAL_BROADCAST_HOST, (err) ->
    throw err  if err
    console.error "sent %s to %s", util.inspect(buf.toString()), LOCAL_BROADCAST_HOST + common.PORT
    process.nextTick sendSocket.sendNext
    return

  return

listener_count = 0
mkListener()
mkListener()
mkListener()
