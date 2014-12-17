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

# This test fails because we copy the arguments array on indirect
# access
g = (f) ->
  assertEquals 100, f.arguments = 100 # read-only
  assertEquals 3, f.arguments.length
  assertEquals 1, f.arguments[0]
  assertEquals 2, f.arguments[1]
  assertEquals 3, f.arguments[2]
  f.arguments[0] = 999
  f.arguments.extra = "kallevip"
  return
h = (f) ->
  assertEquals "kallevip", f.arguments.extra
  f.arguments

# Test function with a materialized arguments array.
f0 = ->
  g f0
  result = h(f0)
  a = arguments
  assertEquals 999, a[0]
  result

# Test function without a materialized arguments array.
f1 = (x) ->
  g f1
  result = h(f1)
  assertEquals 999, x
  result
test = (f) ->
  assertTrue null is f.arguments
  args = f(1, 2, 3)
  assertTrue null is f.arguments
  assertEquals 3, args.length
  assertEquals 999, args[0]
  assertEquals 2, args[1]
  assertEquals 3, args[2]
  assertEquals "kallevip", args.extra
  return
w = ->
  q.arguments
q = (x, y) ->
  x = 2
  result = w()
  y = 3
  result
test f0
test f1
a = q(0, 1)

# x is set locally *before* the last use of arguments before the
# activation of q is popped from the stack.
assertEquals 2, a[0]

# y is set locally *after* the last use of arguments before the
# activation of q is popped from the stack.
assertEquals 1, a[1]
