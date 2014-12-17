
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
run = (cmd, strict, cb) ->
  args = []
  args.push "--use_strict"  if strict
  args.push "-pe", cmd
  child = spawn(process.execPath, args)
  child.stdout.pipe process.stdout
  child.stderr.pipe process.stdout
  child.on "close", cb
  return
go = ->
  c = queue.shift()
  return console.log("done")  unless c
  run c, false, ->
    run c, true, go
    return

  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
queue = [
  "with(this){__filename}"
  "42"
  "throw new Error(\"hello\")"
  "var x = 100; y = x;"
  "var ______________________________________________; throw 10"
]
go()
