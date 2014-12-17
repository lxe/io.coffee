# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = ->
  if0 = ->
    return 11  if 0
    12
  if1 = ->
    return 13  if 1
    14
  if2 = ->
    if 0
      15
    else
      16
  if3 = ->
    if 1
      17
    else
      18
  if4 = ->
    (if 1 then 19 else 20)
  if5 = ->
    (if 0 then 21 else 22)
  if6 = ->
    x = (if 0 then 23 else 24)
    x
  if7 = ->
    if 0
      x = (if 0 then 25 else 26)
    else
      x = (if 0 then 27 else 28)
    x
  if8 = ->
    if 0
      if 0
        x = (if 0 then 29 else 30)
      else
        x = (if 0 then 31 else 32)
    else
      if 0
        x = (if 0 then 33 else 34)
      else
        x = (if 0 then 35 else 36)
    x
  "use asm"
  if0: if0
  if1: if1
  if2: if2
  if3: if3
  if4: if4
  if5: if5
  if6: if6
  if7: if7
  if8: if8
Spec = (a, b, c) ->
  f = ->
    if xx
      if yy
        x = (if zz then 29 else 30)
      else
        x = (if zz then 31 else 32)
    else
      if yy
        x = (if zz then 33 else 34)
      else
        x = (if zz then 35 else 36)
    x
  "use asm"
  xx = a | 0
  yy = b | 0
  zz = c | 0
  f: f
m = Module()
assertEquals 12, m.if0()
assertEquals 13, m.if1()
assertEquals 16, m.if2()
assertEquals 17, m.if3()
assertEquals 19, m.if4()
assertEquals 22, m.if5()
assertEquals 24, m.if6()
assertEquals 28, m.if7()
assertEquals 36, m.if8()
assertEquals 36, Spec(0, 0, 0).f()
assertEquals 35, Spec(0, 0, 1).f()
assertEquals 34, Spec(0, 1, 0).f()
assertEquals 33, Spec(0, 1, 1).f()
assertEquals 32, Spec(1, 0, 0).f()
assertEquals 31, Spec(1, 0, 1).f()
assertEquals 30, Spec(1, 1, 0).f()
assertEquals 29, Spec(1, 1, 1).f()
