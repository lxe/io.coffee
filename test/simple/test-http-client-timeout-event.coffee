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
options =
  method: "GET"
  port: common.PORT
  host: "127.0.0.1"
  path: "/"

server = http.createServer((req, res) ->
)

# this space intentionally left blank
server.listen options.port, options.host, ->
  req = http.request(options, (res) ->
  )
  
  # this space intentionally left blank
  req.on "error", ->

  
  # this space is intentionally left blank
  req.on "close", ->
    server.close()
    return

  timeout_events = 0
  req.setTimeout 1
  req.on "timeout", ->
    timeout_events += 1
    return

  setTimeout (->
    req.destroy()
    assert.equal timeout_events, 1
    return
  ), 100
  setTimeout (->
    req.end()
    return
  ), 50
  return

