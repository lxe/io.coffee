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
exitCode = undefined
termSignal = undefined
gotStdoutEOF = false
gotStderrEOF = false
cat = spawn((if is_windows then "cmd" else "cat"))
cat.stdout.on "end", ->
  gotStdoutEOF = true
  return

cat.stderr.on "data", (chunk) ->
  assert.ok false
  return

cat.stderr.on "end", ->
  gotStderrEOF = true
  return

cat.on "exit", (code, signal) ->
  exitCode = code
  termSignal = signal
  return

assert.equal cat.killed, false
cat.kill()
assert.equal cat.killed, true
process.on "exit", ->
  assert.strictEqual exitCode, null
  assert.strictEqual termSignal, "SIGTERM"
  assert.ok gotStdoutEOF
  assert.ok gotStderrEOF
  return

