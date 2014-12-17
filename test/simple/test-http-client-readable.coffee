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
FakeAgent = ->
  http.Agent.call this
  return
common = require("../common")
assert = require("assert")
http = require("http")
util = require("util")
Duplex = require("stream").Duplex
util.inherits FakeAgent, http.Agent
FakeAgent::createConnection = createConnection = ->
  s = new Duplex()
  once = false
  s._read = read = ->
    return @push(null)  if once
    once = true
    @push "HTTP/1.1 200 Ok\r\nTransfer-Encoding: chunked\r\n\r\n"
    @push "b\r\nhello world\r\n"
    @readable = false
    @push "0\r\n\r\n"
    return

  
  # Blackhole
  s._write = write = (data, enc, cb) ->
    cb()
    return

  s.destroy = s.destroySoon = destroy = ->
    @writable = false
    return

  s

received = ""
ended = 0
req = http.request(
  agent: new FakeAgent()
, (res) ->
  res.on "data", (chunk) ->
    received += chunk
    return

  res.on "end", ->
    ended++
    return

  return
)
req.end()
process.on "exit", ->
  assert.equal received, "hello world"
  assert.equal ended, 1
  return

