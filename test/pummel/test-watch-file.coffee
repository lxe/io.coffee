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
watchFile = ->
  fs.watchFile f, (curr, prev) ->
    console.log f + " change"
    changes++
    assert.ok curr.mtime isnt prev.mtime
    fs.unwatchFile f
    watchFile()
    fs.unwatchFile f
    return

  return
common = require("../common")
assert = require("assert")
fs = require("fs")
path = require("path")
f = path.join(common.fixturesDir, "x.txt")
f2 = path.join(common.fixturesDir, "x2.txt")
console.log "watching for changes of " + f
changes = 0
watchFile()
fd = fs.openSync(f, "w+")
fs.writeSync fd, "xyz\n"
fs.closeSync fd
process.on "exit", ->
  assert.ok changes > 0
  return

