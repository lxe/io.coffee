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
http = require("http")
CRLF = "\r\n"
server = http.createServer()
server.on "upgrade", (req, socket, head) ->
  socket.write "HTTP/1.1 101 Ok" + CRLF + "Connection: Upgrade" + CRLF + "Upgrade: Test" + CRLF + CRLF + "head"
  socket.on "end", ->
    socket.end()
    return

  return

successCount = 0
server.listen common.PORT, ->
  upgradeRequest = (fn) ->
    onUpgrade = (res, socket, head) ->
      console.log "client upgraded"
      wasUpgrade = true
      request.removeListener "upgrade", onUpgrade
      socket.end()
      return
    onEnd = ->
      console.log "client end"
      request.removeListener "end", onEnd
      unless wasUpgrade
        throw new Error("hasn't received upgrade event")
      else
        fn and process.nextTick(fn)
      return
    console.log "req"
    header =
      Connection: "Upgrade"
      Upgrade: "Test"

    request = http.request(
      port: common.PORT
      headers: header
    )
    wasUpgrade = false
    request.on "upgrade", onUpgrade
    request.on "close", onEnd
    request.write "head"
    return
  upgradeRequest ->
    successCount++
    upgradeRequest ->
      successCount++
      
      # Test pass
      console.log "Pass!"
      server.close()
      return

    return

  return

process.on "exit", ->
  assert.equal 2, successCount
  return

