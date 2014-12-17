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
is_windows = process.platform is "win32"
common = require("../common")
assert = require("assert")
os = require("os")
util = require("util")
spawn = require("child_process").spawn

# We're trying to reproduce:
# $ echo "hello\nnode\nand\nworld" | grep o | sed s/o/a/
grep = undefined
sed = undefined
echo = undefined
if is_windows
  grep = spawn("grep", [
    "--binary"
    "o"
  ])
  sed = spawn("sed", [
    "--binary"
    "s/o/O/"
  ])
  echo = spawn("cmd.exe", [
    "/c"
    "echo"
    "hello&&"
    "echo"
    "node&&"
    "echo"
    "and&&"
    "echo"
    "world"
  ])
else
  grep = spawn("grep", ["o"])
  sed = spawn("sed", ["s/o/O/"])
  echo = spawn("echo", ["hello\nnode\nand\nworld\n"])

#
# * grep and sed hang if the spawn function leaks file descriptors to child
# * processes.
# * This happens when calling pipe(2) and then forgetting to set the
# * FD_CLOEXEC flag on the resulting file descriptors.
# *
# * This test checks child processes exit, meaning they don't hang like
# * explained above.
# 

# pipe echo | grep
echo.stdout.on "data", (data) ->
  console.error "grep stdin write " + data.length
  echo.stdout.pause()  unless grep.stdin.write(data)
  return

grep.stdin.on "drain", (data) ->
  echo.stdout.resume()
  return


# propagate end from echo to grep
echo.stdout.on "end", (code) ->
  grep.stdin.end()
  return

echo.on "exit", ->
  console.error "echo exit"
  return

grep.on "exit", ->
  console.error "grep exit"
  return

sed.on "exit", ->
  console.error "sed exit"
  return


# pipe grep | sed
grep.stdout.on "data", (data) ->
  console.error "grep stdout " + data.length
  grep.stdout.pause()  unless sed.stdin.write(data)
  return

sed.stdin.on "drain", (data) ->
  grep.stdout.resume()
  return


# propagate end from grep to sed
grep.stdout.on "end", (code) ->
  console.error "grep stdout end"
  sed.stdin.end()
  return

result = ""

# print sed's output
sed.stdout.on "data", (data) ->
  result += data.toString("utf8", 0, data.length)
  util.print data
  return

sed.stdout.on "end", (code) ->
  assert.equal result, "hellO" + os.EOL + "nOde" + os.EOL + "wOrld" + os.EOL
  return

