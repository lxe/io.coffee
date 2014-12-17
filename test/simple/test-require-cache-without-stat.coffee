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

# We've experienced a regression where the module loader stats a bunch of
# directories on require() even if it's been called before. The require()
# should caching the request.
common = require("../common")
fs = require("fs")
assert = require("assert")
counter = 0

# Switch out the two stat implementations so that they increase a counter
# each time they are called.
_statSync = fs.statSync
_stat = fs.stat
fs.statSync = ->
  counter++
  _statSync.apply this, arguments

fs.stat = ->
  counter++
  _stat.apply this, arguments


# Load the module 'a' and 'http' once. It should become cached.
require common.fixturesDir + "/a"
require "../fixtures/a.js"
require "./../fixtures/a.js"
require "http"
console.log "counterBefore = %d", counter
counterBefore = counter

# Now load the module a bunch of times with equivalent paths.
# stat should not be called.
i = 0

while i < 100
  require common.fixturesDir + "/a"
  require "../fixtures/a.js"
  require "./../fixtures/a.js"
  i++

# Do the same with a built-in module
i = 0

while i < 100
  require "http"
  i++
console.log "counterAfter = %d", counter
counterAfter = counter
assert.equal counterBefore, counterAfter
