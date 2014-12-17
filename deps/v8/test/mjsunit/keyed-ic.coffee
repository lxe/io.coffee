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

# This test attempts to test the inline caching for keyed access.

# ----------------------------------------------------------------------
# Prototype accessor.
# ----------------------------------------------------------------------
runTest = ->
  prototypeTest = (change_index) ->
    i = 0

    while i < 10
      property = f[P]
      if i <= change_index
        assertEquals f::, property
      else
        assertEquals f.hasOwnProperty, property
      P = H  if i is change_index
      i++
    P = initial_P
    return
  initial_P = "prototype"
  P = initial_P
  H = "hasOwnProperty"
  f = ->

  i = 0

  while i < 10
    prototypeTest i
    i++
  f:: = 43
  i = 0

  while i < 10
    prototypeTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# Array length accessor.
# ----------------------------------------------------------------------
runTest = ->
  arrayLengthTest = (change_index) ->
    i = 0

    while i < 10
      l = a[L]
      if i <= change_index
        assertEquals 10, l
      else
        assertEquals `undefined`, l
      L = zero  if i is change_index
      i++
    L = initial_L
    return
  initial_L = "length"
  L = initial_L
  zero = "0"
  a = new Array(10)
  i = 0

  while i < 10
    arrayLengthTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# String length accessor.
# ----------------------------------------------------------------------
runTest = ->
  stringLengthTest = (change_index) ->
    i = 0

    while i < 10
      l = s[L]
      if i <= change_index
        assertEquals 4, l
      else
        assertEquals "a", l
      L = zero  if i is change_index
      i++
    L = initial_L
    return
  initial_L = "length"
  L = initial_L
  zero = "0"
  s = "asdf"
  i = 0

  while i < 10
    stringLengthTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# Field access.
# ----------------------------------------------------------------------
runTest = ->
  fieldTest = (change_index) ->
    i = 0

    while i < 10
      property = o[X]
      if i <= change_index
        assertEquals 42, property
      else
        assertEquals 43, property
      X = Y  if i is change_index
      i++
    X = initial_X
    return
  o =
    x: 42
    y: 43

  initial_X = "x"
  X = initial_X
  Y = "y"
  i = 0

  while i < 10
    fieldTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# Indexed access.
# ----------------------------------------------------------------------
runTest = ->
  fieldTest = (change_index) ->
    i = 0

    while i < 10
      property = o[X]
      if i <= change_index
        assertEquals 42, property
      else
        assertEquals 43, property
      X = Y  if i is change_index
      i++
    X = initial_X
    return
  o = [
    42
    43
  ]
  initial_X = 0
  X = initial_X
  Y = 1
  i = 0

  while i < 10
    fieldTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# Constant function access.
# ----------------------------------------------------------------------
runTest = ->
  fun = ->
  constantFunctionTest = (change_index) ->
    i = 0

    while i < 10
      property = o[F]
      if i <= change_index
        assertEquals fun, property
      else
        assertEquals 42, property
      F = X  if i is change_index
      i++
    F = initial_F
    return
  o = new Object()
  o.f = fun
  o.x = 42
  initial_F = "f"
  F = initial_F
  X = "x"
  i = 0

  while i < 10
    constantFunctionTest i
    i++
  return

runTest()

# ----------------------------------------------------------------------
# Keyed store field.
# ----------------------------------------------------------------------
runTest = ->
  fieldTest = (change_index) ->
    i = 0

    while i < 10
      o[X] = X
      property = o[X]
      if i <= change_index
        assertEquals "x", property
      else
        assertEquals "y", property
      X = Y  if i is change_index
      i++
    X = initial_X
    return
  o =
    x: 42
    y: 43

  initial_X = "x"
  X = initial_X
  Y = "y"
  i = 0

  while i < 10
    fieldTest i
    i++
  return

runTest()
