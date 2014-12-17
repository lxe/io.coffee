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
tls = require("tls")
net = require("net")
fs = require("fs")
assert = require("assert")
options =
  key: fs.readFileSync(common.fixturesDir + "/test_key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/test_cert.pem")

bonkers = new Buffer(1024 * 1024)
bonkers.fill 42
server = tls.createServer(options, (c) ->
).listen(common.PORT, ->
  client = net.connect(common.PORT, ->
    client.write bonkers
    return
  )
  once = false
  writeAgain = setTimeout(->
    client.write bonkers
    return
  )
  client.on "error", (err) ->
    unless once
      clearTimeout writeAgain
      once = true
      client.destroy()
      server.close()
    return

  client.on "close", (hadError) ->
    assert.strictEqual hadError, true, "Client never errored"
    return

  return
)
