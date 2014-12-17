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
cluster = require("cluster")
net = require("net")
if cluster.isWorker
  net.createServer((socket) ->
    socket.end "echo"
    return
  ).listen common.PORT, "127.0.0.1"
  net.createServer((socket) ->
    socket.end "echo"
    return
  ).listen common.PORT + 1, "127.0.0.1"
else if cluster.isMaster
  servers = 2
  
  # test a single TCP server
  testConnection = (port, cb) ->
    socket = net.connect(port, "127.0.0.1", ->
      
      # buffer result
      result = ""
      socket.on "data", (chunk) ->
        result += chunk
        return

      
      # check result
      socket.on "end", ->
        cb result is "echo"
        return

      return
    )
    return

  
  # test both servers created in the cluster
  testCluster = (cb) ->
    done = 0
    i = 0
    l = servers

    while i < l
      testConnection common.PORT + i, (success) ->
        assert.ok success
        done += 1
        cb()  if done is servers
        return

      i++
    return

  
  # start two workers and execute callback when both is listening
  startCluster = (cb) ->
    workers = 8
    online = 0
    i = 0
    l = workers

    while i < l
      worker = cluster.fork()
      worker.on "listening", ->
        online += 1
        cb()  if online is workers * servers
        return

      i++
    return

  results =
    start: 0
    test: 0
    disconnect: 0

  test = (again) ->
    
    #1. start cluster
    startCluster ->
      results.start += 1
      
      #2. test cluster
      testCluster ->
        results.test += 1
        
        #3. disconnect cluster
        cluster.disconnect ->
          results.disconnect += 1
          
          # run test again to confirm cleanup
          test()  if again
          return

        return

      return

    return

  test true
  process.once "exit", ->
    assert.equal results.start, 2
    assert.equal results.test, 2
    assert.equal results.disconnect, 2
    return

