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

# Fork, then spawn. The spawned process should not hang.
checkExit = (statusCode) ->
  seenExit = true
  assert.equal statusCode, 0
  process.nextTick process.exit
  return
haveExit = ->
  assert.equal seenExit, true
  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
fork = require("child_process").fork
switch process.argv[2] or ""
  when ""
    fork(__filename, ["fork"]).on "exit", checkExit
    process.on "exit", haveExit
  when "fork"
    spawn(process.execPath, [
      __filename
      "spawn"
    ]).on "exit", checkExit
    process.on "exit", haveExit
  when "spawn"
  else
    assert 0
seenExit = false
