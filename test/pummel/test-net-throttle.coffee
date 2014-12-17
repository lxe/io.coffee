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
net = require("net")
N = 1024 * 1024
part_N = N / 3
chars_recved = 0
npauses = 0
console.log "build big string"
body = ""
i = 0

while i < N
  body += "C"
  i++
console.log "start server on port " + common.PORT
server = net.createServer((connection) ->
  connection.write body.slice(0, part_N)
  connection.write body.slice(part_N, 2 * part_N)
  assert.equal false, connection.write(body.slice(2 * part_N, N))
  console.log "bufferSize: " + connection.bufferSize, "expecting", N
  assert.ok 0 <= connection.bufferSize and connection._writableState.length <= N
  connection.end()
  return
)
server.listen common.PORT, ->
  paused = false
  client = net.createConnection(common.PORT)
  client.setEncoding "ascii"
  client.on "data", (d) ->
    chars_recved += d.length
    console.log "got " + chars_recved
    unless paused
      client.pause()
      npauses += 1
      paused = true
      console.log "pause"
      x = chars_recved
      setTimeout (->
        assert.equal chars_recved, x
        client.resume()
        console.log "resume"
        paused = false
        return
      ), 100
    return

  client.on "end", ->
    server.close()
    client.end()
    return

  return

process.on "exit", ->
  assert.equal N, chars_recved
  assert.equal true, npauses > 2
  return

