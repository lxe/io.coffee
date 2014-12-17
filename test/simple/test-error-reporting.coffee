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
errExec = (script, callback) ->
  cmd = "\"" + process.argv[0] + "\" \"" + path.join(common.fixturesDir, script) + "\""
  exec cmd, (err, stdout, stderr) ->
    
    # There was some error
    assert.ok err
    
    # More than one line of error output.
    assert.ok stderr.split("\n").length > 2
    
    # Assert the script is mentioned in error output.
    assert.ok stderr.indexOf(script) >= 0
    
    # Proxy the args for more tests.
    callback err, stdout, stderr
    
    # Count the tests
    exits++
    console.log "."
    return

common = require("../common")
assert = require("assert")
exec = require("child_process").exec
path = require("path")
exits = 0

# Simple throw error
errExec "throws_error.js", (err, stdout, stderr) ->
  assert.ok /blah/.test(stderr)
  return


# Trying to JSON.parse(undefined)
errExec "throws_error2.js", (err, stdout, stderr) ->
  assert.ok /SyntaxError/.test(stderr)
  return


# Trying to JSON.parse(undefined) in nextTick
errExec "throws_error3.js", (err, stdout, stderr) ->
  assert.ok /SyntaxError/.test(stderr)
  return


# throw ILLEGAL error
errExec "throws_error4.js", (err, stdout, stderr) ->
  assert.ok /\/\*\*/.test(stderr)
  assert.ok /SyntaxError/.test(stderr)
  return

process.on "exit", ->
  assert.equal 4, exits
  return

