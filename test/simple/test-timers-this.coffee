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
immediateThis = undefined
intervalThis = undefined
timeoutThis = undefined
immediateArgsThis = undefined
intervalArgsThis = undefined
timeoutArgsThis = undefined
immediateHandler = setImmediate(->
  immediateThis = this
  return
)
immediateArgsHandler = setImmediate(->
  immediateArgsThis = this
  return
, "args ...")
intervalHandler = setInterval(->
  clearInterval intervalHandler
  intervalThis = this
  return
)
intervalArgsHandler = setInterval(->
  clearInterval intervalArgsHandler
  intervalArgsThis = this
  return
, 0, "args ...")
timeoutHandler = setTimeout(->
  timeoutThis = this
  return
)
timeoutArgsHandler = setTimeout(->
  timeoutArgsThis = this
  return
, 0, "args ...")
process.once "exit", ->
  assert.strictEqual immediateThis, immediateHandler
  assert.strictEqual immediateArgsThis, immediateArgsHandler
  assert.strictEqual intervalThis, intervalHandler
  assert.strictEqual intervalArgsThis, intervalArgsHandler
  assert.strictEqual timeoutThis, timeoutHandler
  assert.strictEqual timeoutArgsThis, timeoutArgsHandler
  return

