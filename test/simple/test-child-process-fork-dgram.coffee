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

#
# * The purpose of this test is to make sure that when forking a process,
# * sending a fd representing a UDP socket to the child and sending messages
# * to this endpoint, these messages are distributed to the parent and the
# * child process.
# *
# * Because it's not really possible to predict how the messages will be
# * distributed among the parent and the child processes, we keep sending
# * messages until both the parent and the child received at least one
# * message. The worst case scenario is when either one never receives
# * a message. In this case the test runner will timeout after 60 secs
# * and the test will fail.
# 
dgram = require("dgram")
fork = require("child_process").fork
assert = require("assert")
common = require("../common")
if process.platform is "win32"
  console.error "Sending dgram sockets to child processes not supported"
  process.exit 0
if process.argv[2] is "child"
  childCollected = 0
  server = undefined
  process.on "message", removeMe = (msg, clusterServer) ->
    if msg is "server"
      server = clusterServer
      server.on "message", ->
        process.send "gotMessage"
        return

    else if msg is "stop"
      server.close()
      process.removeListener "message", removeMe
    return

else
  server = dgram.createSocket("udp4")
  client = dgram.createSocket("udp4")
  child = fork(__filename, ["child"])
  msg = new Buffer("Some bytes")
  childGotMessage = false
  parentGotMessage = false
  server.on "message", (msg, rinfo) ->
    parentGotMessage = true
    return

  server.on "listening", ->
    child.send "server", server
    child.once "message", (msg) ->
      childGotMessage = true  if msg is "gotMessage"
      return

    sendMessages()
    return

  sendMessages = ->
    timer = setInterval(->
      client.send msg, 0, msg.length, common.PORT, "127.0.0.1", (err) ->
        throw err  if err
        return

      
      #
      #       * Both the parent and the child got at least one message,
      #       * test passed, clean up everyting.
      #       
      if parentGotMessage and childGotMessage
        clearInterval timer
        shutdown()
      return
    , 1)
    return

  shutdown = ->
    child.send "stop"
    server.close()
    client.close()
    return

  server.bind common.PORT, "127.0.0.1"
  process.once "exit", ->
    assert parentGotMessage
    assert childGotMessage
    return

