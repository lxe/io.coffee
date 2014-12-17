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
pwd = (callback) ->
  output = ""
  child = common.spawnPwd()
  child.stdout.setEncoding "utf8"
  child.stdout.on "data", (s) ->
    console.log "stdout: " + JSON.stringify(s)
    output += s
    return

  child.on "exit", (c) ->
    console.log "exit: " + c
    assert.equal 0, c
    childExited = true
    return

  child.on "close", ->
    callback output
    pwd_called = true
    childClosed = true
    return

  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
pwd_called = false
childClosed = false
childExited = false
pwd (result) ->
  console.dir result
  assert.equal true, result.length > 1
  assert.equal "\n", result[result.length - 1]
  return

process.on "exit", ->
  assert.equal true, pwd_called
  assert.equal true, childExited
  assert.equal true, childClosed
  return

