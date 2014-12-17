# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Test that Array builtins can be called on primitive values.

# Test that ToObject on primitive values is only called once.
length = ->
  length_receiver = this
  2
element = ->
  element_receiver = this
  "x"
test_receiver = (expected, call_string) ->
  assertDoesNotThrow call_string
  assertEquals new Number(expected), length_receiver
  assertSame length_receiver, element_receiver
  return
values = [
  23
  4.2
  true
  false
  0 / 0
]
i = 0

while i < values.length
  v = values[i]
  Array::join.call v
  Array::pop.call v
  Array::push.call v
  Array::reverse.call v
  Array::shift.call v
  Array::slice.call v
  Array::splice.call v
  Array::unshift.call v
  ++i
length_receiver = undefined
element_receiver = undefined
Object.defineProperty Number::, "length",
  get: length
  set: length

Object.defineProperty Number::, "0",
  get: element
  set: element

Object.defineProperty Number::, "1",
  get: element
  set: element

Object.defineProperty Number::, "2",
  get: element
  set: element

test_receiver 11, "Array.prototype.join.call(11)"
test_receiver 23, "Array.prototype.pop.call(23)"
test_receiver 42, "Array.prototype.push.call(42, 'y')"
test_receiver 49, "Array.prototype.reverse.call(49)"
test_receiver 65, "Array.prototype.shift.call(65)"
test_receiver 77, "Array.prototype.slice.call(77, 1)"
test_receiver 88, "Array.prototype.splice.call(88, 1, 1)"
test_receiver 99, "Array.prototype.unshift.call(99, 'z')"
