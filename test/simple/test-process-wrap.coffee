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
Process = process.binding("process_wrap").Process
Pipe = process.binding("pipe_wrap").Pipe
pipe = new Pipe()
p = new Process()
processExited = false
gotPipeEOF = false
gotPipeData = false
p.onexit = (exitCode, signal) ->
  console.log "exit"
  p.close()
  pipe.readStart()
  assert.equal 0, exitCode
  assert.equal 0, signal
  processExited = true
  return

pipe.onread = (err, b, off_, len) ->
  assert.ok processExited
  if b
    gotPipeData = true
    console.log "read %d", len
  else
    gotPipeEOF = true
    pipe.close()
  return

p.spawn
  file: process.execPath
  args: [
    process.execPath
    "-v"
  ]
  stdio: [
    {
      type: "ignore"
    }
    {
      type: "pipe"
      handle: pipe
    }
    {
      type: "ignore"
    }
  ]


# 'this' safety
# https://github.com/joyent/node/issues/6690
assert.throws (->
  notp = spawn: p.spawn
  notp.spawn
    file: process.execPath
    args: [
      process.execPath
      "-v"
    ]
    stdio: [
      {
        type: "ignore"
      }
      {
        type: "pipe"
        handle: pipe
      }
      {
        type: "ignore"
      }
    ]

  return
), TypeError
process.on "exit", ->
  assert.ok processExited
  assert.ok gotPipeEOF
  assert.ok gotPipeData
  return

