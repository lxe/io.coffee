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
assert = require("assert")
cp = require("child_process")
fs = require("fs")
path = require("path")
common = require("../common")
msg = test: "this"
nodePath = process.execPath
copyPath = path.join(common.tmpDir, "node-copy.exe")
if process.env.FORK
  assert process.send
  assert.equal process.argv[0], copyPath
  process.send msg
  process.exit()
else
  try
    fs.unlinkSync copyPath
  catch e
    throw e  if e.code isnt "ENOENT"
  fs.writeFileSync copyPath, fs.readFileSync(nodePath)
  fs.chmodSync copyPath, "0755"
  
  # slow but simple
  envCopy = JSON.parse(JSON.stringify(process.env))
  envCopy.FORK = "true"
  child = require("child_process").fork(__filename,
    execPath: copyPath
    env: envCopy
  )
  child.on "message", common.mustCall((recv) ->
    assert.deepEqual msg, recv
    return
  )
  child.on "exit", common.mustCall((code) ->
    fs.unlinkSync copyPath
    assert.equal code, 0
    return
  )
