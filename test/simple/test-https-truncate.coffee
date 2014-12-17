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

# number of bytes discovered empirically to trigger the bug
httpsTest = ->
  sopt =
    key: key
    cert: cert

  server = https.createServer(sopt, (req, res) ->
    res.setHeader "content-length", data.length
    res.end data
    server.close()
    return
  )
  server.listen PORT, ->
    opts =
      port: PORT
      rejectUnauthorized: false

    https.get(opts).on "response", (res) ->
      test res
      return

    return

  return
test = (res) ->
  res.on "end", ->
    assert.equal res._readableState.length, 0
    assert.equal bytes, data.length
    console.log "ok"
    return

  
  # Pause and then resume on each chunk, to ensure that there will be
  # a lone byte hanging out at the very end.
  bytes = 0
  res.on "data", (chunk) ->
    bytes += chunk.length
    @pause()
    setTimeout @resume.bind(this)
    return

  return
common = require("../common")
assert = require("assert")
fs = require("fs")
https = require("https")
path = require("path")
resultFile = path.resolve(common.tmpDir, "result")
key = fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
cert = fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")
PORT = common.PORT
data = new Buffer(1024 * 32 + 1)
httpsTest()
