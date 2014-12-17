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
@fileoverview Test indexing on strings with [].
###
foo = "Foo"
assertEquals "Foo", foo
assertEquals "F", foo[0]
assertEquals "o", foo[1]
assertEquals "o", foo[2]

# Test string keyed load IC.
i = 0

while i < 10
  assertEquals "F", foo[0]
  assertEquals "o", foo[1]
  assertEquals "o", foo[2]
  assertEquals "F", (foo[0] + "BarBazQuuxFooBarQuux")[0]
  i++
assertEquals "F", foo["0" + ""], "string index"
assertEquals "o", foo["1"], "string index"
assertEquals "o", foo["2"], "string index"
assertEquals "undefined", typeof (foo[3]), "out of range"

# SpiderMonkey 1.5 fails this next one.  So does FF 2.0.6.
assertEquals "undefined", typeof (foo[-1]), "known failure in SpiderMonkey 1.5"
assertEquals "undefined", typeof (foo[-2]), "negative index"
foo[0] = "f"
assertEquals "Foo", foo
foo[3] = "t"
assertEquals "Foo", foo
assertEquals "undefined", typeof (foo[3]), "out of range"
assertEquals "undefined", typeof (foo[-2]), "negative index"
S = new String("foo")
assertEquals Object("foo"), S
assertEquals "f", S[0], "string object"
assertEquals "f", S["0"], "string object"
S[0] = "bente"
assertEquals "f", S[0], "string object"
assertEquals "f", S["0"], "string object"
S[-2] = "spider"
assertEquals "spider", S[-2]
S[3] = "monkey"
assertEquals "monkey", S[3]
S["foo"] = "Fu"
assertEquals "Fu", S.foo

# In FF this is ignored I think.  In V8 it puts a property on the String object
# but you won't ever see it because it is hidden by the 0th character in the
# string.  The net effect is pretty much the same.
S["0"] = "bente"
assertEquals "f", S[0], "string object"
assertEquals "f", S["0"], "string object"
assertEquals true, 0 of S, "0 in"
assertEquals false, -1 of S, "-1 in"
assertEquals true, 2 of S, "2 in"
assertEquals true, 3 of S, "3 in"
assertEquals false, 4 of S, "3 in"
assertEquals true, "0" of S, "\"0\" in"
assertEquals false, "-1" of S, "\"-1\" in"
assertEquals true, "2" of S, "\"2\" in"
assertEquals true, "3" of S, "\"3\" in"
assertEquals false, "4" of S, "\"3\" in"
assertEquals true, S.hasOwnProperty(0), "0 hasOwnProperty"
assertEquals false, S.hasOwnProperty(-1), "-1 hasOwnProperty"
assertEquals true, S.hasOwnProperty(2), "2 hasOwnProperty"
assertEquals true, S.hasOwnProperty(3), "3 hasOwnProperty"
assertEquals false, S.hasOwnProperty(4), "3 hasOwnProperty"
assertEquals true, S.hasOwnProperty("0"), "\"0\" hasOwnProperty"
assertEquals false, S.hasOwnProperty("-1"), "\"-1\" hasOwnProperty"
assertEquals true, S.hasOwnProperty("2"), "\"2\" hasOwnProperty"
assertEquals true, S.hasOwnProperty("3"), "\"3\" hasOwnProperty"
assertEquals false, S.hasOwnProperty("4"), "\"3\" hasOwnProperty"
assertEquals true, "foo".hasOwnProperty(0), "foo 0 hasOwnProperty"
assertEquals false, "foo".hasOwnProperty(-1), "foo -1 hasOwnProperty"
assertEquals true, "foo".hasOwnProperty(2), "foo 2 hasOwnProperty"
assertEquals false, "foo".hasOwnProperty(4), "foo 3 hasOwnProperty"
assertEquals true, "foo".hasOwnProperty("0"), "foo \"0\" hasOwnProperty"
assertEquals false, "foo".hasOwnProperty("-1"), "foo \"-1\" hasOwnProperty"
assertEquals true, "foo".hasOwnProperty("2"), "foo \"2\" hasOwnProperty"
assertEquals false, "foo".hasOwnProperty("4"), "foo \"3\" hasOwnProperty"

#assertEquals(true, 0 in "foo", "0 in");
#assertEquals(false, -1 in "foo", "-1 in");
#assertEquals(true, 2 in "foo", "2 in");
#assertEquals(false, 3 in "foo", "3 in");
#
#assertEquals(true, "0" in "foo", '"0" in');
#assertEquals(false, "-1" in "foo", '"-1" in');
#assertEquals(true, "2" in "foo", '"2" in');
#assertEquals(false, "3" in "foo", '"3" in');
delete S[3]

assertEquals "undefined", typeof (S[3])
assertEquals false, 3 of S
assertEquals false, "3" of S
N = new Number(43)
assertEquals Object(43), N
N[-2] = "Alpha"
assertEquals "Alpha", N[-2]
N[0] = "Zappa"
assertEquals "Zappa", N[0]
assertEquals "Zappa", N["0"]
A = [
  "V"
  "e"
  "t"
  "t"
  "e"
  "r"
]
A2 = (A[0] = "v")
assertEquals "v", A[0]
assertEquals "v", A2
S = new String("Onkel")
S2 = (S[0] = "o")
assertEquals "O", S[0]
assertEquals "o", S2
s = "Tante"
s2 = (s[0] = "t")
assertEquals "T", s[0]
assertEquals "t", s2
S2 = (S[-2] = "o")
assertEquals "o", S[-2]
assertEquals "o", S2
s2 = (s[-2] = "t")
assertEquals "undefined", typeof (s[-2])
assertEquals "t", s2

# Make sure enough of the one-char string cache is filled.
alpha = ["@"]
i = 1

while i < 128
  c = String.fromCharCode(i)
  alpha[i] = c[0]
  i++
alphaStr = alpha.join("")

# Now test chars.
i = 1

while i < 128
  assertEquals alpha[i], alphaStr[i]
  assertEquals String.fromCharCode(i), alphaStr[i]
  i++

# Test for keyed ic.
foo = [
  "a12"
  [
    "a"
    2
    "c"
  ]
  "a31"
  42
]
results = [
  1
  2
  3
  NaN
]
i = 0

while i < 200
  index = Math.floor(i / 50)
  receiver = foo[index]
  expected = results[index]
  actual = +(receiver[1])
  assertEquals expected, actual
  ++i
keys = [
  0
  "1"
  2
  3.0
  -1
  10
]
str = "abcd"
arr = [
  "a"
  "b"
  "c"
  "d"
  `undefined`
  `undefined`
]
i = 0

while i < 300
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i

# Test heap number case.
keys = [
  0
  Math.floor(2) * 0.5
]
str = "ab"
arr = [
  "a"
  "b"
]
i = 0

while i < 100
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i

# Test negative zero case.
keys = [
  0
  -0.0
]
str = "ab"
arr = [
  "a"
  "a"
]
i = 0

while i < 100
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i

# Test "not-an-array-index" case.
keys = [
  0
  0.5
]
str = "ab"
arr = [
  "a"
  `undefined`
]
i = 0

while i < 100
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i

# Test out of range case.
keys = [
  0
  -1
]
str = "ab"
arr = [
  "a"
  `undefined`
]
i = 0

while i < 100
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i
keys = [
  0
  10
]
str = "ab"
arr = [
  "a"
  `undefined`
]
i = 0

while i < 100
  index = Math.floor(i / 50)
  key = keys[index]
  expected = arr[index]
  actual = str[key]
  assertEquals expected, actual
  ++i

# Test two byte string.
str = "Ч"
arr = ["Ч"]
i = 0

while i < 50
  expected = arr[0]
  actual = str[0]
  assertEquals expected, actual
  ++i
