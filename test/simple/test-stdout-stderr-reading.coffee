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

# verify that stdout is never read from.
parent = ->
  spawn = require("child_process").spawn
  node = process.execPath
  closes = 0
  c1 = spawn(node, [
    __filename
    "child"
  ])
  c1out = ""
  c1.stdout.setEncoding "utf8"
  c1.stdout.on "data", (chunk) ->
    c1out += chunk
    return

  c1.stderr.setEncoding "utf8"
  c1.stderr.on "data", (chunk) ->
    console.error "c1err: " + chunk.split("\n").join("\nc1err: ")
    return

  c1.on "close", (code, signal) ->
    closes++
    assert not code
    assert not signal
    assert.equal c1out, "ok\n"
    console.log "ok"
    return

  c2 = spawn(node, [
    "-e"
    "console.log(\"ok\")"
  ])
  c2out = ""
  c2.stdout.setEncoding "utf8"
  c2.stdout.on "data", (chunk) ->
    c2out += chunk
    return

  c1.stderr.setEncoding "utf8"
  c1.stderr.on "data", (chunk) ->
    console.error "c1err: " + chunk.split("\n").join("\nc1err: ")
    return

  c2.on "close", (code, signal) ->
    closes++
    assert not code
    assert not signal
    assert.equal c2out, "ok\n"
    console.log "ok"
    return

  process.on "exit", ->
    assert.equal closes, 2, "saw both closes"
    return

  return
child = ->
  
  # should not be reading *ever* in here.
  net.Socket::read = ->
    throw new Error("no reading allowed in child")return

  console.log "ok"
  return
common = require("../common")
assert = require("assert")
net = require("net")
read = net.Socket::read
net.Socket::read = ->
  throw new Error("reading from stdout!")  if @fd is 1
  throw new Error("reading from stderr!")  if @fd is 2
  read.apply this, arguments

if process.argv[2] is "child"
  child()
else
  parent()
