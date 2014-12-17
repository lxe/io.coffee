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

# Server

# Client 1

# Client 2

# Client 3

# Client 4

# Client 5

# Client helper functions
onDataError = ->
  assert false
  return
onDataOk = ->
  dataEvents++
  return
scheduleTearDown = (conn) ->
  setTimeout (->
    conn.removeAllListeners "data"
    conn.resume()
    return
  ), 100
  return
common = require("../common")
assert = require("assert")
net = require("net")
connections = 0
dataEvents = 0
conn = undefined
server = net.createServer((conn) ->
  connections++
  conn.end "This was the year he fell to pieces."
  server.close()  if connections is 5
  return
)
server.listen common.PORT
conn = require("net").createConnection(common.PORT, "localhost")
conn.resume()
conn.on "data", onDataOk
conn = require("net").createConnection(common.PORT, "localhost")
conn.pause()
conn.resume()
conn.on "data", onDataOk
conn = require("net").createConnection(common.PORT, "localhost")
conn.pause()
conn.on "data", onDataError
scheduleTearDown conn
conn = require("net").createConnection(common.PORT, "localhost")
conn.resume()
conn.pause()
conn.resume()
conn.on "data", onDataOk
conn = require("net").createConnection(common.PORT, "localhost")
conn.resume()
conn.resume()
conn.pause()
conn.on "data", onDataError
scheduleTearDown conn

# Exit sanity checks
process.on "exit", ->
  assert.strictEqual connections, 5
  assert.strictEqual dataEvents, 3
  return

