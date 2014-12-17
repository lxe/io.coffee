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

# Simple tests of most basic domain functionality.
common = require("../common")
assert = require("assert")
domain = require("domain")
events = require("events")
caught = 0
expectCaught = 1
d = new domain.Domain()
e = new events.EventEmitter()
d.on "error", (er) ->
  console.error "caught", er
  assert.strictEqual er.domain, d
  assert.strictEqual er.domainThrown, true
  assert.ok not er.domainEmitter
  assert.strictEqual er.code, "ENOENT"
  assert.ok /\bthis file does not exist\b/i.test(er.path)
  assert.strictEqual typeof er.errno, "number"
  caught++
  return

process.on "exit", ->
  console.error "exit"
  assert.equal caught, expectCaught
  console.log "ok"
  return


# implicit handling of thrown errors while in a domain, via the
# single entry points of ReqWrap and MakeCallback.  Even if
# we try very hard to escape, there should be no way to, even if
# we go many levels deep through timeouts and multiple IO calls.
# Everything that happens between the domain.enter() and domain.exit()
# calls will be bound to the domain, even if multiple levels of
# handles are created.
d.run ->
  setTimeout (->
    fs = require("fs")
    fs.readdir __dirname, ->
      fs.open "this file does not exist", "r", (er) ->
        throw er  if er
        throw new Error("should not get here!")return

      return

    return
  ), 100
  return

