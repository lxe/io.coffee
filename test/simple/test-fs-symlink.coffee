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
path = require("path")
fs = require("fs")
exec = require("child_process").exec
completed = 0
expected_tests = 2
is_windows = process.platform is "win32"
runtest = (skip_symlinks) ->
  unless skip_symlinks
    
    # test creating and reading symbolic link
    linkData = path.join(common.fixturesDir, "/cycles/root.js")
    linkPath = path.join(common.tmpDir, "symlink1.js")
    
    # Delete previously created link
    try
      fs.unlinkSync linkPath
    fs.symlink linkData, linkPath, (err) ->
      throw err  if err
      console.log "symlink done"
      
      # todo: fs.lstat?
      fs.readlink linkPath, (err, destination) ->
        throw err  if err
        assert.equal destination, linkData
        completed++
        return

      return

  
  # test creating and reading hard link
  srcPath = path.join(common.fixturesDir, "cycles", "root.js")
  dstPath = path.join(common.tmpDir, "link1.js")
  
  # Delete previously created link
  try
    fs.unlinkSync dstPath
  fs.link srcPath, dstPath, (err) ->
    throw err  if err
    console.log "hard link done"
    srcContent = fs.readFileSync(srcPath, "utf8")
    dstContent = fs.readFileSync(dstPath, "utf8")
    assert.equal srcContent, dstContent
    completed++
    return

  return

if is_windows
  
  # On Windows, creating symlinks requires admin privileges.
  # We'll only try to run symlink test if we have enough privileges.
  exec "whoami /priv", (err, o) ->
    if err or o.indexOf("SeCreateSymbolicLinkPrivilege") is -1
      expected_tests = 1
      runtest true
    else
      runtest false
    return

else
  runtest false
process.on "exit", ->
  assert.equal completed, expected_tests
  return

