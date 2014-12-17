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

# no matter what happens, we should increment a 10 times.
log = ->
  console.log a++, process.domain
  setTimeout log, 20  if a < 10
  return

# in 50ms we'll throw an error.
err = ->
  err2 = ->
    
    # this timeout should never be called, since the domain gets
    # disposed when the error happens.
    setTimeout ->
      console.error "This should not happen."
      disposalFailed = true
      process.exit 1
      return

    
    # this function doesn't exist, and throws an error as a result.
    err3()
    return
  handle = (e) ->
    
    # this should clean up everything properly.
    d.dispose()
    console.error e
    console.error "in handler", process.domain, process.domain is d
    return
  d = domain.create()
  d.on "error", handle
  d.run err2
  return
common = require("../common.js")
assert = require("assert")
domain = require("domain")
disposalFailed = false
a = 0
log()
setTimeout err, 50
process.on "exit", ->
  assert.equal a, 10
  assert.equal disposalFailed, false
  console.log "ok"
  return

