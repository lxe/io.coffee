# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# Copyright (C) 2011 by Ben Noordhuis <info@bnoordhuis.nl>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
common = require("../common")
punycode = require("punycode")
assert = require("assert")
assert.equal punycode.encode("ü"), "tda"
assert.equal punycode.encode("Goethe"), "Goethe-"
assert.equal punycode.encode("Bücher"), "Bcher-kva"
assert.equal punycode.encode("Willst du die Blüthe des frühen, die Früchte des späteren Jahres"), "Willst du die Blthe des frhen, die Frchte des spteren Jahres-x9e96lkal"
assert.equal punycode.encode("日本語"), "wgv71a119e"
assert.equal punycode.decode("tda"), "ü"
assert.equal punycode.decode("Goethe-"), "Goethe"
assert.equal punycode.decode("Bcher-kva"), "Bücher"
assert.equal punycode.decode("Willst du die Blthe des frhen, die Frchte des spteren Jahres-x9e96lkal"), "Willst du die Blüthe des frühen, die Früchte des späteren Jahres"
assert.equal punycode.decode("wgv71a119e"), "日本語"

# http://tools.ietf.org/html/rfc3492#section-7.1
tests =
  
  # (A) Arabic (Egyptian)
  egbpdaj6bu4bxfgehfvwxn: "ليهمابتكلمو" + "شعربي؟"
  
  # (B) Chinese (simplified)
  ihqwcrb4cv8a8dqg056pqjye: "他们为什么不说中文"
  
  # (C) Chinese (traditional)
  ihqwctvzc91f659drss3x8bo0yb: "他們爲什麽不說中文"
  
  # (D) Czech: Pro<ccaron>prost<ecaron>nemluv<iacute><ccaron>esky
  "Proprostnemluvesky-uyb24dma41a": "Pročprostěn" + "emluvíčesky"
  
  # (E) Hebrew
  "4dbcagdahymbxekheh6e0a7fei0b": "למההםפשוטלא" + "מדבריםעברית"
  
  # (F) Hindi (Devanagari)
  i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd: "यहलोगहिन्दी" + "क्योंनहींबो" + "लसकतेहैं"
  
  # (G) Japanese (kanji and hiragana)
  n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa: "なぜみんな日本語を話し" + "てくれないのか"
  
  # (H) Korean (Hangul syllables)
  "989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c": "세계의모든사람들이한국" + "어를이해한다면얼마나좋" + "을까"
  
  # (I) Russian (Cyrillic)
  # XXX disabled, fails - possibly a bug in the RFC
  #  'b1abfaaepdrnnbgefbaDotcwatmq2g4l':
  #      '\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438' +
  #      '\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E' +
  #      '\u0440\u0443\u0441\u0441\u043A\u0438',
  #  
  
  # (J) Spanish: Porqu<eacute>nopuedensimplementehablarenEspa<ntilde>ol
  "PorqunopuedensimplementehablarenEspaol-fmd56a": "Porquénopue" + "densimpleme" + "ntehablaren" + "Español"
  
  # (K) Vietnamese: T<adotbelow>isaoh<odotbelow>kh<ocirc>ngth
  # <ecirchookabove>ch<ihookabove>n<oacute>iti<ecircacute>ngVi<ecircdotbelow>t
  "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g": "Tạisaohọkhô" + "ngthểchỉnói" + "tiếngViệt"
  
  # (L) 3<nen>B<gumi><kinpachi><sensei>
  "3B-ww4c5e180e575a65lsy2b": "3年B組金八先生"
  
  # (M) <amuro><namie>-with-SUPER-MONKEYS
  "-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n": "安室奈美恵-with-" + "SUPER-MONKE" + "YS"
  
  # (N) Hello-Another-Way-<sorezore><no><basho>
  "Hello-Another-Way--fc4qua05auwb3674vfr0b": "Hello-Anoth" + "er-Way-それぞれ" + "の場所"
  
  # (O) <hitotsu><yane><no><shita>2
  "2-u9tlzr9756bt3uc0v": "ひとつ屋根の下2"
  
  # (P) Maji<de>Koi<suru>5<byou><mae>
  "MajiKoi5-783gue6qz075azm5e": "MajiでKoiする5" + "秒前"
  
  # (Q) <pafii>de<runba>
  "de-jg4avhby1noc0d": "パフィーdeルンバ"
  
  # (R) <sono><supiido><de>
  d9juau41awczczp: "そのスピードで"
  
  # (S) -> $1.00 <-
  "-> $1.00 <--": "-> $1.00 <-"

errors = 0
for encoded of tests
  decoded = tests[encoded]
  try
    assert.equal punycode.encode(decoded), encoded
  catch e
    console.error "FAIL: expected %j, got %j", e.expected, e.actual
    errors++
  try
    assert.equal punycode.decode(encoded), decoded
  catch e
    console.error "FAIL: expected %j, got %j", e.expected, e.actual
    errors++

# BMP code point
assert.equal punycode.ucs2.encode([0x61]), "a"

# supplementary code point (surrogate pair)
assert.equal punycode.ucs2.encode([0x1d306]), "𝌆"

# high surrogate
assert.equal punycode.ucs2.encode([0xd800]), "�"

# high surrogate followed by non-surrogates
assert.equal punycode.ucs2.encode([
  0xd800
  0x61
  0x62
]), "�ab"

# low surrogate
assert.equal punycode.ucs2.encode([0xdc00]), "�"

# low surrogate followed by non-surrogates
assert.equal punycode.ucs2.encode([
  0xdc00
  0x61
  0x62
]), "�ab"
assert.equal errors, 0
