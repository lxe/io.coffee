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
innerArrayLiteral = (n) ->
  a = new Array(n)
  i = 0

  while i < n
    a[i] = i * 2 + 7
    i++
  a.join()
testConstructOfSizeSize = (n) ->
  str = innerArrayLiteral(n)
  a = eval("[" + str + "]")
  b = eval("new Array(" + str + ")")
  c = eval("Array(" + str + ")")
  assertEquals n, a.length
  assertArrayEquals a, b
  assertArrayEquals a, c
  return
loop_count = 5
i = 0

while i < loop_count
  a = new Array()
  b = Array()
  assertEquals 0, a.length
  assertEquals 0, b.length
  k = 0

  while k < 10
    assertEquals "undefined", typeof a[k]
    assertEquals "undefined", typeof b[k]
    k++
  i++
i = 0

while i < loop_count
  j = 0

  while j < 100
    a = new Array(j)
    b = Array(j)
    assertEquals j, a.length
    assertEquals j, b.length
    k = 0

    while k < j
      assertEquals "undefined", typeof a[k]
      assertEquals "undefined", typeof b[k]
      k++
    j++
  i++
i = 0

while i < loop_count
  a = new Array(0, 1)
  assertArrayEquals [
    0
    1
  ], a
  a = new Array(0, 1, 2)
  assertArrayEquals [
    0
    1
    2
  ], a
  a = new Array(0, 1, 2, 3)
  assertArrayEquals [
    0
    1
    2
    3
  ], a
  a = new Array(0, 1, 2, 3, 4)
  assertArrayEquals [
    0
    1
    2
    3
    4
  ], a
  a = new Array(0, 1, 2, 3, 4, 5)
  assertArrayEquals [
    0
    1
    2
    3
    4
    5
  ], a
  a = new Array(0, 1, 2, 3, 4, 5, 6)
  assertArrayEquals [
    0
    1
    2
    3
    4
    5
    6
  ], a
  a = new Array(0, 1, 2, 3, 4, 5, 6, 7)
  assertArrayEquals [
    0
    1
    2
    3
    4
    5
    6
    7
  ], a
  a = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8)
  assertArrayEquals [
    0
    1
    2
    3
    4
    5
    6
    7
    8
  ], a
  a = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  assertArrayEquals [
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
  ], a
  i++
i = 0

while i < loop_count
  
  # JSObject::kInitialMaxFastElementArray is 10000.
  j = 1000

  while j < 12000
    testConstructOfSizeSize j
    j += 1000
  i++
i = 0

while i < loop_count
  assertArrayEquals ["xxx"], new Array("xxx")
  assertArrayEquals ["xxx"], Array("xxx")
  assertArrayEquals [true], new Array(true)
  assertArrayEquals [false], Array(false)
  assertArrayEquals [a: 1], new Array(a: 1)
  assertArrayEquals [b: 2], Array(b: 2)
  i++
assertThrows "new Array(3.14)"
assertThrows "Array(2.72)"
