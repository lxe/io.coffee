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
fixtPath = (p) ->
  path.join common.fixturesDir, p

# Test the equivalent of:
# $ /bin/echo 'hello world' > hello.txt
test1 = (next) ->
  console.log "Test 1..."
  fs.open helloPath, "w", 400, (err, fd) ->
    throw err  if err
    child = spawn("/bin/echo", [expected],
      customFds: [
        -1
        fd
      ]
    )
    assert.notEqual child.stdin, null
    assert.equal child.stdout, null
    assert.notEqual child.stderr, null
    child.on "exit", (err) ->
      throw err  if err
      fs.close fd, (error) ->
        throw error  if error
        fs.readFile helloPath, (err, data) ->
          throw err  if err
          assert.equal data.toString(), expected + "\n"
          console.log "  File was written."
          next test3
          return

        return

      return

    return

  return

# Test the equivalent of:
# $ node ../fixture/stdio-filter.js < hello.txt
test2 = (next) ->
  console.log "Test 2..."
  fs.open helloPath, "r", `undefined`, (err, fd) ->
    child = spawn(process.argv[0], [
      fixtPath("stdio-filter.js")
      "o"
      "a"
    ],
      customFds: [
        fd
        -1
        -1
      ]
    )
    assert.equal child.stdin, null
    actualData = ""
    child.stdout.on "data", (data) ->
      actualData += data.toString()
      return

    child.on "exit", (code) ->
      throw err  if err
      assert.equal actualData, "hella warld\n"
      console.log "  File was filtered successfully"
      fs.close fd, ->
        next test3
        return

      return

    return

  return

# Test the equivalent of:
# $ /bin/echo 'hello world' | ../stdio-filter.js a o
test3 = (next) ->
  console.log "Test 3..."
  filter = spawn(process.argv[0], [
    fixtPath("stdio-filter.js")
    "o"
    "a"
  ])
  echo = spawn("/bin/echo", [expected],
    customFds: [
      -1
      filter.fds[0]
    ]
  )
  actualData = ""
  filter.stdout.on "data", (data) ->
    console.log "  Got data --> " + data
    actualData += data
    return

  filter.on "exit", (code) ->
    throw "Return code was " + code  if code
    assert.equal actualData, "hella warld\n"
    console.log "  Talked to another process successfully"
    return

  echo.on "exit", (code) ->
    throw "Return code was " + code  if code
    filter.stdin.end()
    fs.unlinkSync helloPath
    return

  return
common = require("../common")
assert = require("assert")
assert = require("assert")
spawn = require("child_process").spawn
path = require("path")
fs = require("fs")
expected = "hello world"
helloPath = path.join(common.tmpDir, "hello.txt")
test1 test2
