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

# Tests for non-standard array iteration functions.
#
# See
#
# <http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Objects:Array>
#
# for an explanation of each of the functions.

#
# Array.prototype.filter
#
(->
  
  # Simple use.
  a = [
    0
    1
  ]
  assertArrayEquals [0], a.filter((n) ->
    n is 0
  )
  assertArrayEquals [
    0
    1
  ], a
  
  # Use specified object as this object when calling the function.
  o = value: 42
  a = [
    1
    42
    3
    42
    4
  ]
  assertArrayEquals [
    42
    42
  ], a.filter((n) ->
    @value is n
  , o)
  
  # Modify original array.
  a = [
    1
    42
    3
    42
    4
  ]
  assertArrayEquals [
    42
    42
  ], a.filter((n, index, array) ->
    array[index] = 43
    42 is n
  )
  assertArrayEquals [
    43
    43
    43
    43
    43
  ], a
  
  # Only loop through initial part of array eventhough elements are
  # added.
  a = [
    1
    1
  ]
  assertArrayEquals [], a.filter((n, index, array) ->
    array.push n + 1
    n is 2
  )
  assertArrayEquals [
    1
    1
    2
    2
  ], a
  
  # Respect holes.
  a = new Array(20)
  count = 0
  a[2] = 2
  a[15] = 2
  a[17] = 4
  a = a.filter((n) ->
    count++
    n is 2
  )
  assertEquals 3, count
  for i of a
    assertEquals 2, a[i]
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].filter (->
    a.push this
    return
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].filter (->
    a.push this
    return
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].filter (->
    "use strict"
    a.push this
    return
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()

#
# Array.prototype.forEach
#
(->
  
  # Simple use.
  a = [
    0
    1
  ]
  count = 0
  a.forEach (n) ->
    count++
    return

  assertEquals 2, count
  
  # Use specified object as this object when calling the function.
  o = value: 42
  result = []
  a.forEach ((n) ->
    result.push @value
    return
  ), o
  assertArrayEquals [
    42
    42
  ], result
  
  # Modify original array.
  a = [
    0
    1
  ]
  count = 0
  a.forEach (n, index, array) ->
    array[index] = n + 1
    count++
    return

  assertEquals 2, count
  assertArrayEquals [
    1
    2
  ], a
  
  # Only loop through initial part of array eventhough elements are
  # added.
  a = [
    1
    1
  ]
  count = 0
  a.forEach (n, index, array) ->
    array.push n + 1
    count++
    return

  assertEquals 2, count
  assertArrayEquals [
    1
    1
    2
    2
  ], a
  
  # Respect holes.
  a = new Array(20)
  count = 0
  a[15] = 2
  a.forEach (n) ->
    count++
    return

  assertEquals 1, count
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].forEach (->
    a.push this
    return
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].forEach (->
    a.push this
    return
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].forEach (->
    "use strict"
    a.push this
    return
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()

#
# Array.prototype.every
#
(->
  
  # Simple use.
  a = [
    0
    1
  ]
  assertFalse a.every((n) ->
    n is 0
  )
  a = [
    0
    0
  ]
  assertTrue a.every((n) ->
    n is 0
  )
  assertTrue [].every((n) ->
    n is 0
  )
  
  # Use specified object as this object when calling the function.
  o = value: 42
  a = [0]
  assertFalse a.every((n) ->
    @value is n
  , o)
  a = [42]
  assertTrue a.every((n) ->
    @value is n
  , o)
  
  # Modify original array.
  a = [
    0
    1
  ]
  assertFalse a.every((n, index, array) ->
    array[index] = n + 1
    n is 1
  )
  assertArrayEquals [
    1
    1
  ], a
  
  # Only loop through initial part of array eventhough elements are
  # added.
  a = [
    1
    1
  ]
  assertTrue a.every((n, index, array) ->
    array.push n + 1
    n is 1
  )
  assertArrayEquals [
    1
    1
    2
    2
  ], a
  
  # Respect holes.
  a = new Array(20)
  count = 0
  a[2] = 2
  a[15] = 2
  assertTrue a.every((n) ->
    count++
    n is 2
  )
  assertEquals 2, count
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].every (->
    a.push this
    true
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].every (->
    a.push this
    true
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].every (->
    "use strict"
    a.push this
    true
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()

#
# Array.prototype.map
#
(->
  a = [
    0
    1
    2
    3
    4
  ]
  
  # Simple use.
  result = [
    1
    2
    3
    4
    5
  ]
  assertArrayEquals result, a.map((n) ->
    n + 1
  )
  assertEquals a, a
  
  # Use specified object as this object when calling the function.
  o = delta: 42
  result = [
    42
    43
    44
    45
    46
  ]
  assertArrayEquals result, a.map((n) ->
    @delta + n
  , o)
  
  # Modify original array.
  a = [
    0
    1
    2
    3
    4
  ]
  result = [
    1
    2
    3
    4
    5
  ]
  assertArrayEquals result, a.map((n, index, array) ->
    array[index] = n + 1
    n + 1
  )
  assertArrayEquals result, a
  
  # Only loop through initial part of array eventhough elements are
  # added.
  a = [
    0
    1
    2
    3
    4
  ]
  result = [
    1
    2
    3
    4
    5
  ]
  assertArrayEquals result, a.map((n, index, array) ->
    array.push n
    n + 1
  )
  assertArrayEquals [
    0
    1
    2
    3
    4
    0
    1
    2
    3
    4
  ], a
  
  # Respect holes.
  a = new Array(20)
  a[15] = 2
  a = a.map((n) ->
    2 * n
  )
  for i of a
    assertEquals 4, a[i]
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].map (->
    a.push this
    return
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].map (->
    a.push this
    return
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].map (->
    "use strict"
    a.push this
    return
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()

#
# Array.prototype.some
#
(->
  a = [
    0
    1
    2
    3
    4
  ]
  
  # Simple use.
  assertTrue a.some((n) ->
    n is 3
  )
  assertFalse a.some((n) ->
    n is 5
  )
  
  # Use specified object as this object when calling the function.
  o = element: 42
  a = [
    1
    42
    3
  ]
  assertTrue a.some((n) ->
    @element is n
  , o)
  a = [1]
  assertFalse a.some((n) ->
    @element is n
  , o)
  
  # Modify original array.
  a = [
    0
    1
    2
    3
  ]
  assertTrue a.some((n, index, array) ->
    array[index] = n + 1
    n is 2
  )
  assertArrayEquals [
    1
    2
    3
    3
  ], a
  
  # Only loop through initial part when elements are added.
  a = [
    0
    1
    2
  ]
  assertFalse a.some((n, index, array) ->
    array.push 42
    n is 42
  )
  assertArrayEquals [
    0
    1
    2
    42
    42
    42
  ], a
  
  # Respect holes.
  a = new Array(20)
  count = 0
  a[2] = 42
  a[10] = 2
  a[15] = 42
  assertTrue a.some((n) ->
    count++
    n is 2
  )
  assertEquals 2, count
  
  # Create a new object in each function call when receiver is a
  # primitive value. See ECMA-262, Annex C.
  a = []
  [
    1
    2
  ].some (->
    a.push this
    return
  ), ""
  assertTrue a[0] isnt a[1]
  
  # Do not create a new object otherwise.
  a = []
  [
    1
    2
  ].some (->
    a.push this
    return
  ), {}
  assertEquals a[0], a[1]
  
  # In strict mode primitive values should not be coerced to an object.
  a = []
  [
    1
    2
  ].some (->
    "use strict"
    a.push this
    return
  ), ""
  assertEquals "", a[0]
  assertEquals a[0], a[1]
  return
)()
