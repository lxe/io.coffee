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
master = ->
  
  # Fork 4 workers.
  
  # Wait until all workers are listening.
  
  # Start sending messages.
  
  # Set up event handlers for every worker. Each worker sends a message when
  # it has received the expected number of packets. After that it disconnects.
  setupWorker = (worker) ->
    received = 0
    worker.on "message", (msg) ->
      received = msg.received
      console.log "worker %d received %d packets", worker.id, received
      return

    worker.on "disconnect", ->
      assert received is PACKETS_PER_WORKER
      console.log "worker %d disconnected", worker.id
      return

    return
  listening = 0
  i = 0

  while i < NUM_WORKERS
    cluster.fork()
    i++
  cluster.on "listening", ->
    doSend = ->
      socket.send buf, 0, buf.length, common.PORT, "127.0.0.1", afterSend
      return
    afterSend = ->
      sent++
      if sent < NUM_WORKERS * PACKETS_PER_WORKER
        doSend()
      else
        console.log "master sent %d packets", sent
        socket.close()
      return
    return  if ++listening < NUM_WORKERS
    buf = new Buffer("hello world")
    socket = dgram.createSocket("udp4")
    sent = 0
    doSend()
    return

  for key of cluster.workers
    setupWorker cluster.workers[key]  if cluster.workers.hasOwnProperty(key)
  return
worker = ->
  received = 0
  
  # Create udp socket and start listening.
  socket = dgram.createSocket("udp4")
  socket.on "message", (data, info) ->
    received++
    
    # Every 10 messages, notify the master.
    if received is PACKETS_PER_WORKER
      process.send received: received
      process.disconnect()
    return

  socket.bind common.PORT
  return
NUM_WORKERS = 4
PACKETS_PER_WORKER = 10
assert = require("assert")
cluster = require("cluster")
common = require("../common")
dgram = require("dgram")
if process.platform is "win32"
  console.warn "dgram clustering is currently not supported on windows."
  process.exit 0
if cluster.isMaster
  master()
else
  worker()
