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
if module.parent
  
  # signal we've been loaded as a module
  console.log "Loaded as a module, exiting with status code 42."
  process.exit 42
common = require("../common.js")
assert = require("assert")
child = require("child_process")
nodejs = "\"" + process.execPath + "\""

# replace \ by / because windows uses backslashes in paths, but they're still
# interpreted as the escape character when put between quotes.
filename = __filename.replace(/\\/g, "/")

# assert that nothing is written to stdout
child.exec nodejs + " --eval 42", (err, stdout, stderr) ->
  assert.equal stdout, ""
  assert.equal stderr, ""
  return


# assert that "42\n" is written to stderr
child.exec nodejs + " --eval \"console.error(42)\"", (err, stdout, stderr) ->
  assert.equal stdout, ""
  assert.equal stderr, "42\n"
  return


# assert that the expected output is written to stdout
[
  "--print"
  "-p -e"
  "-pe"
  "-p"
].forEach (s) ->
  cmd = nodejs + " " + s + " "
  child.exec cmd + "42", (err, stdout, stderr) ->
    assert.equal stdout, "42\n"
    assert.equal stderr, ""
    return

  child.exec cmd + "'[]'", (err, stdout, stderr) ->
    assert.equal stdout, "[]\n"
    assert.equal stderr, ""
    return

  return


# assert that module loading works
child.exec nodejs + " --eval \"require('" + filename + "')\"", (status, stdout, stderr) ->
  assert.equal status.code, 42
  return


# module path resolve bug, regression test
child.exec nodejs + " --eval \"require('./test/simple/test-cli-eval.js')\"", (status, stdout, stderr) ->
  assert.equal status.code, 42
  return


# empty program should do nothing
child.exec nodejs + " -e \"\"", (status, stdout, stderr) ->
  assert.equal stdout, ""
  assert.equal stderr, ""
  return


# "\\-42" should be interpreted as an escaped expression, not a switch
child.exec nodejs + " -p \"\\-42\"", (err, stdout, stderr) ->
  assert.equal stdout, "-42\n"
  assert.equal stderr, ""
  return

child.exec nodejs + " --use-strict -p process.execArgv", (status, stdout, stderr) ->
  assert.equal stdout, "[ '--use-strict', '-p', 'process.execArgv' ]\n"
  return

