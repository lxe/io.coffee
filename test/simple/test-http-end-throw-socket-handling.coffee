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

# Make sure that throwing in 'end' handler doesn't lock
# up the socket forever.
#
# This is NOT a good way to handle errors in general, but all
# the same, we should not be so brittle and easily broken.
catcher = ->
  errors++
  return
common = require("../common")
assert = require("assert")
http = require("http")
n = 0
server = http.createServer((req, res) ->
  server.close()  if ++n is 10
  res.end "ok"
  return
)
server.listen common.PORT, ->
  i = 0

  while i < 10
    options = port: common.PORT
    req = http.request(options, (res) ->
      res.resume()
      res.on "end", ->
        throw new Error("gleep glorp")return

      return
    )
    req.end()
    i++
  return

setTimeout(->
  process.removeListener "uncaughtException", catcher
  throw new Error("Taking too long!")return
, 1000).unref()
process.on "uncaughtException", catcher
errors = 0
process.on "exit", ->
  assert.equal errors, 10
  console.log "ok"
  return

