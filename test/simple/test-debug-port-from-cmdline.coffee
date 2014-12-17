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
testTimedOut = ->
  assert false, "test timed out."
  return

# Give the child process small amout of time to start
processStderrLine = (line) ->
  console.log "> " + line
  outputLines.push line
  if /Debugger listening/.test(line)
    assertOutputLines()
    process.exit()
  return
assertOutputLines = ->
  expectedLines = [
    "Starting debugger agent."
    "Debugger listening on port " + debugPort
  ]
  assert.equal outputLines.length, expectedLines.length
  i = 0

  while i < expectedLines.length
    assert.equal outputLines[i], expectedLines[i]
    i++
  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
debugPort = common.PORT
args = ["--debug-port=" + debugPort]
child = spawn(process.execPath, args)
child.stderr.on "data", (data) ->
  lines = data.toString().replace(/\r/g, "").trim().split("\n")
  lines.forEach processStderrLine
  return

setTimeout testTimedOut, 3000
setTimeout (->
  process._debugProcess child.pid
  return
), 100
process.on "exit", ->
  child.kill()
  return

outputLines = []
