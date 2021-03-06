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
child_process = require("child_process")
wrong_script = path.join(common.fixturesDir, "cert.pem")
p = child_process.spawn(process.execPath, [
  "-e"
  "try { require(process.argv[1]); } catch (e) { console.log(e.stack); }"
  wrong_script
])
p.stderr.on "data", (data) ->
  assert false, "Unexpected stderr data: " + data
  return

output = ""
p.stdout.on "data", (data) ->
  output += data
  return

process.on "exit", ->
  assert /BEGIN CERT/.test(output)
  assert /^\s+\^/m.test(output)
  assert /Invalid left-hand side expression in prefix operation/.test(output)
  return

