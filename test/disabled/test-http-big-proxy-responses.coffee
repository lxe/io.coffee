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

# Produce a very large response.

# Proxy to the chargen server.
call_chargen = (list) ->
  if list.length > 0
    len = list.shift()
    common.debug "calling chargen for " + len + " chunks."
    recved = 0
    req = http.request(
      port: 9001
      host: "localhost"
      path: "/"
      headers:
        "x-len": len
    , (res) ->
      res.on "data", (d) ->
        recved += d.length
        assert.ok recved <= (len * chunk.length)
        return

      res.on "end", ->
        assert.ok recved <= (len * chunk.length)
        common.debug "end for " + len + " chunks."
        call_chargen list
        return

      return
    )
    req.end()
  else
    console.log "End of list. closing servers"
    proxy.close()
    chargen.close()
    done = true
  return
ready = ->
  return  if ++serversRunning < 2
  call_chargen [
    100
    1000
    10000
    100000
    1000000
  ]
  return
common = require("../common")
assert = require("assert")
util = require("util")
fs = require("fs")
http = require("http")
url = require("url")
chunk = "01234567890123456789"
chargen = http.createServer((req, res) ->
  len = parseInt(req.headers["x-len"], 10)
  assert.ok len > 0
  res.writeHead 200,
    "transfer-encoding": "chunked"

  i = 0

  while i < len
    common.print ","  if i % 1000 is 0
    res.write chunk
    i++
  res.end()
  return
)
chargen.listen 9000, ready
proxy = http.createServer((req, res) ->
  onError = (e) ->
    console.log "proxy client error. sent " + sent
    throw ereturn
  len = parseInt(req.headers["x-len"], 10)
  assert.ok len > 0
  sent = 0
  proxy_req = http.request(
    host: "localhost"
    port: 9000
    method: req.method
    path: req.url
    headers: req.headers
  , (proxy_res) ->
    res.writeHead proxy_res.statusCode, proxy_res.headers
    count = 0
    proxy_res.on "data", (d) ->
      common.print "."  if count++ % 1000 is 0
      res.write d
      sent += d.length
      assert.ok sent <= (len * chunk.length)
      return

    proxy_res.on "end", ->
      res.end()
      return

    return
  )
  proxy_req.on "error", onError
  proxy_req.end()
  return
)
proxy.listen 9001, ready
done = false
serversRunning = 0
process.on "exit", ->
  assert.ok done
  return

