# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = ->
  if0 = ->
    x = (if 0 then 11 else 12)
    (x is 11) | 0
  if1 = ->
    x = (if 1 then 13 else 14)
    (x is 13) | 0
  if2 = ->
    x = (if 0 then 15 else 16)
    (x isnt 15) | 0
  if3 = ->
    x = (if 1 then 17 else 18)
    (x isnt 17) | 0
  if4 = ->
    x = (if 0 then 19 else 20)
    y = (if (x is 19) then 21 else 22)
    y
  if5 = ->
    x = (if 1 then 23 else 24)
    y = (if (x is 23) then 25 else 26)
    y
  if6 = ->
    x = (if 0 then 27 else 28)
    y = (if (x is 27) then 29 else 30)
    z = (if (y is 29) then 31 else 32)
    z
  if7 = ->
    x = (if 1 then 33 else 34)
    y = (if (x is 33) then 35 else 36)
    z = (if (y is 35) then 37 else 38)
    w = (if (z is 37) then 39 else 40)
    w
  if8 = ->
    if 0
      x = (if 0 then 43 else 44)
      y = (if (x is 43) then 45 else 46)
      z = (if (y is 45) then 47 else 48)
      w = (if (z is 47) then 49 else 50)
    else
      x = (if 1 then 53 else 54)
      y = (if (x is 53) then 55 else 56)
      z = (if (y is 55) then 57 else 58)
      w = (if (z is 57) then 59 else 60)
    w
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
Spec = (a, b) ->
  f = ->
    if xx
      x = (if yy then 43 else 44)
      y = (if (x is 43) then 45 else 46)
      z = (if (y is 45) then 47 else 48)
      w = (if (z is 47) then 49 else 50)
    else
      x = (if yy then 53 else 54)
      y = (if (x is 53) then 55 else 56)
      z = (if (y is 55) then 57 else 58)
      w = (if (z is 57) then 59 else 60)
    w
  "use asm"
  xx = a | 0
  yy = b | 0
  f: f
m = Module()
assertEquals 0, m.if0()
assertEquals 1, m.if1()
assertEquals 1, m.if2()
assertEquals 0, m.if3()
assertEquals 22, m.if4()
assertEquals 25, m.if5()
assertEquals 32, m.if6()
assertEquals 39, m.if7()
assertEquals 59, m.if8()
assertEquals 60, Spec(0, 0).f()
assertEquals 59, Spec(0, 1).f()
assertEquals 50, Spec(1, 0).f()
assertEquals 49, Spec(1, 1).f()
