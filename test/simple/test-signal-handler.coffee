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

# SIGUSR1 and SIGHUP are not supported on Windows
process.exit 0  if process.platform is "win32"
common = require("../common")
assert = require("assert")
console.log "process.pid: " + process.pid
first = 0
second = 0
sighup = false
process.on "SIGUSR1", ->
  console.log "Interrupted by SIGUSR1"
  first += 1
  return

process.on "SIGUSR1", ->
  second += 1
  setTimeout (->
    console.log "End."
    process.exit 0
    return
  ), 5
  return

i = 0
setInterval (->
  console.log "running process..." + ++i
  process.kill process.pid, "SIGUSR1"  if i is 5
  return
), 1

# Test on condition where a watcher for SIGNAL
# has been previously registered, and `process.listeners(SIGNAL).length === 1`
process.on "SIGHUP", ->

process.removeAllListeners "SIGHUP"
process.on "SIGHUP", ->
  sighup = true
  return

process.kill process.pid, "SIGHUP"
process.on "exit", ->
  assert.equal 1, first
  assert.equal 1, second
  assert.equal true, sighup
  return

