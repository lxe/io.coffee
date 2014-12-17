# Copyright 2009 the V8 project authors. All rights reserved.
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

# Test pre- and postfix count operations.

# Test value context.

# Test effect context.

# Test test context.

# Test value/test and test/value contexts.

# Test count operations with parameters.
f = (x) ->
  x++
  x
g = (x) ->
  ++x
  x
h = (x) ->
  y = x++
  y
k = (x) ->
  y = ++x
  y

# Test count operation in a test context.
countTestPost = (i) ->
  k = 0
  k++  while i--
  k
countTestPre = (i) ->
  k = 0
  k++  while --i
  k
a = 42
b = x: 42
c = "x"
assertEquals 43, ++a
assertEquals 43, a
assertEquals 43, a++
assertEquals 44, a
assertEquals 43, ++b.x
assertEquals 43, b.x
assertEquals 43, b.x++
assertEquals 44, b.x
assertEquals 45, ++b[c]
assertEquals 45, b[c]
assertEquals 45, b[c]++
assertEquals 46, b[c]
a = 42
b = x: 42
c = "x"
assertEquals 1, eval("++a; 1")
assertEquals 43, a
assertEquals 1, eval("a++; 1")
assertEquals 44, a
assertEquals 1, eval("++b.x; 1")
assertEquals 43, b.x
assertEquals 1, eval("b.x++; 1")
assertEquals 44, b.x
assertEquals 1, eval("++b[c]; 1")
assertEquals 45, b[c]
assertEquals 1, eval("b[c]++; 1")
assertEquals 46, b[c]
a = 42
b = x: 42
c = "x"
assertEquals 1, (if (++a) then 1 else 0)
assertEquals 43, a
assertEquals 1, (if (a++) then 1 else 0)
assertEquals 44, a
assertEquals 1, (if (++b.x) then 1 else 0)
assertEquals 43, b.x
assertEquals 1, (if (b.x++) then 1 else 0)
assertEquals 44, b.x
assertEquals 1, (if (++b[c]) then 1 else 0)
assertEquals 45, b[c]
assertEquals 1, (if (b[c]++) then 1 else 0)
assertEquals 46, b[c]
a = 42
b = x: 42
c = "x"
assertEquals 43, ++a or 1
assertEquals 43, a
assertEquals 43, a++ or 1
assertEquals 44, a
assertEquals 43, ++b.x or 1
assertEquals 43, b.x
assertEquals 43, (b.x++) or 1
assertEquals 44, b.x
assertEquals 45, ++b[c] or 1
assertEquals 45, b[c]
assertEquals 45, b[c]++ or 1
assertEquals 46, b[c]
a = 42
b = x: 42
c = "x"
assertEquals 1, ++a and 1
assertEquals 43, a
assertEquals 1, a++ and 1
assertEquals 44, a
assertEquals 1, ++b.x and 1
assertEquals 43, b.x
assertEquals 1, (b.x++) and 1
assertEquals 44, b.x
assertEquals 1, ++b[c] and 1
assertEquals 45, b[c]
assertEquals 1, b[c]++ and 1
assertEquals 46, b[c]
assertEquals 43, f(42)
assertEquals 43, g(42)
assertEquals 42, h(42)
assertEquals 43, k(42)
assertEquals 10, countTestPost(10)
assertEquals 9, countTestPre(10)
