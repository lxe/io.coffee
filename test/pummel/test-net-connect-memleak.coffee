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

# Flags: --expose-gc

# 2**26 == 64M entries
# keep reference alive
done = ->
  gc()
  after = process.memoryUsage().rss
  reclaimed = (before - after) / 1024
  console.log "%d kB reclaimed", reclaimed
  assert reclaimed > 128 * 1024 # It's around 256 MB on x64.
  process.exit()
  return
common = require("../common")
assert = require("assert")
net = require("net")
assert typeof gc is "function", "Run this test with --expose-gc"
net.createServer(->
).listen common.PORT
before = 0
(->
  gc()
  i = 0
  junk = [0]

  while i < 26
    junk = junk.concat(junk)
    ++i
  before = process.memoryUsage().rss
  net.createConnection common.PORT, "127.0.0.1", ->
    assert junk.length isnt 0
    setTimeout done, 10
    gc()
    return

  return
)()
