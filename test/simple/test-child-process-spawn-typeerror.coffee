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
spawn = require("child_process").spawn
assert = require("assert")
windows = (process.platform is "win32")
cmd = (if (windows) then "rundll32" else "ls")
invalidcmd = "hopefully_you_dont_have_this_on_your_machine"
invalidArgsMsg = /Incorrect value of args option/
invalidOptionsMsg = /options argument must be an object/
errors = 0
try
  
  # Ensure this throws a TypeError
  child = spawn(invalidcmd, "this is not an array")
  child.on "error", (err) ->
    errors++
    return

catch e
  assert.equal e instanceof TypeError, true

# verify that valid argument combinations do not throw
assert.doesNotThrow ->
  spawn cmd
  return

assert.doesNotThrow ->
  spawn cmd, []
  return

assert.doesNotThrow ->
  spawn cmd, {}
  return

assert.doesNotThrow ->
  spawn cmd, [], {}
  return


# verify that invalid argument combinations throw
assert.throws (->
  spawn()
  return
), /Bad argument/
assert.throws (->
  spawn cmd, null
  return
), invalidArgsMsg
assert.throws (->
  spawn cmd, true
  return
), invalidArgsMsg
assert.throws (->
  spawn cmd, [], null
  return
), invalidOptionsMsg
assert.throws (->
  spawn cmd, [], 1
  return
), invalidOptionsMsg
process.on "exit", ->
  assert.equal errors, 0
  return

