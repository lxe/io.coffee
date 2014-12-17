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

#messages
PREFIX = "NODE_"
normal = cmd: "foo" + PREFIX
internal = cmd: PREFIX + "bar"
if process.argv[2] is "child"
  
  #send non-internal message containing PREFIX at a non prefix position
  process.send normal
  
  #send inernal message
  process.send internal
  process.exit 0
else
  fork = require("child_process").fork
  child = fork(process.argv[1], ["child"])
  gotNormal = undefined
  child.once "message", (data) ->
    gotNormal = data
    return

  gotInternal = undefined
  child.once "internalMessage", (data) ->
    gotInternal = data
    return

  process.on "exit", ->
    assert.deepEqual gotNormal, normal
    assert.deepEqual gotInternal, internal
    return

