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
childProcess = require("child_process")

# Child pipe test
if process.argv[2] is "pipetest"
  process.stdout.write "stdout message"
  process.stderr.write "stderr message"
else if process.argv[2] is "ipctest"
  
  # Child IPC test
  process.send "message from child"
  process.on "message", ->
    process.send "got message from master"
    return

else if process.argv[2] is "parent"
  
  # Parent | start child pipe test
  child = childProcess.fork(process.argv[1], ["pipetest"],
    silent: true
  )
  
  # Allow child process to self terminate
  child._channel.close()
  child._channel = null
  child.on "exit", ->
    process.exit 0
    return

else
  
  # testcase | start parent && child IPC test
  
  # testing: is stderr and stdout piped to parent
  args = [
    process.argv[1]
    "parent"
  ]
  parent = childProcess.spawn(process.execPath, args)
  
  #got any stderr or std data
  stdoutData = false
  parent.stdout.on "data", ->
    stdoutData = true
    return

  stderrData = false
  parent.stdout.on "data", ->
    stderrData = true
    return

  
  # testing: do message system work when using silent
  child = childProcess.fork(process.argv[1], ["ipctest"],
    silent: true
  )
  
  # Manual pipe so we will get errors
  child.stderr.pipe process.stderr,
    end: false

  child.stdout.pipe process.stdout,
    end: false

  childSending = false
  childReciveing = false
  child.on "message", (message) ->
    childSending = (message is "message from child")  if childSending is false
    childReciveing = (message is "got message from master")  if childReciveing is false
    child.kill()  if childReciveing is true
    return

  child.send "message to child"
  
  # Check all values
  process.on "exit", ->
    
    # clean up
    child.kill()
    parent.kill()
    
    # Check std(out|err) pipes
    assert.ok not stdoutData, "The stdout socket was piped to parent"
    assert.ok not stderrData, "The stderr socket was piped to parent"
    
    # Check message system
    assert.ok childSending, "The child was able to send a message"
    assert.ok childReciveing, "The child was able to receive a message"
    return

