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
spawn = require("child_process").spawn
args = [
  "--debug"
  common.fixturesDir + "/clustered-server/app.js"
]
child = spawn(process.execPath, args)
outputLines = []
child.stderr.on "data", (data) ->
  lines = data.toString().replace(/\r/g, "").trim().split("\n")
  line = lines[0]
  lines.forEach (ln) ->
    console.log "> " + ln
    return

  if line is "all workers are running"
    assertOutputLines()
    process.exit()
  else
    outputLines = outputLines.concat(lines)
  return

process.on "exit", onExit = ->
  child.kill()
  return

assertOutputLines = common.mustCall(->
  expectedLines = [
    "Debugger listening on port " + 5858
    "Debugger listening on port " + 5859
    "Debugger listening on port " + 5860
  ]
  
  # Do not assume any particular order of output messages,
  # since workers can take different amout of time to
  # start up
  outputLines.sort()
  assert.equal outputLines.length, expectedLines.length
  i = 0

  while i < expectedLines.length
    assert.equal outputLines[i], expectedLines[i]
    i++
  return
)
