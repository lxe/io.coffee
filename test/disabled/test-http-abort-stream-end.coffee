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
maxSize = 1024
size = 0
s = http.createServer((req, res) ->
  @close()
  res.writeHead 200,
    "Content-Type": "text/plain"

  i = 0

  while i < maxSize
    res.write "x" + i
    i++
  res.end()
  return
)
aborted = false
s.listen common.PORT, ->
  req = http.get("http://localhost:" + common.PORT, (res) ->
    res.on "data", (chunk) ->
      size += chunk.length
      assert not aborted, "got data after abort"
      if size > maxSize
        aborted = true
        req.abort()
        size = maxSize
      return

    return
  )
  req.end()
  return

process.on "exit", ->
  assert aborted
  assert.equal size, maxSize
  console.log "ok"
  return

