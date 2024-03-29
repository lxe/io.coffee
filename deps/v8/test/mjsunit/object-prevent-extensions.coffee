# Copyright 2010 the V8 project authors. All rights reserved.
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

# Tests the Object.preventExtensions method - ES 15.2.3.10

# Extensible defaults to true.

# Make sure the is_extensible flag is set.

# Try adding a new element.

# Try when the object has an existing property.

# obj2.y should still be undefined.

# Make sure we can still write values to obj.x.

# obj2.y should still be undefined.

# obj2.y should still be undefined.

# We should still be able to change exiting elements.

# Test the the extensible flag is not inherited.

# We should be able to add new properties to the child object.

# This should have no influence on the parent class.

# Test that attributes on functions are also handled correctly.
foo = ->
  42
obj1 = {}
assertTrue Object.isExtensible(obj1)
Object.preventExtensions obj1
assertFalse Object.isExtensible(obj1)
obj1.x = 42
assertEquals `undefined`, obj1.x
obj1[1] = 42
assertEquals `undefined`, obj1[1]
obj2 = {}
assertTrue Object.isExtensible(obj2)
obj2.x = 42
assertEquals 42, obj2.x
assertTrue Object.isExtensible(obj2)
Object.preventExtensions obj2
assertEquals 42, obj2.x
obj2.y = 42
assertEquals `undefined`, obj2.y
obj2.x = 43
assertEquals 43, obj2.x
obj2.y = new ->
  42

assertEquals `undefined`, obj2.y
assertEquals 43, obj2.x
try
  Object.defineProperty obj2, "y",
    value: 42

catch e
  assertTrue /object is not extensible/.test(e)
assertEquals `undefined`, obj2.y
assertEquals 43, obj2.x
obj2[1] = 42
assertEquals `undefined`, obj2[1]
arr = new Array()
arr[1] = 10
Object.preventExtensions arr
arr[2] = 42
assertEquals 10, arr[1]
arr[1] = 42
assertEquals 42, arr[1]
parent = {}
parent.x = 42
Object.preventExtensions parent
child = Object.create(parent)
child.y = 42
parent.y = 29
Object.preventExtensions foo
foo.x = 29
assertEquals `undefined`, foo.x

# when Object.isExtensible(o) === false
# assignment should return right hand side value
o = Object.preventExtensions({})
v = o.v = 50
assertEquals `undefined`, o.v
assertEquals 50, v

# test same behavior as above, but for integer properties
n = o[0] = 100
assertEquals `undefined`, o[0]
assertEquals 100, n
