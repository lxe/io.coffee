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
util = require("util")
assert = require("assert")
exec = require("child_process").exec
success_count = 0
error_count = 0
cmd = [
  process.execPath
  "-e"
  "\"console.error(process.argv)\""
  "foo"
  "bar"
].join(" ")
expected = util.format([
  process.execPath
  "foo"
  "bar"
]) + "\n"
child = exec(cmd, (err, stdout, stderr) ->
  if err
    console.log err.toString()
    ++error_count
    return
  assert.equal stderr, expected
  ++success_count
  return
)
process.on "exit", ->
  assert.equal 1, success_count
  assert.equal 0, error_count
  return

