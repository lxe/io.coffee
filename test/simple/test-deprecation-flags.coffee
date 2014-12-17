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
execFile = require("child_process").execFile
depmod = require.resolve("../fixtures/deprecated.js")
node = process.execPath
normal = [depmod]
noDep = [
  "--no-deprecation"
  depmod
]
traceDep = [
  "--trace-deprecation"
  depmod
]
execFile node, normal, (er, stdout, stderr) ->
  console.error "normal: show deprecation warning"
  assert.equal er, null
  assert.equal stdout, ""
  assert.equal stderr, "util.p: Use console.error() instead\n'This is deprecated'\n"
  console.log "normal ok"
  return

execFile node, noDep, (er, stdout, stderr) ->
  console.error "--no-deprecation: silence deprecations"
  assert.equal er, null
  assert.equal stdout, ""
  assert.equal stderr, "'This is deprecated'\n"
  console.log "silent ok"
  return

execFile node, traceDep, (er, stdout, stderr) ->
  console.error "--trace-deprecation: show stack"
  assert.equal er, null
  assert.equal stdout, ""
  stack = stderr.trim().split("\n")
  
  # just check the top and bottom.
  assert.equal stack[0], "Trace: util.p: Use console.error() instead"
  assert.equal stack.pop(), "'This is deprecated'"
  console.log "trace ok"
  return

