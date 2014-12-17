# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Module = ->
  w0 = (a) ->
    a = a | 0
    loop  if a
    42
  w1 = (a) ->
    a = a | 0
    loop
      return 42
    106
  d0 = (a) ->
    a = a | 0
    if a
      loop
        break unless 1
    42
  d1 = (a) ->
    a = a | 0
    loop
      return 42
      break unless 1
    107
  f0 = (a) ->
    a = a | 0
    loop  if a
    42
  f1 = (a) ->
    a = a | 0
    loop
      return 42
    108
  "use asm"
  w0: w0
  w1: w1
  d0: d0
  d1: d1
  f0: f0
  f1: f1
m = Module()
assertEquals 42, m.w0(0)
assertEquals 42, m.w1(0)
assertEquals 42, m.d0(0)
assertEquals 42, m.d1(0)
assertEquals 42, m.f0(0)
assertEquals 42, m.f1(0)
