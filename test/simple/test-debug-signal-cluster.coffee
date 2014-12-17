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
onNoMoreLines = ->
  assertOutputLines()
  process.exit()
  return

# Kill processes in reverse order to avoid timing problems on Windows where
# the parent process is killed before the children.
assertOutputLines = ->
  expectedLines = [
    "Starting debugger agent."
    "Debugger listening on port " + 5858
    "Starting debugger agent."
    "Debugger listening on port " + 5859
    "Starting debugger agent."
    "Debugger listening on port " + 5860
  ]
  
  # Do not assume any particular order of output messages,
  # since workers can take different amout of time to
  # start up
  outputLines.sort()
  expectedLines.sort()
  assert.equal outputLines.length, expectedLines.length
  i = 0

  while i < expectedLines.length
    assert.equal outputLines[i], expectedLines[i]
    i++
  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
args = [common.fixturesDir + "/clustered-server/app.js"]
child = spawn(process.execPath, args,
  stdio: [
    "pipe"
    "pipe"
    "pipe"
    "ipc"
  ]
)
outputLines = []
outputTimerId = undefined
waitingForDebuggers = false
pids = null
child.stderr.on "data", (data) ->
  lines = data.toString().replace(/\r/g, "").trim().split("\n")
  line = lines[0]
  lines.forEach (ln) ->
    console.log "> " + ln
    return

  clearTimeout outputTimerId  if outputTimerId isnt `undefined`
  if waitingForDebuggers
    outputLines = outputLines.concat(lines)
    outputTimerId = setTimeout(onNoMoreLines, 800)
  else if line is "all workers are running"
    child.on "message", (msg) ->
      return  if msg.type isnt "pids"
      pids = msg.pids
      console.error "got pids %j", pids
      waitingForDebuggers = true
      process._debugProcess child.pid
      return

    child.send type: "getpids"
  return

setTimeout (testTimedOut = ->
  assert false, "test timed out."
  return
), 6000
process.on "exit", onExit = ->
  pids.reverse().forEach (pid) ->
    process.kill pid
    return

  return

