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
parent = ->
  test "foo,tud,bar", true
  test "foo,tud", true
  test "tud,bar", true
  test "tud", true
  test "foo,bar", false
  test "", false
  return
test = (environ, shouldWrite) ->
  expectErr = ""
  expectErr = "TUD %PID%: this { is: 'a' } /debugging/\n" + "TUD %PID%: number=1234 string=asdf obj={\"foo\":\"bar\"}\n"  if shouldWrite
  expectOut = "ok\n"
  didTest = false
  spawn = require("child_process").spawn
  child = spawn(process.execPath, [
    __filename
    "child"
  ],
    env:
      NODE_DEBUG: environ
  )
  expectErr = expectErr.split("%PID%").join(child.pid)
  err = ""
  child.stderr.setEncoding "utf8"
  child.stderr.on "data", (c) ->
    err += c
    return

  out = ""
  child.stdout.setEncoding "utf8"
  child.stdout.on "data", (c) ->
    out += c
    return

  child.on "close", (c) ->
    assert not c
    assert.equal err, expectErr
    assert.equal out, expectOut
    didTest = true
    console.log "ok %j %j", environ, shouldWrite
    return

  process.on "exit", ->
    assert didTest
    return

  return
child = ->
  util = require("util")
  debug = util.debuglog("tud")
  debug "this",
    is: "a"
  , /debugging/
  debug "number=%d string=%s obj=%j", 1234, "asdf",
    foo: "bar"

  console.log "ok"
  return
common = require("../common")
assert = require("assert")
if process.argv[2] is "child"
  child()
else
  parent()
