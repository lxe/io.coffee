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
tryImmediate = ->
  console.log "set immediate"
  setImmediate ->
    revivals++
    process.once "beforeExit", tryTimer
    return

  return
tryTimer = ->
  console.log "set a timeout"
  setTimeout (->
    console.log "timeout cb, do another once beforeExit"
    revivals++
    process.once "beforeExit", tryListen
    return
  ), 1
  return
tryListen = ->
  console.log "create a server"
  net.createServer().listen(0).on "listening", ->
    revivals++
    @close()
    return

  return
assert = require("assert")
net = require("net")
util = require("util")
revivals = 0
deaths = 0
process.on "beforeExit", ->
  deaths++
  return

process.once "beforeExit", tryImmediate
process.on "exit", ->
  assert.equal 4, deaths
  assert.equal 3, revivals
  return

