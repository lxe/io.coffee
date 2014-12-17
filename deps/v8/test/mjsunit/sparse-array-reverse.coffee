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

###*
@fileoverview Test reverse on small * and large arrays.
###

# Nicer for firefox 1.5.  Unless you uncomment the following line,
# smjs will appear to hang on this file.
#var VERYLARGE = 40000;

# Simple test of reverse on sparse array.
# Should be hidden by a[30].
# Should leave no trace once deleted.
# Swapped with a[40] when reversing.

# CONG pseudo random number generator.  Used for fuzzing the sparse array
# reverse code.
DoOrDont = ->
  seed = (69069 * seed + 1234567) % 0x100000000
  (seed & 0x100000) isnt 0
VERYLARGE = 4000000000
a = []
a.length = 2000
a[15] = "a"
a[30] = "b"
Array::[30] = "B"
a[40] = "c"
a[50] = "deleted"
delete a[50]

a[1959] = "d"
a[1999] = "e"
assertEquals "abcde", a.join("")
a.reverse()
delete Array::[30]

assertEquals "edcba", a.join("")
seed = 43
sizes = [
  140
  40000
  VERYLARGE
]
poses = [
  0
  10
  50
  69
]

# Fuzzing test of reverse on sparse array.
iterations = 0

while iterations < 20
  size_pos = 0

  while size_pos < sizes.length
    size = sizes[size_pos]
    to_delete = []
    a = undefined
    
    # Make sure we test both array-backed and hash-table backed
    # arrays.
    if size < 1000
      a = new Array(size)
    else
      a = new Array()
      a.length = size
    expected = ""
    expected_reversed = ""
    pos_pos = 0

    while pos_pos < poses.length
      pos = poses[pos_pos]
      letter = String.fromCharCode(97 + pos_pos)
      if DoOrDont()
        a[pos] = letter
        expected += letter
        expected_reversed = letter + expected_reversed
      else if DoOrDont()
        Array::[pos] = letter
        expected += letter
        expected_reversed = letter + expected_reversed
        to_delete.push pos
      pos_pos++
    expected2 = ""
    expected_reversed2 = ""
    pos_pos = poses.length - 1

    while pos_pos >= 0
      letter = String.fromCharCode(110 + pos_pos)
      pos = size - poses[pos_pos] - 1
      if DoOrDont()
        a[pos] = letter
        expected2 += letter
        expected_reversed2 = letter + expected_reversed2
      else if DoOrDont()
        Array::[pos] = letter
        expected2 += letter
        expected_reversed2 = letter + expected_reversed2
        to_delete.push pos
      pos_pos--
    assertEquals expected + expected2, a.join(""), "join" + size
    a.reverse()
    until to_delete.length is 0
      pos = to_delete.pop()
      delete (Array::[pos])
    assertEquals expected_reversed2 + expected_reversed, a.join(""), "reverse then join" + size
    size_pos++
  iterations++
