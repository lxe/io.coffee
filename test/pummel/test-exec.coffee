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

# Unix.

# Windows: `choice` is a command built into cmd.exe. Use another cmd process
# to create a process tree, so we can catch bugs related to it.

# make sure there is no race condition in starting the process
# the PID SHOULD exist directly following the exec() call.

# Kill the process
killMeTwiceCallback = (err, stdout, stderr) ->
  diff = (new Date()) - startSleep3
  
  # We should have already killed this process. Assert that the timeout still
  # works and that we are getting the proper callback parameters.
  assert.ok err
  assert.ok err.killed
  assert.equal err.signal, "SIGTERM"
  
  # the timeout should still be in effect
  console.log "'sleep 3' was already killed. Took %d ms", diff
  assert.ok diff < 1500
  return
common = require("../common")
assert = require("assert")
exec = require("child_process").exec
if process.platform isnt "win32"
  SLEEP3_COMMAND = "sleep 3"
else
  SLEEP3_COMMAND = "cmd /c choice /t 3 /c X /d X"
success_count = 0
error_count = 0
exec process.execPath + " -p -e process.versions", (err, stdout, stderr) ->
  if err
    error_count++
    console.log "error!: " + err.code
    console.log "stdout: " + JSON.stringify(stdout)
    console.log "stderr: " + JSON.stringify(stderr)
    assert.equal false, err.killed
  else
    success_count++
    console.dir stdout
  return

exec "thisisnotavalidcommand", (err, stdout, stderr) ->
  if err
    error_count++
    assert.equal "", stdout
    assert.equal true, err.code isnt 0
    assert.equal false, err.killed
    assert.strictEqual null, err.signal
    console.log "error code: " + err.code
    console.log "stdout: " + JSON.stringify(stdout)
    console.log "stderr: " + JSON.stringify(stderr)
  else
    success_count++
    console.dir stdout
    assert.equal true, stdout isnt ""
  return

sleeperStart = new Date()
exec SLEEP3_COMMAND,
  timeout: 50
, (err, stdout, stderr) ->
  diff = (new Date()) - sleeperStart
  console.log "'sleep 3' with timeout 50 took %d ms", diff
  assert.ok diff < 500
  assert.ok err
  assert.ok err.killed
  assert.equal err.signal, "SIGTERM"
  return

startSleep3 = new Date()
killMeTwice = exec(SLEEP3_COMMAND,
  timeout: 1000
, killMeTwiceCallback)
process.nextTick ->
  console.log "kill pid %d", killMeTwice.pid
  assert.equal "number", typeof killMeTwice._handle.pid
  killMeTwice.kill()
  return

exec "python -c \"print 200000*'C'\"",
  maxBuffer: 1000
, (err, stdout, stderr) ->
  assert.ok err
  assert.ok /maxBuffer/.test(err.message)
  return

process.on "exit", ->
  assert.equal 1, success_count
  assert.equal 1, error_count
  return

