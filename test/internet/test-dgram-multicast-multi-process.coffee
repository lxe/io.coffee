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
dgram = require("dgram")
util = require("util")
assert = require("assert")
Buffer = require("buffer").Buffer
fork = require("child_process").fork
LOCAL_BROADCAST_HOST = "224.0.0.114"
TIMEOUT = 5000
messages = [
  new Buffer("First message to send")
  new Buffer("Second message to send")
  new Buffer("Third message to send")
  new Buffer("Fourth message to send")
]
if process.argv[2] isnt "child"
  
  #exit the test if it doesn't succeed within TIMEOUT
  
  #launch child processes
  
  #handle the death of workers
  
  # don't consider this the true death if the
  # worker has finished successfully
  
  # or if the exit code is 0
  
  #all child process are listening, so start sending
  
  # FIXME a libuv limitation makes it necessary to bind()
  # before calling any of the set*() functions - the bind()
  # call is what creates the actual socket...
  
  # The socket is actually created async now
  killChildren = (children) ->
    Object.keys(children).forEach (key) ->
      child = children[key]
      child.kill()
      return

    return
  workers = {}
  listeners = 3
  listening = 0
  dead = 0
  i = 0
  done = 0
  timer = null
  timer = setTimeout(->
    console.error "[PARENT] Responses were not received within %d ms.", TIMEOUT
    console.error "[PARENT] Fail"
    killChildren workers
    process.exit 1
    return
  , TIMEOUT)
  x = 0

  while x < listeners
    (->
      worker = fork(process.argv[1], ["child"])
      workers[worker.pid] = worker
      worker.messagesReceived = []
      worker.on "exit", (code, signal) ->
        return  if worker.isDone or code is 0
        dead += 1
        console.error "[PARENT] Worker %d died. %d dead of %d", worker.pid, dead, listeners
        if dead is listeners
          console.error "[PARENT] All workers have died."
          console.error "[PARENT] Fail"
          killChildren workers
          process.exit 1
        return

      worker.on "message", (msg) ->
        if msg.listening
          listening += 1
          sendSocket.sendNext()  if listening is listeners
        else if msg.message
          worker.messagesReceived.push msg.message
          if worker.messagesReceived.length is messages.length
            done += 1
            worker.isDone = true
            console.error "[PARENT] %d received %d messages total.", worker.pid, worker.messagesReceived.length
          if done is listeners
            console.error "[PARENT] All workers have received the " + "required number of messages. Will now compare."
            Object.keys(workers).forEach (pid) ->
              worker = workers[pid]
              count = 0
              worker.messagesReceived.forEach (buf) ->
                i = 0

                while i < messages.length
                  if buf.toString() is messages[i].toString()
                    count++
                    break
                  ++i
                return

              console.error "[PARENT] %d received %d matching messages.", worker.pid, count
              assert.equal count, messages.length, "A worker received an invalid multicast message"
              return

            clearTimeout timer
            console.error "[PARENT] Success"
            killChildren workers
        return

      return
    ) x
    x++
  sendSocket = dgram.createSocket("udp4")
  sendSocket.bind()
  sendSocket.on "listening", ->
    sendSocket.setTTL 1
    sendSocket.setBroadcast true
    sendSocket.setMulticastTTL 1
    sendSocket.setMulticastLoopback true
    return

  sendSocket.on "close", ->
    console.error "[PARENT] sendSocket closed"
    return

  sendSocket.sendNext = ->
    buf = messages[i++]
    unless buf
      try
        sendSocket.close()
      return
    sendSocket.send buf, 0, buf.length, common.PORT, LOCAL_BROADCAST_HOST, (err) ->
      throw err  if err
      console.error "[PARENT] sent %s to %s:%s", util.inspect(buf.toString()), LOCAL_BROADCAST_HOST, common.PORT
      process.nextTick sendSocket.sendNext
      return

    return
if process.argv[2] is "child"
  receivedMessages = []
  listenSocket = dgram.createSocket(
    type: "udp4"
    reuseAddr: true
  )
  listenSocket.on "message", (buf, rinfo) ->
    console.error "[CHILD] %s received %s from %j", process.pid, util.inspect(buf.toString()), rinfo
    receivedMessages.push buf
    process.send message: buf.toString()
    if receivedMessages.length is messages.length
      listenSocket.dropMembership LOCAL_BROADCAST_HOST
      process.nextTick -> # TODO should be changed to below.
        # listenSocket.dropMembership(LOCAL_BROADCAST_HOST, function() {
        listenSocket.close()
        return

    return

  listenSocket.on "close", ->
    
    #HACK: Wait to exit the process to ensure that the parent
    #process has had time to receive all messages via process.send()
    #This may be indicitave of some other issue.
    setTimeout (->
      process.exit()
      return
    ), 1000
    return

  listenSocket.on "listening", ->
    process.send listening: true
    return

  listenSocket.bind common.PORT
  listenSocket.on "listening", ->
    listenSocket.addMembership LOCAL_BROADCAST_HOST
    return

