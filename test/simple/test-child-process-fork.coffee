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
assert = require("assert")
common = require("../common")
fork = require("child_process").fork
args = [
  "foo"
  "bar"
]
n = fork(common.fixturesDir + "/child-process-spawn-node.js", args)
assert.deepEqual args, [
  "foo"
  "bar"
]
messageCount = 0
n.on "message", (m) ->
  console.log "PARENT got message:", m
  assert.ok m.foo
  messageCount++
  return


# https://github.com/joyent/node/issues/2355 - JSON.stringify(undefined)
# returns "undefined" but JSON.parse() cannot parse that...
assert.throws (->
  n.send `undefined`
  return
), TypeError
assert.throws (->
  n.send()
  return
), TypeError
n.send hello: "world"
childExitCode = -1
n.on "exit", (c) ->
  childExitCode = c
  return

process.on "exit", ->
  assert.ok childExitCode is 0
  return

