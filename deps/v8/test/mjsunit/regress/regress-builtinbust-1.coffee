# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
nope = ->
  false
a = [
  1
  2
  3
]
Object.seal a
Object.isSealed = nope
assertThrows (->
  a.pop()
  return
), TypeError
assertThrows (->
  a.push 5
  return
), TypeError
assertThrows (->
  a.shift()
  return
), TypeError
assertThrows (->
  a.unshift 5
  return
), TypeError
assertThrows (->
  a.splice 0, 1
  return
), TypeError
