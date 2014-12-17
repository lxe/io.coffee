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
domain = require("domain")
assert = require("assert")
common = require("../common.js")
timeout_err = undefined
timeout = undefined
immediate_err = undefined
timeoutd = domain.create()
timeoutd.on "error", (e) ->
  timeout_err = e
  clearTimeout timeout
  return

timeoutd.run ->
  setTimeout(->
    throw new Error("Timeout UNREFd")return
  ).unref()
  return

immediated = domain.create()
immediated.on "error", (e) ->
  immediate_err = e
  return

immediated.run ->
  setImmediate ->
    throw new Error("Immediate Error")return

  return

timeout = setTimeout(->
, 10 * 1000)
process.on "exit", ->
  assert.equal timeout_err.message, "Timeout UNREFd", "Domain should catch timer error"
  assert.equal immediate_err.message, "Immediate Error", "Domain should catch immediate error"
  return

