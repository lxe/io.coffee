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
path = require("path")
child_process = require("child_process")
fs = require("fs")
testScript = path.join(common.fixturesDir, "catch-stdout-error.js")
cmd = JSON.stringify(process.execPath) + " " + JSON.stringify(testScript) + " | " + JSON.stringify(process.execPath) + " " + "-pe \"process.exit(1);\""
child = child_process.exec(cmd)
output = ""
outputExpect =
  code: "EPIPE"
  errno: "EPIPE"
  syscall: "write"

child.stderr.on "data", (c) ->
  output += c
  return

child.on "close", (code) ->
  try
    output = JSON.parse(output)
  catch er
    console.error output
    process.exit 1
  assert.deepEqual output, outputExpect
  console.log "ok"
  return

