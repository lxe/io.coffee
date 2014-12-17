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
makeConnection = ->
  client = new TCP()
  req = new TCPConnectWrap()
  err = client.connect(req, "127.0.0.1", common.PORT)
  assert.equal err, 0
  req.oncomplete = (status, client_, req_) ->
    assert.equal 0, status
    assert.equal client, client_
    assert.equal req, req_
    console.log "connected"
    shutdownReq = new ShutdownWrap()
    err = client.shutdown(shutdownReq)
    assert.equal err, 0
    shutdownReq.oncomplete = (status, client_, req_) ->
      console.log "shutdown complete"
      assert.equal 0, status
      assert.equal client, client_
      assert.equal shutdownReq, req_
      shutdownCount++
      client.close()
      return

    return

  return
common = require("../common")
assert = require("assert")
TCP = process.binding("tcp_wrap").TCP
TCPConnectWrap = process.binding("tcp_wrap").TCPConnectWrap
ShutdownWrap = process.binding("stream_wrap").ShutdownWrap

#///
connectCount = 0
endCount = 0
shutdownCount = 0
server = require("net").Server((s) ->
  console.log "got connection"
  connectCount++
  s.resume()
  s.on "end", ->
    console.log "got eof"
    endCount++
    s.destroy()
    server.close()
    return

  return
)
server.listen common.PORT, makeConnection
process.on "exit", ->
  assert.equal 1, shutdownCount
  assert.equal 1, connectCount
  assert.equal 1, endCount
  return

