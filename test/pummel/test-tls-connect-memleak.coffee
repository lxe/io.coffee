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
  before = process.memoryUsage().rss
  gc()
  after = process.memoryUsage().rss
  reclaimed = (before - after) / 1024
  console.log "%d kB reclaimed", reclaimed
  assert reclaimed > 256 * 1024 # it's more like 512M on x64
  process.exit()
  return
common = require("../common")
assert = require("assert")
tls = require("tls")
fs = require("fs")
assert typeof gc is "function", "Run this test with --expose-gc"
tls.createServer(
  cert: fs.readFileSync(common.fixturesDir + "/test_cert.pem")
  key: fs.readFileSync(common.fixturesDir + "/test_key.pem")
).listen common.PORT
(->
  i = 0
  junk = [0]

  while i < 26
    junk = junk.concat(junk)
    ++i
  options = rejectUnauthorized: false
  tls.connect common.PORT, "127.0.0.1", options, ->
    assert junk.length isnt 0
    setTimeout done, 10
    gc()
    return

  return
)()
