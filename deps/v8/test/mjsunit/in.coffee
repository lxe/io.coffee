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

# ----------------
# Check fast objects
o = {}
assertFalse 0 of o
assertFalse "x" of o
assertFalse "y" of o
assertTrue "toString" of o, "toString"
o = x: 12
assertFalse 0 of o
assertTrue "x" of o
assertFalse "y" of o
assertTrue "toString" of o, "toString"
o =
  x: 12
  y: 15

assertFalse 0 of o
assertTrue "x" of o
assertTrue "y" of o
assertTrue "toString" of o, "toString"

# ----------------
# Check dense arrays
a = []
assertFalse 0 of a
assertFalse 1 of a
assertFalse "0" of a
assertFalse "1" of a
assertTrue "toString" of a, "toString"
a = [1]
assertTrue 0 of a
assertFalse 1 of a
assertTrue "0" of a
assertFalse "1" of a
assertTrue "toString" of a, "toString"
a = [
  1
  2
]
assertTrue 0 of a
assertTrue 1 of a
assertTrue "0" of a
assertTrue "1" of a
assertTrue "toString" of a, "toString"
a = [
  1
  2
]
assertFalse 0.001 of a
assertTrue -0 of a
assertTrue +0 of a
assertFalse "0.0" of a
assertFalse "1.0" of a
assertFalse NaN of a
assertFalse Infinity of a
assertFalse -Infinity of a
a = []
a[1] = 2
assertFalse 0 of a
assertTrue 1 of a
assertFalse 2 of a
assertFalse "0" of a
assertTrue "1" of a
assertFalse "2" of a
assertTrue "toString" of a, "toString"

# ----------------
# Check dictionary ("normalized") objects
o = {}
i = 0x0020

while i < 0x02ff
  o["char:" + String.fromCharCode(i)] = i
  i += 2
i = 0x0020

while i < 0x02ff
  assertTrue "char:" + String.fromCharCode(i) of o
  assertFalse "char:" + String.fromCharCode(i + 1) of o
  i += 2
assertTrue "toString" of o, "toString"
o = {}
o[Math.pow(2, 30) - 1] = 0
o[Math.pow(2, 31) - 1] = 0
o[1] = 0
assertFalse 0 of o
assertTrue 1 of o
assertFalse 2 of o
assertFalse Math.pow(2, 30) - 2 of o
assertTrue Math.pow(2, 30) - 1 of o
assertFalse Math.pow(2, 30) - 0 of o
assertTrue Math.pow(2, 31) - 1 of o
assertFalse 0.001 of o
assertFalse "0.0" of o
assertFalse "1.0" of o
assertFalse NaN of o
assertFalse Infinity of o
assertFalse -Infinity of o
assertFalse -0 of o
assertFalse +0 of o
assertTrue "toString" of o, "toString"

# ----------------
# Check sparse arrays
a = []
a[Math.pow(2, 30) - 1] = 0
a[Math.pow(2, 31) - 1] = 0
a[1] = 0
assertFalse 0 of a, "0 in a"
assertTrue 1 of a, "1 in a"
assertFalse 2 of a, "2 in a"
assertFalse Math.pow(2, 30) - 2 of a, "Math.pow(2,30)-2 in a"
assertTrue Math.pow(2, 30) - 1 of a, "Math.pow(2,30)-1 in a"
assertFalse Math.pow(2, 30) - 0 of a, "Math.pow(2,30)-0 in a"
assertTrue Math.pow(2, 31) - 1 of a, "Math.pow(2,31)-1 in a"
assertFalse 0.001 of a, "0.001 in a"
assertFalse "0.0" of a, "'0.0' in a"
assertFalse "1.0" of a, "'1.0' in a"
assertFalse NaN of a, "NaN in a"
assertFalse Infinity of a, "Infinity in a"
assertFalse -Infinity of a, "-Infinity in a"
assertFalse -0 of a, "-0 in a"
assertFalse +0 of a, "+0 in a"
assertTrue "toString" of a, "toString"

# -------------
# Check negative indices in arrays.
a = []
assertFalse -1 of a
a[-1] = 43
assertTrue -1 of a
