# Copyright 2008 the V8 project authors. All rights reserved.
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
f0 = ->
  this
f1 = (a) ->
  a = a or "i"
  this[a]
f2 = (a, b) ->
  a = a or "n"
  b = b or 2
  this[a] + b
fn = ->
  arguments.length
assertTrue this is f0.call(), "1"
assertTrue this is f0.call(this), "w"
assertTrue this is f0.call(this, 1), "w"
assertTrue this is f0.call(this, 1, 2), "w"
assertTrue this is f0.call(null), "3a"
assertTrue this is f0.call(null, 1), "3b"
assertTrue this is f0.call(null, 1, 2), "3c"
assertTrue this is f0.call(undefined), "4a"
assertTrue this is f0.call(undefined, 1), "4b"
assertTrue this is f0.call(undefined, 1, 2), "4c"
x = {}
assertTrue x is f0.call(x)
assertTrue x is f0.call(x, 1)
assertTrue x is f0.call(x, 1, 2)
assertEquals 1, f1.call(i: 1)
assertEquals 42, f1.call(
  i: 42
, "i")
assertEquals 87, f1.call(
  j: 87
, "j", 1)
assertEquals 99, f1.call(
  k: 99
, "k", 1, 2)
x = n: 1
assertEquals 3, f2.call(x)
assertEquals 14, f2.call(
  i: 12
, "i")
assertEquals 42, f2.call(x, "n", 41)
assertEquals 87, f2.call(x, "n", 86, 1)
assertEquals 99, f2.call(x, "n", 98, 1, 2)
assertEquals 0, fn.call()
assertEquals 0, fn.call(this)
assertEquals 0, fn.call(null)
assertEquals 0, fn.call(undefined)
assertEquals 1, fn.call(this, 1)
assertEquals 2, fn.call(this, 1, 2)
assertEquals 3, fn.call(this, 1, 2, 3)
