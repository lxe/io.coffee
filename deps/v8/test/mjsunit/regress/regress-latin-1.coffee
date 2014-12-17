# Copyright 2013 the V8 project authors. All rights reserved.
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
assertEquals String.fromCharCode(97, 220, 256), "a" + "Ü" + "Ā"
assertEquals String.fromCharCode(97, 220, 256), "aÜĀ"
assertEquals 0x80, JSON.stringify("").charCodeAt(1)
assertEquals 0x80, JSON.stringify("", 0, null).charCodeAt(1)
assertEquals [
  "a"
  "b"
  "Ü"
], [
  "b"
  "Ü"
  "a"
].sort()
assertEquals [
  "üÜ"
  "ü"
], new RegExp("(Ü)\\1", "i").exec("üÜ")

# Same test but for all values in Latin-1 range.
total_lo = 0
i = 0

while i < 0xff
  base = String.fromCharCode(i)
  escaped = base
  escaped = "\\" + base  if base is "(" or base is ")" or base is "*" or base is "+" or base is "?" or base is "[" or base is "]" or base is "\\" or base is "$" or base is "^" or base is "|"
  lo = String.fromCharCode(i + 0x20)
  base_result = new RegExp("(" + escaped + ")\\1", "i").exec(base + base)
  assertEquals base_result, [
    base + base
    base
  ]
  lo_result = new RegExp("(" + escaped + ")\\1", "i").exec(base + lo)
  if base.toLowerCase() is lo
    assertEquals [
      base + lo
      base
    ], lo_result
    total_lo++
  else
    assertEquals null, lo_result
  i++

# Should have hit the branch for the following char codes:
# [A-Z], [192-222] but not 215
assertEquals (90 - 65 + 1) + (222 - 192 - 1 + 1), total_lo

# Latin-1 whitespace character
assertEquals 1, +(String.fromCharCode(0xa0) + "1")

# Latin-1 \W characters
assertEquals [
  "+£"
  "=="
], "+£==".match(/\W\W/g)

# Latin-1 character that uppercases out of Latin-1.
assertTrue /\u0178/i.test("ÿ")

# Unicode equivalence
assertTrue /\u039c/i.test("µ")
assertTrue /\u039c/i.test("μ")
assertTrue /\u00b5/i.test("μ")

# Unicode equivalence ranges
assertTrue /[\u039b-\u039d]/i.test("µ")
assertFalse /[^\u039b-\u039d]/i.test("µ")
assertFalse /[\u039b-\u039d]/.test("µ")
assertTrue /[^\u039b-\u039d]/.test("µ")

# Check a regression in QuoteJsonSlow and WriteQuoteJsonString
testNumber = 0

while testNumber < 2
  testString = "Ü"
  loopLength = (if testNumber is 0 then 0 else 20)
  i = 0

  while i < loopLength
    testString += testString
    i++
  stringified = JSON.stringify(
    test: testString
  , null, 0)
  stringifiedExpected = "{\"test\":\"" + testString + "\"}"
  assertEquals stringifiedExpected, stringified
  testNumber++
