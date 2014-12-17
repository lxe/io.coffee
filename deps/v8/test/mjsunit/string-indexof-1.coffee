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
s = "test test test"
assertEquals 0, s.indexOf("t")
assertEquals 3, s.indexOf("t", 1)
assertEquals 5, s.indexOf("t", 4)
assertEquals 1, s.indexOf("e")
assertEquals 2, s.indexOf("s")
assertEquals 5, s.indexOf("test", 4)
assertEquals 5, s.indexOf("test", 5)
assertEquals 10, s.indexOf("test", 6)
assertEquals 0, s.indexOf("test", 0)
assertEquals 0, s.indexOf("test", -1)
assertEquals 0, s.indexOf("test")
assertEquals -1, s.indexOf("notpresent")
assertEquals -1, s.indexOf()
i = 0

while i < s.length + 10
  expected = (if i < s.length then i else s.length)
  assertEquals expected, s.indexOf("", i)
  i++
reString = "asdf[a-z]+(asdf)?"
assertEquals 4, reString.indexOf("[a-z]+")
assertEquals 10, reString.indexOf("(asdf)?")
assertEquals 1, String::indexOf.length

# Random greek letters
twoByteString = "ΚΑΣΣΕ"

# Test single char pattern
assertEquals 0, twoByteString.indexOf("Κ"), "Lamda"
assertEquals 1, twoByteString.indexOf("Α"), "Alpha"
assertEquals 2, twoByteString.indexOf("Σ"), "First Sigma"
assertEquals 3, twoByteString.indexOf("Σ", 3), "Second Sigma"
assertEquals 4, twoByteString.indexOf("Ε"), "Epsilon"
assertEquals -1, twoByteString.indexOf("Β"), "Not beta"

# Test multi-char pattern
assertEquals 0, twoByteString.indexOf("ΚΑ"), "lambda Alpha"
assertEquals 1, twoByteString.indexOf("ΑΣ"), "Alpha Sigma"
assertEquals 2, twoByteString.indexOf("ΣΣ"), "Sigma Sigma"
assertEquals 3, twoByteString.indexOf("ΣΕ"), "Sigma Epsilon"
assertEquals -1, twoByteString.indexOf("ΑΣΕ"), "Not Alpha Sigma Epsilon"

#single char pattern
assertEquals 4, twoByteString.indexOf("Ε")

# Test complex string indexOf algorithms. Only trigger for long strings.

# Long string that isn't a simple repeat of a shorter string.
long = "A"
i = 66 # from 'B' to 'K'

while i < 76
  long = long + String.fromCharCode(i) + long
  i++

# pattern of 15 chars, repeated every 16 chars in long
pattern = "ABACABADABACABA"
i = 0

while i < long.length - pattern.length
  index = long.indexOf(pattern, i)
  assertEquals (i + 15) & ~0xf, index, "Long ABACABA...-string at index " + i
  i += 7
assertEquals 510, long.indexOf("AJABACA"), "Long AJABACA, First J"
assertEquals 1534, long.indexOf("AJABACA", 511), "Long AJABACA, Second J"
pattern = "JABACABADABACABA"
assertEquals 511, long.indexOf(pattern), "Long JABACABA..., First J"
assertEquals 1535, long.indexOf(pattern, 512), "Long JABACABA..., Second J"

# Search for a non-ASCII string in a pure ASCII string.
asciiString = "arglebargleglopglyfarglebargleglopglyfarglebargleglopglyf"
assertEquals -1, asciiString.indexOf(" 61")

# Search in string containing many non-ASCII chars.
allCodePoints = []
i = 0

while i < 65536
  allCodePoints[i] = i
  i++
allCharsString = String.fromCharCode.apply(String, allCodePoints)

# Search for string long enough to trigger complex search with ASCII pattern
# and UC16 subject.
assertEquals -1, allCharsString.indexOf("notfound")

# Find substrings.
lengths = [ # Single char, simple and complex.
  1
  4
  15
]
indices = [
  0x5
  0x65
  0x85
  0x105
  0x205
  0x285
  0x2005
  0x2085
  0xfff0
]
lengthIndex = 0

while lengthIndex < lengths.length
  length = lengths[lengthIndex]
  i = 0

  while i < indices.length
    index = indices[i]
    pattern = allCharsString.substring(index, index + length)
    assertEquals index, allCharsString.indexOf(pattern)
    i++
  lengthIndex++
