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
isWindows = process.platform is "win32"
env = HELLO: "WORLD"
env.__proto__ = FOO: "BAR"
if isWindows
  child = spawn("cmd.exe", [
    "/c"
    "set"
  ],
    env: env
  )
else
  child = spawn("/usr/bin/env", [],
    env: env
  )
response = ""
child.stdout.setEncoding "utf8"
child.stdout.on "data", (chunk) ->
  console.log "stdout: " + chunk
  response += chunk
  return

process.on "exit", ->
  assert.ok response.indexOf("HELLO=WORLD") >= 0
  assert.ok response.indexOf("FOO=BAR") >= 0
  return

