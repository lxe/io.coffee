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
is_windows = process.platform is "win32"
cat = spawn((if is_windows then "more" else "cat"))
cat.stdin.write "hello"
cat.stdin.write " "
cat.stdin.write "world"
assert.ok cat.stdin.writable
assert.ok not cat.stdin.readable
cat.stdin.end()
response = ""
exitStatus = -1
closed = false
gotStdoutEOF = false
cat.stdout.setEncoding "utf8"
cat.stdout.on "data", (chunk) ->
  console.log "stdout: " + chunk
  response += chunk
  return

cat.stdout.on "end", ->
  gotStdoutEOF = true
  return

gotStderrEOF = false
cat.stderr.on "data", (chunk) ->
  
  # shouldn't get any stderr output
  assert.ok false
  return

cat.stderr.on "end", (chunk) ->
  gotStderrEOF = true
  return

cat.on "exit", (status) ->
  console.log "exit event"
  exitStatus = status
  return

cat.on "close", ->
  closed = true
  if is_windows
    assert.equal "hello world\r\n", response
  else
    assert.equal "hello world", response
  return

process.on "exit", ->
  assert.equal 0, exitStatus
  assert closed
  if is_windows
    assert.equal "hello world\r\n", response
  else
    assert.equal "hello world", response
  return

