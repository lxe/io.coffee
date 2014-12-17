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

# Test that a Linux specific quirk in the handle passing protocol is handled
# correctly. See https://github.com/joyent/node/issues/5330 for details.
master = ->
  
  # spawn() can only create one IPC channel so we use stdin/stdout as an
  # ad-hoc command channel.
  proc = spawn(process.execPath, [
    __filename
    "worker"
  ],
    stdio: [
      "pipe"
      "pipe"
      "pipe"
      "ipc"
    ]
  )
  handle = null
  proc.on "exit", ->
    handle.close()
    return

  proc.stdout.on "data", (data) ->
    assert.equal data, "ok\r\n"
    net.createServer(assert.fail).listen common.PORT, ->
      handle = @_handle
      proc.send "one"
      proc.send "two", handle
      proc.send "three"
      proc.stdin.write "ok\r\n"
      return

    return

  proc.stderr.pipe process.stderr
  return
worker = ->
  process._channel.readStop() # Make messages batch up.
  process.stdout.ref()
  process.stdout.write "ok\r\n"
  process.stdin.once "data", (data) ->
    assert.equal data, "ok\r\n"
    process._channel.readStart()
    return

  n = 0
  process.on "message", (msg, handle) ->
    n += 1
    if n is 1
      assert.equal msg, "one"
      assert.equal handle, `undefined`
    else if n is 2
      assert.equal msg, "two"
      assert.equal typeof handle, "object" # Also matches null, therefore...
      assert.ok handle # also check that it's truthy.
      handle.close()
    else if n is 3
      assert.equal msg, "three"
      assert.equal handle, `undefined`
      process.exit()
    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
spawn = require("child_process").spawn
if process.argv[2] is "worker"
  worker()
else
  master()
