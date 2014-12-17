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
assert = require("assert")
common = require("../common")
fork = require("child_process").fork
fork = require("child_process").fork
cp = fork(common.fixturesDir + "/child-process-message-and-exit.js")
gotMessage = false
gotExit = false
gotClose = false
cp.on "message", (message) ->
  assert not gotMessage
  assert not gotClose
  assert.strictEqual message, "hello"
  gotMessage = true
  return

cp.on "exit", ->
  assert not gotExit
  assert not gotClose
  gotExit = true
  return

cp.on "close", ->
  assert gotMessage
  assert gotExit
  assert not gotClose
  gotClose = true
  return

process.on "exit", ->
  assert gotMessage
  assert gotExit
  assert gotClose
  return

