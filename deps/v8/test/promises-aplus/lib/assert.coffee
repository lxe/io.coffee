# Copyright 2014 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Mimics assert module in node.
compose = (message1, message2) ->
  (if message2 then message1 + ": " + message2 else message1)
fail = (actual, expected, message, operator) ->
  e = Error(compose("FAIL", message) + ": (" + actual + " " + operator + " " + expected + ") should hold")
  fails.push e
  throw ereturn
ok = (value, message) ->
  throw Error(compose("FAIL", +message) + ": value = " + value)  unless value
  return
equal = (actual, expected, message) ->
  fail actual, expected, message, "=="  unless expected is actual
  return
notEqual = (actual, expected, message) ->
  fail actual, expected, message, "!="  unless expected isnt actual
  return
strictEqual = (actual, expected, message) ->
  fail actual, expected, message, "==="  unless expected is actual
  return
notStrictEqual = (actual, expected, message) ->
  fail actual, expected, message, "!=="  unless expected isnt actual
  return
assert = (value, message) ->
  ok value, message
notImplemented = ->
  throw Error("FAIL: This assertion function is not yet implemented.")return
clear = ->
  @fails = []
  return
assert.fail = fail
assert.ok = ok
assert.equal = equal
assert.notEqual = notEqual
assert.deepEqual = notImplemented
assert.notDeepEqual = notImplemented
assert.strictEqual = strictEqual
assert.notStrictEqual = notStrictEqual
assert.throws = notImplemented
assert.doesNotThrow = notImplemented
assert.ifError = notImplemented
assert.clear = clear
exports = assert
