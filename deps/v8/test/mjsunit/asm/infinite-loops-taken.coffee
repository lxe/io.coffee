# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
counter = (x) ->
  ->
    throw error  if x-- is 0
    return
Module = ->
  w0 = (f) ->
    loop
      f()
    108
  w1 = (f) ->
    if 1
      loop
        f()
    109
  w2 = (f) ->
    if 1
      loop
        f()
    else
      loop
        f()
    110
  w3 = (f) ->
    if 0
      loop
        f()
    111
  "use asm"
  w0: w0
  w1: w1
  w2: w2
  w3: w3
error = "error"
m = Module()
assertThrows (->
  m.w0 counter(5)
  return
), error
assertThrows (->
  m.w1 counter(5)
  return
), error
assertThrows (->
  m.w2 counter(5)
  return
), error
assertEquals 111, m.w3(counter(5))
