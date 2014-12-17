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
repl = require("repl")
stream = require("stream")
buildType = process.config.target_defaults.default_configuration
buildPath = __dirname + "/build/" + buildType + "/binding"
cb_ran = false
process.on "exit", ->
  assert cb_ran
  console.log "ok"
  return


# This line shouldn't cause an assertion error.

# Log output to double check callback ran.
lines = ["require('" + buildPath + "')" + ".method(function() { console.log('cb_ran'); });"]
dInput = new stream.Readable()
dOutput = new stream.Writable()
dInput._read = _read = (size) ->
    while lines.length > 0 and @push(lines.shift())
  @push null  if lines.length is 0
  return

dOutput._write = _write = (chunk, encoding, cb) ->
  cb_ran = true  if chunk.toString().indexOf("cb_ran") is 0
  cb()
  return

options =
  input: dInput
  output: dOutput
  terminal: false
  ignoreUndefined: true


# Run commands from fake REPL.
dummy = repl.start(options)
