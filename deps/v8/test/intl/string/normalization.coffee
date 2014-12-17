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

# Tests the new String.prototype.normalize method.

# Common use case when searching for 'not very exact' match.
# These are examples of data one might encounter in real use.
testRealUseCases = ->
  
  # Vietnamese legacy text, old Windows 9x / non-Unicode applications use
  # windows-1258 code page, which is neither precomposed, nor decomposed.
  assertEquals "tiếng Việt".normalize("NFKD"), "tiếng Việt".normalize("NFKD") # all precomposed
  
  # Various kinds of spaces
  # normal space
  assertEquals "Google Maps".normalize("NFKD"), "Google Maps".normalize("NFKD") # non-breaking space
  # normal space
  assertEquals "Google Maps".normalize("NFKD"), "Google Maps".normalize("NFKD") # en-space
  # normal space
  assertEquals "Google Maps".normalize("NFKD"), "Google Maps".normalize("NFKD") # em-space
  # normal space
  assertEquals "Google Maps".normalize("NFKD"), "Google　Maps".normalize("NFKC") # ideographic space
  
  # Latin small ligature "fi"
  assertEquals "fi".normalize("NFKD"), "ﬁ".normalize("NFKD")
  
  # ŀ, Latin small L with middle dot, used in Catalan and often represented
  # as decomposed for non-Unicode environments ( l + ·)
  assertEquals "l·".normalize("NFKD"), "ŀ".normalize("NFKD")
  
  # Legacy text, Japanese narrow Kana (MS-DOS & Win 3.x time)
  # パソコン  :  wide
  assertEquals "パソコン".normalize("NFKD"), "ﾊﾟｿｺﾝ".normalize("NFKD") # ﾊﾟｿｺﾝ  :  narrow
  # Also for Japanese, Latin fullwidth forms vs. ASCII
  assertEquals "ABCD".normalize("NFKD"), "ＡＢＣＤ".normalize("NFKD") # ＡＢＣＤ, fullwidth
  return
()
testEdgeCases = ->
  
  # Make sure we throw RangeError, as the standard requires.
  assertThrows "\"\".normalize(1234)", RangeError
  assertThrows "\"\".normalize(\"BAD\")", RangeError
  
  # The standard does not say what kind of exceptions we should throw, so we
  # will not be specific. But we still test that we throw errors.
  assertThrows "s.normalize()" # s is not defined
  assertThrows "var s = null; s.normalize()"
  assertThrows "var s = undefined; s.normalize()"
  assertThrows "var s = 1234; s.normalize()" # no normalize for non-strings
  return
()

# Several kinds of mappings. No need to be comprehensive, we don't test
# the ICU functionality, we only test C - JavaScript 'glue'
testData = [
  
  # org, default, NFC, NFD, NKFC, NKFD
  [ # Ç : Combining sequence, Latin 1
    "Ç"
    "Ç"
    "Ç"
    "Ç"
    "Ç"
  ]
  [ # Ș : Combining sequence, non-Latin 1
    "Ș"
    "Ș"
    "Ș"
    "Ș"
    "Ș"
  ]
  [ # 가 : Hangul
    "가"
    "가"
    "가"
    "가"
    "가"
  ]
  [ # ｶ : Narrow Kana
    "ｶ"
    "ｶ"
    "ｶ"
    "カ"
    "カ"
  ]
  [ # ¼ : Fractions
    "¼"
    "¼"
    "¼"
    "1⁄4"
    "1⁄4"
  ]
  [ # ǆ  : Latin ligature
    "ǆ"
    "ǆ"
    "ǆ"
    "dž"
    "dž"
  ]
  [ # s + dot above + dot below, ordering of combining marks
    "ṩ"
    "ṩ"
    "ṩ"
    "ṩ"
    "ṩ"
  ]
  [ # ㌀ : Squared characters
    "㌀"
    "㌀"
    "㌀"
    "アパート" # アパート
    "アパート" # アパート
  ]
  [ # ︷ : Vertical forms
    "︷"
    "︷"
    "︷"
    "{"
    "{"
  ]
  [ # ⁹ : superscript 9
    "⁹"
    "⁹"
    "⁹"
    "9"
    "9"
  ]
  [ # Arabic forms
    "ﻥﻦﻧﻨ"
    "ﻥﻦﻧﻨ"
    "ﻥﻦﻧﻨ"
    "نننن"
    "نننن"
  ]
  [ # ① : Circled
    "①"
    "①"
    "①"
    "1"
    "1"
  ]
  [ # ℌ : Font variants
    "ℌ"
    "ℌ"
    "ℌ"
    "H"
    "H"
  ]
  [ # Ω : Singleton, OHM sign vs. Greek capital letter OMEGA
    "Ω"
    "Ω"
    "Ω"
    "Ω"
    "Ω"
  ]
  [ # Long ligature, ARABIC LIGATURE JALLAJALALOUHOU
    "ﷻ"
    "ﷻ"
    "ﷻ"
    "جل جلاله"
    "جل جلاله"
  ]
]
testArray = ->
  kNFC = 1
  kNFD = 2
  kNFKC = 3
  kNFKD = 4
  i = 0

  while i < testData.length
    
    # the original, NFC and NFD should normalize to the same thing
    column = 0

    while column < 3
      str = testData[i][column]
      assertEquals str.normalize(), testData[i][kNFC] # defaults to NFC
      assertEquals str.normalize("NFC"), testData[i][kNFC]
      assertEquals str.normalize("NFD"), testData[i][kNFD]
      assertEquals str.normalize("NFKC"), testData[i][kNFKC]
      assertEquals str.normalize("NFKD"), testData[i][kNFKD]
      ++column
    ++i
  return
()
