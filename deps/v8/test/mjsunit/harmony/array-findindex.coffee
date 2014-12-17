# Copyright 2013 the V8 project authors. All rights reserved.
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

# Flags: --harmony-arrays
assertEquals 1, Array::findIndex.length
a = [
  21
  22
  23
  24
]
assertEquals -1, a.findIndex(->
  false
)
assertEquals -1, a.findIndex((val) ->
  121 is val
)
assertEquals 0, a.findIndex(->
  true
)
assertEquals 1, a.findIndex((val) ->
  22 is val
), `undefined`
assertEquals 2, a.findIndex((val) ->
  23 is val
), null
assertEquals 3, a.findIndex((val) ->
  24 is val
)

#
# Test predicate is not called when array is empty
#
(->
  a = []
  l = -1
  o = -1
  v = -1
  k = -1
  a.findIndex (val, key, obj) ->
    o = obj
    l = obj.length
    v = val
    k = key
    false

  assertEquals -1, l
  assertEquals -1, o
  assertEquals -1, v
  assertEquals -1, k
  return
)()

#
# Test predicate is called with correct argumetns
#
(->
  a = ["b"]
  l = -1
  o = -1
  v = -1
  k = -1
  index = a.findIndex((val, key, obj) ->
    o = obj
    l = obj.length
    v = val
    k = key
    false
  )
  assertArrayEquals a, o
  assertEquals a.length, l
  assertEquals "b", v
  assertEquals 0, k
  assertEquals -1, index
  return
)()

#
# Test predicate is called array.length times
#
(->
  a = [
    1
    2
    3
    4
    5
  ]
  l = 0
  a.findIndex ->
    l++
    false

  assertEquals a.length, l
  return
)()

#
# Test Array.prototype.findIndex works with String
#
(->
  a = "abcd"
  l = -1
  o = -1
  v = -1
  k = -1
  index = Array::findIndex.call(a, (val, key, obj) ->
    o = obj.toString()
    l = obj.length
    v = val
    k = key
    false
  )
  assertEquals a, o
  assertEquals a.length, l
  assertEquals "d", v
  assertEquals 3, k
  assertEquals -1, index
  index = Array::findIndex.apply(a, [(val, key, obj) ->
    o = obj.toString()
    l = obj.length
    v = val
    k = key
    true
  ])
  assertEquals a, o
  assertEquals a.length, l
  assertEquals "a", v
  assertEquals 0, k
  assertEquals 0, index
  return
)()

#
# Test Array.prototype.findIndex works with exotic object
#
(->
  l = -1
  o = -1
  v = -1
  k = -1
  a =
    prop1: "val1"
    prop2: "val2"
    isValid: ->
      @prop1 is "val1" and @prop2 is "val2"

  Array::push.apply a, [
    30
    31
    32
  ]
  index = Array::findIndex.call(a, (val, key, obj) ->
    o = obj
    l = obj.length
    v = val
    k = key
    not obj.isValid()
  )
  assertArrayEquals a, o
  assertEquals 3, l
  assertEquals 32, v
  assertEquals 2, k
  assertEquals -1, index
  return
)()

#
# Test array modifications
#
(->
  a = [
    1
    2
    3
  ]
  a.findIndex (val) ->
    a.push val
    false

  assertArrayEquals [
    1
    2
    3
    1
    2
    3
  ], a
  assertEquals 6, a.length
  a = [
    1
    2
    3
  ]
  a.findIndex (val, key) ->
    a[key] = ++val
    false

  assertArrayEquals [
    2
    3
    4
  ], a
  assertEquals 3, a.length
  return
)()

#
# Test predicate is only called for existing elements
#
(->
  a = new Array(30)
  a[11] = 21
  a[7] = 10
  a[29] = 31
  count = 0
  a.findIndex ->
    count++
    false

  assertEquals 3, count
  return
)()

#
# Test thisArg
#
(->
  
  # Test String as a thisArg
  index = [
    1
    2
    3
  ].findIndex((val, key) ->
    @charAt(Number(key)) is String(val)
  , "321")
  assertEquals 1, index
  
  # Test object as a thisArg
  thisArg = elementAt: (key) ->
    this[key]

  Array::push.apply thisArg, [
    "c"
    "b"
    "a"
  ]
  index = [
    "a"
    "b"
    "c"
  ].findIndex((val, key) ->
    @elementAt(key) is val
  , thisArg)
  assertEquals 1, index
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].findIndex (->
    a.push this
    return
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].findIndex (->
    a.push this
    return
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].findIndex (->
    "use strict"
    a.push this
    return
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()

# Test exceptions
assertThrows "Array.prototype.findIndex.call(null, function() { })", TypeError
assertThrows "Array.prototype.findIndex.call(undefined, function() { })", TypeError
assertThrows "Array.prototype.findIndex.apply(null, function() { }, [])", TypeError
assertThrows "Array.prototype.findIndex.apply(undefined, function() { }, [])", TypeError
assertThrows "[].findIndex(null)", TypeError
assertThrows "[].findIndex(undefined)", TypeError
assertThrows "[].findIndex(0)", TypeError
assertThrows "[].findIndex(true)", TypeError
assertThrows "[].findIndex(false)", TypeError
assertThrows "[].findIndex(\"\")", TypeError
assertThrows "[].findIndex({})", TypeError
assertThrows "[].findIndex([])", TypeError
assertThrows "[].findIndex(/d+/)", TypeError
assertThrows "Array.prototype.findIndex.call({}, null)", TypeError
assertThrows "Array.prototype.findIndex.call({}, undefined)", TypeError
assertThrows "Array.prototype.findIndex.call({}, 0)", TypeError
assertThrows "Array.prototype.findIndex.call({}, true)", TypeError
assertThrows "Array.prototype.findIndex.call({}, false)", TypeError
assertThrows "Array.prototype.findIndex.call({}, \"\")", TypeError
assertThrows "Array.prototype.findIndex.call({}, {})", TypeError
assertThrows "Array.prototype.findIndex.call({}, [])", TypeError
assertThrows "Array.prototype.findIndex.call({}, /d+/)", TypeError
assertThrows "Array.prototype.findIndex.apply({}, null, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, undefined, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, 0, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, true, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, false, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, \"\", [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, {}, [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, [], [])", TypeError
assertThrows "Array.prototype.findIndex.apply({}, /d+/, [])", TypeError
