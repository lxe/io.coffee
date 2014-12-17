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
require "../common"
assert = require("assert")
exec = require("child_process").exec
success_count = 0
error_count = 0
pwdcommand = undefined
dir = undefined
if process.platform is "win32"
  pwdcommand = "echo %cd%"
  dir = "c:\\windows"
else
  pwdcommand = "pwd"
  dir = "/dev"
child = exec(pwdcommand,
  cwd: dir
, (err, stdout, stderr) ->
  if err
    error_count++
    console.log "error!: " + err.code
    console.log "stdout: " + JSON.stringify(stdout)
    console.log "stderr: " + JSON.stringify(stderr)
    assert.equal false, err.killed
  else
    success_count++
    console.log stdout
    assert.ok stdout.indexOf(dir) is 0
  return
)
process.on "exit", ->
  assert.equal 1, success_count
  assert.equal 0, error_count
  return

