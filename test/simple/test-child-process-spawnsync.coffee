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
spawnSync = require("child_process").spawnSync
TIMER = 100
SLEEP = 1000
timeout = 0
setTimeout (->
  timeout = process.hrtime(start)
  assert.ok stop, "timer should not fire before process exits"
  assert.strictEqual timeout[0], 1, "timer should take as long as sleep"
  return
), TIMER
console.log "sleep started"
start = process.hrtime()
ret = spawnSync("sleep", ["1"])
stop = process.hrtime(start)
assert.strictEqual ret.status, 0, "exit status should be zero"
console.log "sleep exited", stop
assert.strictEqual stop[0], 1, "sleep should not take longer or less than 1 second"

# Error test when command does not exist
ret_err = spawnSync("command_does_not_exist")
assert.strictEqual ret_err.error.code, "ENOENT"

# Verify that the cwd option works - GH #7824
(->
  response = undefined
  cwd = undefined
  if process.platform is "win32"
    cwd = "c:\\"
    response = spawnSync("cmd.exe", [
      "/c"
      "cd"
    ],
      cwd: cwd
    )
  else
    cwd = "/"
    response = spawnSync("pwd", [],
      cwd: cwd
    )
  assert.strictEqual response.stdout.toString().trim(), cwd
  return
)()
