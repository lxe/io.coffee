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

# settings

# measured
runClient = (callback) ->
  client = net.createConnection(common.PORT)
  client.connections = 0
  client.setEncoding "utf8"
  client.on "connect", ->
    common.print "c"
    client.recved = ""
    client.connections += 1
    return

  client.on "data", (chunk) ->
    @recved += chunk
    return

  client.on "end", ->
    client.end()
    return

  client.on "error", (e) ->
    console.log "\n\nERROOOOOr"
    throw ereturn

  client.on "close", (had_error) ->
    common.print "."
    assert.equal false, had_error
    assert.equal bytes, client.recved.length
    console.log client.fd  if client.fd
    assert.ok not client.fd
    if @connections < connections_per_client
      @connect common.PORT
    else
      callback()
    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
bytes = 1024 * 40
concurrency = 100
connections_per_client = 5
total_connections = 0
body = ""
i = 0

while i < bytes
  body += "C"
  i++
server = net.createServer((c) ->
  console.log "connected"
  total_connections++
  common.print "#"
  c.write body
  c.end()
  return
)
server.listen common.PORT, ->
  finished_clients = 0
  i = 0

  while i < concurrency
    runClient ->
      server.close()  if ++finished_clients is concurrency
      return

    i++
  return

process.on "exit", ->
  assert.equal connections_per_client * concurrency, total_connections
  console.log "\nokay!"
  return

