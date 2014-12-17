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
assert = require("assert")
cluster = require("cluster")
net = require("net")
destroyed = undefined
success = undefined
worker = undefined
server = undefined

# workers do not exit on disconnect, they exit under normal node rules: when
# they have nothing keeping their loop alive, like an active connection
#
# test this by:
#
# 1 creating a server, so worker can make a connection to something
# 2 disconnecting worker
# 3 wait to confirm it did not exit
# 4 destroy connection
# 5 confirm it does exit
if cluster.isMaster
  
  # worker should not exit while it has a connection
  server = net.createServer((conn) ->
    server.close()
    worker.disconnect()
    worker.once("disconnect", ->
      setTimeout (->
        conn.destroy()
        destroyed = true
        return
      ), 1000
      return
    ).once "exit", ->
      assert destroyed, "worker exited before connection destroyed"
      success = true
      return

    return
  ).listen(0, ->
    port = @address().port
    worker = cluster.fork().on("online", ->
      @send port: port
      return
    )
    return
  )
  process.on "exit", ->
    assert success
    return

else
  process.on "message", (msg) ->
    
    # we shouldn't exit, not while a network connection exists
    net.connect msg.port
    return

