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

# Tests of multiple domains happening at once.
common = require("../common")
assert = require("assert")
domain = require("domain")
events = require("events")
caughtA = false
caughtB = false
caughtC = false
a = domain.create()
a.enter() # this will be our "root" domain
a.on "error", (er) ->
  caughtA = true
  console.log "This should not happen"
  throw erreturn

http = require("http")

# child domain of a.

# treat these EE objects as if they are a part of the b domain
# so, an 'error' event on them propagates to the domain, rather
# than being thrown.

# res.writeHead(500), res.destroy, etc.

# XXX this bind should not be necessary.
# the write cb behavior in http/net should use an
# event so that it picks up the domain handling.
server = http.createServer((req, res) ->
  b = domain.create()
  a.add b
  b.add req
  b.add res
  b.on "error", (er) ->
    caughtB = true
    console.error "Error encountered", er
    if res
      res.writeHead 500
      res.end "An error occurred"
    server.close()
    return

  res.write "HELLO\n", b.bind(->
    throw new Error("this kills domain B, not A")return
  )
  return
).listen(common.PORT)
c = domain.create()
req = http.get(
  host: "localhost"
  port: common.PORT
)

# add the request to the C domain
c.add req
req.on "response", (res) ->
  console.error "got response"
  
  # add the response object to the C domain
  c.add res
  res.pipe process.stdout
  return

c.on "error", (er) ->
  caughtC = true
  console.error "Error on c", er.message
  return

process.on "exit", ->
  assert.equal caughtA, false
  assert.equal caughtB, true
  assert.equal caughtC, true
  console.log "ok - Errors went where they were supposed to go"
  return

