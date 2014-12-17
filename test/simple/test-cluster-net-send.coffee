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
fork = require("child_process").fork
net = require("net")
if process.argv[2] isnt "child"
  console.error "[%d] master", process.pid
  worker = fork(__filename, ["child"])
  called = false
  worker.once "message", (msg, handle) ->
    assert.equal msg, "handle"
    assert.ok handle
    worker.send "got"
    handle.on "data", (data) ->
      called = true
      assert.equal data.toString(), "hello"
      return

    handle.on "end", ->
      worker.kill()
      return

    return

  process.once "exit", ->
    assert.ok called
    return

else
  console.error "[%d] worker", process.pid
  server = net.createServer((c) ->
    process.once "message", (msg) ->
      assert.equal msg, "got"
      c.end "hello"
      return

    return
  )
  server.listen common.PORT, ->
    socket = net.connect(common.PORT, "127.0.0.1", ->
      process.send "handle", socket
      return
    )
    return

  process.on "disconnect", ->
    process.exit()
    server.close()
    return

