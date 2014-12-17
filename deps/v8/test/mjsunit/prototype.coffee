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
A = ->
B = ->
C = ->
NewC = ->
  A:: = {}
  B:: = new A()
  C:: = new B()
  result = new C()
  result.A = A::
  result.B = B::
  result.C = C::
  result

# Check that we can read properties defined in prototypes.

# Regression test:
# Make sure we preserve the prototype of an object in the face of map transitions.
D = ->
  @d = 1
  return

# Regression test:
# Make sure that arrays and functions in the prototype chain works;
# check length.
X = ->
Y = ->
c = NewC()
c.A.x = 1
c.B.y = 2
c.C.z = 3
assertEquals 1, c.x
assertEquals 2, c.y
assertEquals 3, c.z
c = NewC()
c.A.x = 0
i = 0

while i < 2
  assertEquals i, c.x
  c.B.x = 1
  i++
p = new Object()
p.y = 1
new D()
D:: = p
assertEquals 1, (new D).y
X:: = (a, b) ->

Y:: = [
  1
  2
  3
]
assertEquals 2, (new X).length
assertEquals 3, (new Y).length

# Test setting the length of an object where the prototype is from an array.
test = new Object
test.__proto__ = (new Array()).__proto__
test.length = 14
assertEquals 14, test.length
