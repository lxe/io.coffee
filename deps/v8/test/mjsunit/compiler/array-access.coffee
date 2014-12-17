# Copyright 2010 the V8 project authors. All rights reserved.
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
Get0 = (a) ->
  a[0]
GetN = (a, n) ->
  a[n]
GetA0 = (a) ->
  a[a[0]]
GetAN = (a, n) ->
  a[a[n]]
GetAAN = (a, n) ->
  a[a[a[n]]]
RunGetTests = ->
  a = [
    2
    0
    1
  ]
  assertEquals 2, Get0(a)
  assertEquals 2, GetN(a, 0)
  assertEquals 0, GetN(a, 1)
  assertEquals 1, GetN(a, 2)
  assertEquals 1, GetA0(a)
  assertEquals 1, GetAN(a, 0)
  assertEquals 2, GetAN(a, 1)
  assertEquals 0, GetAN(a, 2)
  assertEquals 0, GetAAN(a, 0)
  assertEquals 1, GetAAN(a, 1)
  assertEquals 2, GetAAN(a, 2)
  return
Set07 = (a) ->
  a[0] = 7
  return
Set0V = (a, v) ->
  a[0] = v
  return
SetN7 = (a, n) ->
  a[n] = 7
  return
SetNX = (a, n, x) ->
  a[n] = x
  return
RunSetTests = (a) ->
  Set07 a
  assertEquals 7, a[0]
  assertEquals 0, a[1]
  assertEquals 0, a[2]
  Set0V a, 1
  assertEquals 1, a[0]
  assertEquals 0, a[1]
  assertEquals 0, a[2]
  SetN7 a, 2
  assertEquals 1, a[0]
  assertEquals 0, a[1]
  assertEquals 7, a[2]
  SetNX a, 1, 5
  assertEquals 1, a[0]
  assertEquals 5, a[1]
  assertEquals 7, a[2]
  i = 0

  while i < 3
    SetNX a, i, 0
    i++
  assertEquals 0, a[0]
  assertEquals 0, a[1]
  assertEquals 0, a[2]
  return
RunArrayBoundsCheckTest = ->
  f = (a, i) ->
    a[i] = 42
    return
  g = [
    1
    2
    3
  ]
  i = 0

  while i < 100000
    f g, 0
    i++
  f g, 4
  assertEquals 42, g[0]
  assertEquals 42, g[4]
  return
a = [
  0
  0
  0
]
o =
  0: 0
  1: 0
  2: 0

i = 0

while i < 1000
  RunGetTests()
  RunSetTests a
  RunSetTests o
  i++
RunArrayBoundsCheckTest()
