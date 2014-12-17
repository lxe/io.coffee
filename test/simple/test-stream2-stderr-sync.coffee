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

# Make sure that sync writes to stderr get processed before exiting.
parent = ->
  spawn = require("child_process").spawn
  assert = require("assert")
  i = 0
  children.forEach (_, c) ->
    child = spawn(process.execPath, [
      __filename
      "" + c
    ])
    err = ""
    child.stderr.on "data", (c) ->
      err += c
      return

    child.on "close", ->
      assert.equal err, "child " + c + "\nfoo\nbar\nbaz\n"
      console.log "ok %d child #%d", ++i, c
      console.log "1.." + i  if i is children.length
      return

    return

  return

# using console.error
child0 = ->
  console.error "child 0"
  console.error "foo"
  console.error "bar"
  console.error "baz"
  return

# using process.stderr
child1 = ->
  process.stderr.write "child 1\n"
  process.stderr.write "foo\n"
  process.stderr.write "bar\n"
  process.stderr.write "baz\n"
  return

# using a net socket
child2 = ->
  net = require("net")
  socket = new net.Socket(
    fd: 2
    readable: false
    writable: true
  )
  socket.write "child 2\n"
  socket.write "foo\n"
  socket.write "bar\n"
  socket.write "baz\n"
  return
child3 = ->
  console.error "child 3\nfoo\nbar\nbaz"
  return
child4 = ->
  process.stderr.write "child 4\nfoo\nbar\nbaz\n"
  return
common = require("../common.js")
assert = require("assert")
util = require("util")
errnoException = util._errnoException
children = [
  child0
  child1
  child2
  child3
  child4
]
unless process.argv[2]
  parent()
else
  children[process.argv[2]]()
  
  # immediate process.exit to kill any waiting stuff.
  process.exit()
