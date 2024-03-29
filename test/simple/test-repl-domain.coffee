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

# A stream to push an array into a REPL
ArrayStream = ->
  @run = (data) ->
    self = this
    data.forEach (line) ->
      self.emit "data", line + "\n"
      return

    return

  return
assert = require("assert")
common = require("../common.js")
util = require("util")
repl = require("repl")
util.inherits ArrayStream, require("stream").Stream
ArrayStream::readable = true
ArrayStream::writable = true
ArrayStream::resume = ->

ArrayStream::write = ->

putIn = new ArrayStream()
testMe = repl.start("", putIn)
putIn.write = (data) ->
  
  # Don't use assert for this because the domain might catch it, and
  # give a false negative.  Don't throw, just print and exit.
  if data is "OK\n"
    console.log "ok"
  else
    console.error data
    process.exit 1
  return

putIn.run ["require(\"domain\").create().on(\"error\", function () { console.log(\"OK\") })" + ".run(function () { throw new Error(\"threw\") })"]
