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
s = "abcdefghijklmn"
assertEquals s, s.substr()
assertEquals s, s.substr(0)
assertEquals s, s.substr("0")
assertEquals s, s.substr(undefined)
assertEquals s, s.substr(null)
assertEquals s, s.substr(false)
assertEquals s, s.substr(0.9)
assertEquals s, s.substr(valueOf: ->
  0
)
assertEquals s, s.substr(toString: ->
  "0"
)
s1 = s.substring(1)
assertEquals s1, s.substr(1)
assertEquals s1, s.substr("1")
assertEquals s1, s.substr(true)
assertEquals s1, s.substr(1.1)
assertEquals s1, s.substr(valueOf: ->
  1
)
assertEquals s1, s.substr(toString: ->
  "1"
)
assertEquals s.substring(s.length - 1), s.substr(-1)
assertEquals s.substring(s.length - 1), s.substr(-1.2)
assertEquals s.substring(s.length - 1), s.substr(-1.7)
assertEquals s.substring(s.length - 2), s.substr(-2)
assertEquals s.substring(s.length - 2), s.substr(-2.3)
assertEquals s.substring(s.length - 2, s.length - 1), s.substr(-2, 1)
assertEquals s, s.substr(-100)
assertEquals "abc", s.substr(-100, 3)
assertEquals s1, s.substr(-s.length + 1)

# assertEquals('', s.substr(0, void 0)); // smjs and rhino
assertEquals "abcdefghijklmn", s.substr(0, undefined) # kjs and v8
assertEquals "", s.substr(0, null)
assertEquals s, s.substr(0, String(s.length))
assertEquals "a", s.substr(0, true)

# Test substrings of different lengths and alignments.
# First ASCII.
x = "ASCII"
i = 0

while i < 25
  x += (i >> 4).toString(16) + (i & 0x0f).toString(16)
  i++
/x/.exec x # Try to force a flatten.
i = 5

while i < 25
  j = 0

  while j < 25
    z = x.substring(i, i + j)
    w = Math.random() * 42 # Allocate something new in new-space.
    assertEquals j, z.length
    k = 0

    while k < j
      assertEquals x.charAt(i + k), z.charAt(k)
      k++
    j++
  i++

# Then two-byte strings.
x = "UC16 " # Non-ascii char forces two-byte string.
i = 0

while i < 25
  x += (i >> 4).toString(16) + (i & 0x0f).toString(16)
  i++
/x/.exec x # Try to force a flatten.
i = 5

while i < 25
  j = 0

  while j < 25
    z = x.substring(i, i + j)
    w = Math.random() * 42 # Allocate something new in new-space.
    assertEquals j, z.length
    k = 0

    while k < j
      assertEquals x.charAt(i + k), z.charAt(k)
      k++
    j++
  i++

# Keep creating strings to to force allocation failure on substring creation.
x = "0123456789ABCDEF"
x += x # 2^5
x += x
x += x
x += x
x += x
x += x # 2^10
x += x
x += x
xl = x.length
cache = []
i = 0

while i < 10000
  z = x.substring(i % xl)
  assertEquals xl - (i % xl), z.length
  cache.push z
  i++

# Same with two-byte strings
x = " 123456789ABCDEF"
x += x # 2^5
x += x
x += x
x += x
x += x
x += x # 2^10
x += x
x += x
xl = x.length
cache = []
i = 0

while i < 10000
  z = x.substring(i % xl)
  assertEquals xl - (i % xl), z.length
  cache.push z
  i++

# Substring of substring.
cache = []
last = x
offset = 0
i = 0

while i < 64
  z = last.substring(i)
  last = z
  cache.push z
  offset += i
  i++
i = 63

while i >= 0
  z = cache.pop()
  assertTrue /\u2028123456789ABCDEF/.test(z)
  assertEquals xl - offset, z.length
  offset -= i
  i--
