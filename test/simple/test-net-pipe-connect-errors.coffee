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
fs = require("fs")
net = require("net")
path = require("path")
assert = require("assert")
common = require("../common")
notSocketErrorFired = false
noEntErrorFired = false
accessErrorFired = false

# Test if ENOTSOCK is fired when trying to connect to a file which is not
# a socket.
emptyTxt = undefined
if process.platform is "win32"
  
  # on Win, common.PIPE will be a named pipe, so we use an existing empty
  # file instead
  emptyTxt = path.join(common.fixturesDir, "empty.txt")
else
  
  # use common.PIPE to ensure we stay within POSIX socket path length
  # restrictions, even on CI
  cleanup = ->
    try
      fs.unlinkSync emptyTxt
    catch e
      throw e  unless e.code is "ENOENT"
    return
  emptyTxt = common.PIPE + ".txt"
  process.on "exit", cleanup
  cleanup()
  fs.writeFileSync emptyTxt, ""
notSocketClient = net.createConnection(emptyTxt, ->
  assert.ok false
  return
)
notSocketClient.on "error", (err) ->
  assert err.code is "ENOTSOCK" or err.code is "ECONNREFUSED"
  notSocketErrorFired = true
  return


# Trying to connect to not-existing socket should result in ENOENT error
noEntSocketClient = net.createConnection("no-ent-file", ->
  assert.ok false
  return
)
noEntSocketClient.on "error", (err) ->
  assert.equal err.code, "ENOENT"
  noEntErrorFired = true
  return


# On Windows or when running as root, a chmod has no effect on named pipes
if process.platform isnt "win32" and process.getuid() isnt 0
  
  # Trying to connect to a socket one has no access to should result in EACCES
  accessServer = net.createServer(->
    assert.ok false
    return
  )
  accessServer.listen common.PIPE, ->
    fs.chmodSync common.PIPE, 0
    accessClient = net.createConnection(common.PIPE, ->
      assert.ok false
      return
    )
    accessClient.on "error", (err) ->
      assert.equal err.code, "EACCES"
      accessErrorFired = true
      accessServer.close()
      return

    return


# Assert that all error events were fired
process.on "exit", ->
  assert.ok notSocketErrorFired
  assert.ok noEntErrorFired
  assert.ok accessErrorFired  if process.platform isnt "win32" and process.getuid() isnt 0
  return

