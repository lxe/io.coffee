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

# We use the has() function to avoid relying on a functioning
# implementation of 'in'.
has = (o, k) ->
  typeof o[k] isnt "undefined"
# should have DontDelete attribute

# Check that a LoadIC for a dictionary field works, even
# when the dictionary probe misses.
load_deleted_property_using_IC = ->
  x = new Object()
  x.a = 3
  x.b = 4
  x.c = 5
  delete x.c

  assertEquals 3, load_a(x)
  assertEquals 3, load_a(x)
  delete x.a

  assertTrue typeof load_a(x) is "undefined", "x.a is gone"
  assertTrue typeof load_a(x) is "undefined", "x.a is gone"
  return
load_a = (x) ->
  x.a
assertTrue delete null

assertTrue delete 2

assertTrue delete "foo"

assertTrue delete Number(7)

assertTrue delete new Number(8)

assertTrue delete {}.x

assertTrue delete {}.y

assertTrue delete {}.toString

x = 42
assertEquals 42, x
assertTrue delete x

assertTrue typeof x is "undefined", "x is gone"
y = 87
assertEquals 87, y
assertFalse delete y
, "don't delete"
assertFalse typeof y is "undefined"
assertEquals 87, y
o =
  x: 42
  y: 87

assertTrue has(o, "x")
assertTrue has(o, "y")
assertTrue delete o.x

assertFalse has(o, "x")
assertTrue has(o, "y")
assertTrue delete o["y"]

assertFalse has(o, "x")
assertFalse has(o, "y")
o = {}
i = 0x0020

while i < 0x02ff
  o[String.fromCharCode(i)] = i
  o[String.fromCharCode(i + 1)] = i + 1
  i += 2
i = 0x0020

while i < 0x02ff
  assertTrue delete o[String.fromCharCode(i)]

  i += 2
i = 0x0020

while i < 0x02ff
  assertFalse has(o, String.fromCharCode(i)), "deleted (" + i + ")"
  assertTrue has(o, String.fromCharCode(i + 1)), "still here (" + i + ")"
  i += 2
a = [
  0
  1
  2
]
assertTrue has(a, 0)
assertTrue delete a[0]

assertFalse has(a, 0), "delete 0"
assertEquals 1, a[1]
assertEquals 2, a[2]
assertTrue delete a[100]
, "delete 100"
assertTrue delete a[Math.pow(2, 31) - 1]
, "delete 2^31-1"
assertFalse has(a, 0), "delete 0"
assertEquals 1, a[1]
assertEquals 2, a[2]
a = [
  0
  1
  2
]
assertEquals 3, a.length
assertTrue delete a[2]

assertEquals 3, a.length
assertTrue delete a[0]

assertEquals 3, a.length
assertTrue delete a[1]

assertEquals 3, a.length
o = {}
o[Math.pow(2, 30) - 1] = 0
o[Math.pow(2, 31) - 1] = 0
o[1] = 0
assertTrue delete o[0]

assertTrue delete o[Math.pow(2, 30)]

assertFalse has(o, 0), "delete 0"
assertFalse has(o, Math.pow(2, 30))
assertTrue has(o, 1)
assertTrue has(o, Math.pow(2, 30) - 1)
assertTrue has(o, Math.pow(2, 31) - 1)
assertTrue delete o[Math.pow(2, 30) - 1]

assertTrue has(o, 1)
assertFalse has(o, Math.pow(2, 30) - 1), "delete 2^30-1"
assertTrue has(o, Math.pow(2, 31) - 1)
assertTrue delete o[1]

assertFalse has(o, 1), "delete 1"
assertFalse has(o, Math.pow(2, 30) - 1), "delete 2^30-1"
assertTrue has(o, Math.pow(2, 31) - 1)
assertTrue delete o[Math.pow(2, 31) - 1]

assertFalse has(o, 1), "delete 1"
assertFalse has(o, Math.pow(2, 30) - 1), "delete 2^30-1"
assertFalse has(o, Math.pow(2, 31) - 1), "delete 2^31-1"
a = []
a[Math.pow(2, 30) - 1] = 0
a[Math.pow(2, 31) - 1] = 0
a[1] = 0
assertTrue delete a[0]

assertTrue delete a[Math.pow(2, 30)]

assertFalse has(a, 0), "delete 0"
assertFalse has(a, Math.pow(2, 30)), "delete 2^30"
assertTrue has(a, 1)
assertTrue has(a, Math.pow(2, 30) - 1)
assertTrue has(a, Math.pow(2, 31) - 1)
assertEquals Math.pow(2, 31), a.length
assertTrue delete a[Math.pow(2, 30) - 1]

assertTrue has(a, 1)
assertFalse has(a, Math.pow(2, 30) - 1), "delete 2^30-1"
assertTrue has(a, Math.pow(2, 31) - 1)
assertEquals Math.pow(2, 31), a.length
assertTrue delete a[1]

assertFalse has(a, 1), "delete 1"
assertFalse has(a, Math.pow(2, 30) - 1), "delete 2^30-1"
assertTrue has(a, Math.pow(2, 31) - 1)
assertEquals Math.pow(2, 31), a.length
assertTrue delete a[Math.pow(2, 31) - 1]

assertFalse has(a, 1), "delete 1"
assertFalse has(a, Math.pow(2, 30) - 1), "delete 2^30-1"
assertFalse has(a, Math.pow(2, 31) - 1), "delete 2^31-1"
assertEquals Math.pow(2, 31), a.length
load_deleted_property_using_IC()
