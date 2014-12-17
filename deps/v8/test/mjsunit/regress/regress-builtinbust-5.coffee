# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
poison = ->
  was_called = true
  return
a = [
  1
  2
  3
]
was_called = false
a.hasOwnProperty = poison
Object.freeze a
assertThrows "a.unshift()", TypeError
assertEquals 3, a.length
assertFalse was_called
