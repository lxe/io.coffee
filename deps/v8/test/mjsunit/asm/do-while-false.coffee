# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = ->
  d0 = ->
    loop
      break unless false
    110
  d1 = ->
    loop
      return 111
      break unless false
    112
  d2 = ->
    loop
      break
      break unless false
    113
  d3 = (a) ->
    a = a | 0
    loop
      return 114  if a
      break unless false
    115
  d4 = (a) ->
    a = a | 0
    loop
      if a
        return 116
      else
        break
      break unless false
    117
  d5 = (a) ->
    a = a | 0
    loop
      return 118  if a
      break unless false
    119
  d6 = (a) ->
    a = a | 0
    loop
      return 120  if a is 0
      break  if a is 1
      return 122  if a is 2
      continue  if a is 3
      return 124  if a is 4
      break unless false
    125
  "use asm"
  d0: d0
  d1: d1
  d2: d2
  d3: d3
  d4: d4
  d5: d5
  d6: d6
m = Module()
assertEquals 110, m.d0()
assertEquals 111, m.d1()
assertEquals 113, m.d2()
assertEquals 114, m.d3(1)
assertEquals 115, m.d3(0)
assertEquals 116, m.d4(1)
assertEquals 117, m.d4(0)
assertEquals 118, m.d5(1)
assertEquals 119, m.d5(0)
assertEquals 120, m.d6(0)
assertEquals 125, m.d6(1)
assertEquals 122, m.d6(2)
assertEquals 125, m.d6(3)
assertEquals 124, m.d6(4)
assertEquals 125, m.d6(5)
