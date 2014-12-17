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

# Test ES5 sections 15.2.3.5 Object.create.
# We do not support nonconfigurable properties on objects so that is not
# tested.  We do test getters, setters, writable, enumerable and value.

# Check that no exceptions are thrown.

# Check that the right exception is thrown.
valueGet = ->
  ctr5++
  3
getterGet = ->
  ctr5++
  ->
    ctr6++
Object.create null
Object.create null, `undefined`
try
  Object.create 4
  assertTrue false
catch e
  assertTrue /Object or null/.test(e)
try
  Object.create "foo"
  print 2
  assertTrue false
catch e
  assertTrue /Object or null/.test(e)
ctr = 0
ctr2 = 0
ctr3 = 0
ctr4 = 0
ctr5 = 0
ctr6 = 1000
protoFoo = foo: ->
  ctr++
  return

fooValue = foo:
  writable: true
  value: ->
    ctr2++
    return

fooGetter = foo:
  get: ->
    ctr3++

fooSetter = foo:
  set: ->
    ctr4++

fooAmbiguous = foo:
  get: ->
    ctr3++

  value: 3


# Simple object with prototype, no properties added.
Object.create(protoFoo).foo()
assertEquals 1, ctr

# Simple object with object with prototype, no properties added.
Object.create(Object.create(protoFoo)).foo()
assertEquals 2, ctr

# Add a property foo that returns a function.
v = Object.create(protoFoo, fooValue)
v.foo()
assertEquals 2, ctr
assertEquals 1, ctr2

# Ensure the property is writable.
v.foo = 42
assertEquals 42, v.foo
assertEquals 2, ctr
assertEquals 1, ctr2

# Ensure by default properties are not writable.
v = Object.create(null,
  foo:
    value: 103
)
assertEquals 103, v.foo
v.foo = 42
assertEquals 103, v.foo

# Add a getter foo that returns a counter value.
assertEquals 0, Object.create(protoFoo, fooGetter).foo
assertEquals 2, ctr
assertEquals 1, ctr2
assertEquals 1, ctr3

# Add a setter foo that runs a function.
assertEquals 1, Object.create(protoFoo, fooSetter).foo = 1
assertEquals 2, ctr
assertEquals 1, ctr2
assertEquals 1, ctr3
assertEquals 1, ctr4

# Make sure that trying to add both a value and a getter
# will result in an exception.
try
  Object.create protoFoo, fooAmbiguous
  assertTrue false
catch e
  assertTrue /Invalid property/.test(e)
assertEquals 2, ctr
assertEquals 1, ctr2
assertEquals 1, ctr3
assertEquals 1, ctr4
ctr7 = 0
metaProps =
  enumerable:
    get: ->
      assertEquals 0, ctr7++
      true

  configurable:
    get: ->
      assertEquals 1, ctr7++
      true

  value:
    get: ->
      assertEquals 2, ctr7++
      4

  writable:
    get: ->
      assertEquals 3, ctr7++
      true

  get:
    get: ->
      assertEquals 4, ctr7++
      ->

  set:
    get: ->
      assertEquals 5, ctr7++
      ->


# Instead of a plain props object, let's use getters to return its properties.
magicValueProps = foo: Object.create(null,
  value:
    get: valueGet
)
magicGetterProps = foo: Object.create(null,
  get:
    get: getterGet
)
magicAmbiguousProps = foo: Object.create(null, metaProps)
assertEquals 3, Object.create(null, magicValueProps).foo
assertEquals 1, ctr5
assertEquals 1000, Object.create(null, magicGetterProps).foo
assertEquals 2, ctr5

# See if we do the steps in ToPropertyDescriptor in the right order.
# We shouldn't throw the exception for an ambiguous properties object
# before we got all the values out.
try
  Object.create null, magicAmbiguousProps
  assertTrue false
catch e
  assertTrue /Invalid property/.test(e)
  assertEquals 6, ctr7
magicWritableProps = foo: Object.create(null,
  value:
    value: 4

  writable:
    get: ->
      ctr6++
      false
)
fooNotWritable = Object.create(null, magicWritableProps)
assertEquals 1002, ctr6
assertEquals 4, fooNotWritable.foo
fooNotWritable.foo = 5
assertEquals 4, fooNotWritable.foo

# Test enumerable flag.
fooNotEnumerable = Object.create(
  fizz: 14
,
  foo:
    value: 3
    enumerable: false

  bar:
    value: 4
    enumerable: true

  baz:
    value: 5
)
sum = 0
for x of fooNotEnumerable
  assertTrue x is "bar" or x is "fizz"
  sum += fooNotEnumerable[x]
assertEquals 18, sum
try
  Object.create null,
    foo:
      get: 0

  assertTrue false
catch e
  assertTrue /Getter must be a function/.test(e)
try
  Object.create null,
    foo:
      set: 0

  assertTrue false
catch e
  assertTrue /Setter must be a function/.test(e)
try
  Object.create null,
    foo:
      set: 0
      get: 0

  assertTrue false
catch e
  assertTrue /Getter must be a function/.test(e)

# Ensure that only enumerable own properties on the descriptor are used.
tricky = Object.create(
  foo:
    value: 1
    enumerable: true
,
  bar:
    value:
      value: 2
      enumerable: true

    enumerable: false

  baz:
    value:
      value: 4
      enumerable: false

    enumerable: true

  fizz:
    value:
      value: 8
      enumerable: false

    enumerable: false

  buzz:
    value:
      value: 16
      enumerable: true

    enumerable: true
)
assertEquals 1, tricky.foo.value
assertEquals 2, tricky.bar.value
assertEquals 4, tricky.baz.value
assertEquals 8, tricky.fizz.value
assertEquals 16, tricky.buzz.value
sonOfTricky = Object.create(null, tricky)
assertFalse "foo" of sonOfTricky
assertFalse "bar" of sonOfTricky
assertTrue "baz" of sonOfTricky
assertFalse "fizz" of sonOfTricky
assertTrue "buzz" of sonOfTricky
sum = 0
for x of sonOfTricky
  assertTrue x is "buzz"
  sum += sonOfTricky[x]
assertEquals 16, sum
