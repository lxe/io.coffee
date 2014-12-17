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

#
# * Now we're going to fork ourselves to gcore
# 
LanguageH = (chapter) ->
  @OBEY = "CHAPTER " + parseInt(chapter, 10)
  return
common = require("../common")
assert = require("assert")
os = require("os")
path = require("path")
util = require("util")
unless os.type() is "SunOS"
  console.error "Skipping because postmortem debugging not available."
  process.exit 0
spawn = require("child_process").spawn
prefix = "/var/tmp/node"
corefile = prefix + "." + process.pid
gcore = spawn("gcore", [
  "-o"
  prefix
  process.pid + ""
])
output = ""
unlinkSync = require("fs").unlinkSync
args = [corefile]
if process.env.MDB_LIBRARY_PATH and process.env.MDB_LIBRARY_PATH isnt ""
  args = args.concat([
    "-L"
    process.env.MDB_LIBRARY_PATH
  ])
obj = new LanguageH(1)
gcore.stderr.on "data", (data) ->
  console.log "gcore: " + data
  return

gcore.on "exit", (code) ->
  unless code is 0
    console.error "gcore exited with code " + code
    process.exit code
  mdb = spawn("mdb", args,
    stdio: "pipe"
  )
  mdb.on "exit", (code) ->
    retained = "; core retained as " + corefile
    unless code is 0
      console.error "mdb exited with code " + util.inspect(code) + retained
      process.exit code
    lines = output.split("\n")
    found = 0
    i = undefined
    expected = "OBEY: \"" + obj.OBEY + "\""
    nexpected = 2
    i = 0

    while i < lines.length
      found++  unless lines[i].indexOf(expected) is -1
      i++
    assert.equal found, nexpected, "expected " + nexpected + " objects, found " + found + retained
    unlinkSync corefile
    process.exit 0
    return

  mdb.stdout.on "data", (data) ->
    output += data
    return

  mdb.stderr.on "data", (data) ->
    console.log "mdb stderr: " + data
    return

  mod = util.format("::load %s\n", path.join(__dirname, "..", "..", "out", "Release", "mdb_v8.so"))
  mdb.stdin.write mod
  mdb.stdin.write "::findjsobjects -c LanguageH | "
  mdb.stdin.write "::findjsobjects | ::jsprint\n"
  mdb.stdin.write "::findjsobjects -p OBEY | "
  mdb.stdin.write "::findjsobjects | ::jsprint\n"
  mdb.stdin.end()
  return

