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

# test that errors propagated from cluster children are properly received in their master
# creates an EADDRINUSE condition by also forking a child process to listen on a socket
common = require("../common")
assert = require("assert")
cluster = require("cluster")
fork = require("child_process").fork
fs = require("fs")
net = require("net")
if cluster.isMaster
  worker = cluster.fork()
  gotError = 0
  worker.on "message", (err) ->
    gotError++
    console.log err
    assert.strictEqual "EADDRINUSE", err.code
    worker.disconnect()
    return

  process.on "exit", ->
    console.log "master exited"
    try
      fs.unlinkSync common.PIPE
    assert.equal gotError, 1
    return

else
  cp = fork(common.fixturesDir + "/listen-on-socket-and-exit.js",
    stdio: "inherit"
  )
  
  # message from the child indicates it's ready and listening
  cp.on "message", ->
    server = net.createServer().listen(common.PIPE, ->
      console.log "parent listening, should not be!"
      return
    )
    server.on "error", (err) ->
      console.log "parent error, ending"
      
      # message to child process tells it to exit
      cp.send "end"
      
      # propagate error to parent
      process.send err
      return

    return

