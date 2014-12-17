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
common = require("../common")
assert = require("assert")
os = require("os")
util = require("util")
unless os.type() is "SunOS"
  console.error "Skipping because DTrace not available."
  process.exit 0

#
# * Some functions to create a recognizable stack.
# 
frames = [
  "stalloogle"
  "bagnoogle"
  "doogle"
]
expected = undefined
stalloogle = (str) ->
  expected = str
  os.loadavg()
  return

bagnoogle = (arg0, arg1) ->
  stalloogle arg0 + " is " + arg1 + " except that it is read-only"
  return

done = false
doogle = ->
  setTimeout doogle, 10  unless done
  bagnoogle "The bfs command", "(almost) like ed(1)"
  return

spawn = require("child_process").spawn
prefix = "/var/tmp/node"
corefile = prefix + "." + process.pid

#
# * We're going to use DTrace to stop us, gcore us, and set us running again
# * when we call getloadavg() -- with the implicit assumption that our
# * deepest function is the only caller of os.loadavg().
# 
dtrace = spawn("dtrace", [
  "-qwn"
  "syscall::getloadavg:entry/pid == " + process.pid + "/{ustack(100, 8192); exit(0); }"
])
output = ""
dtrace.stderr.on "data", (data) ->
  console.log "dtrace: " + data
  return

dtrace.stdout.on "data", (data) ->
  output += data
  return

dtrace.on "exit", (code) ->
  unless code is 0
    console.error "dtrace exited with code " + code
    process.exit code
  done = true
  sentinel = "(anon) as "
  lines = output.split("\n")
  i = 0

  while i < lines.length
    line = lines[i]
    continue  if line.indexOf(sentinel) is -1 or frames.length is 0
    frame = line.substr(line.indexOf(sentinel) + sentinel.length)
    top = frames.shift()
    assert.equal frame.indexOf(top), 0, "unexpected frame where " + top + " was expected"
    i++
  assert.equal frames.length, 0, "did not find expected frame " + frames[0]
  process.exit 0
  return

setTimeout doogle, 10
