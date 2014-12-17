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
util = require("util")
path = require("path")
assert = require("assert")
spawn = require("child_process").spawn
common = require("../common")
console.error "argv=%j", process.argv
console.error "exec=%j", process.execPath
if process.argv[2] isnt "child"
  child = spawn("./node", [
    __filename
    "child"
  ],
    cwd: path.dirname(process.execPath)
  )
  childArgv0 = ""
  childErr = ""
  child.stdout.on "data", (chunk) ->
    childArgv0 += chunk
    return

  child.stderr.on "data", (chunk) ->
    childErr += chunk
    return

  child.on "exit", ->
    console.error "CHILD: %s", childErr.trim().split("\n").join("\nCHILD: ")
    if process.platform is "win32"
      
      # On Windows argv[0] is not expanded into full path
      assert.equal childArgv0, "./node"
    else
      assert.equal childArgv0, process.execPath
    return

else
  process.stdout.write process.argv[0]
