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
net = require("net")
buf = new Buffer(10 * 1024 * 1024)
buf.fill 0x62
errs = []
srv = net.createServer(onConnection = (conn) ->
  conn.write buf
  conn.on "error", (err) ->
    errs.push err
    assert false, "We should not be emitting the same error twice"  if errs.length > 1 and errs[0] is errs[1]
    return

  conn.on "close", ->
    srv.unref()
    return

  return
).listen(common.PORT, ->
  client = net.connect(port: common.PORT)
  client.on "connect", ->
    client.destroy()
    return

  return
)
process.on "exit", ->
  console.log errs
  assert.equal errs.length, 1
  return

