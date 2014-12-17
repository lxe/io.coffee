# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Tests taken from:
# http://mathias.html5.org/tests/javascript/string/
assertEquals "_".anchor("b"), "<a name=\"b\">_</a>"
assertEquals "<".anchor("<"), "<a name=\"<\"><</a>"
assertEquals "_".anchor(0x2a), "<a name=\"42\">_</a>"
assertEquals "_".anchor("\""), "<a name=\"&quot;\">_</a>"
assertEquals String::anchor.call(0x2a, 0x2a), "<a name=\"42\">42</a>"
assertThrows (->
  String::anchor.call `undefined`
  return
), TypeError
assertThrows (->
  String::anchor.call null
  return
), TypeError
assertEquals String::anchor.length, 1
assertEquals "_".big(), "<big>_</big>"
assertEquals "<".big(), "<big><</big>"
assertEquals String::big.call(0x2a), "<big>42</big>"
assertThrows (->
  String::big.call `undefined`
  return
), TypeError
assertThrows (->
  String::big.call null
  return
), TypeError
assertEquals String::big.length, 0
assertEquals "_".blink(), "<blink>_</blink>"
assertEquals "<".blink(), "<blink><</blink>"
assertEquals String::blink.call(0x2a), "<blink>42</blink>"
assertThrows (->
  String::blink.call `undefined`
  return
), TypeError
assertThrows (->
  String::blink.call null
  return
), TypeError
assertEquals String::blink.length, 0
assertEquals "_".bold(), "<b>_</b>"
assertEquals "<".bold(), "<b><</b>"
assertEquals String::bold.call(0x2a), "<b>42</b>"
assertThrows (->
  String::bold.call `undefined`
  return
), TypeError
assertThrows (->
  String::bold.call null
  return
), TypeError
assertEquals String::bold.length, 0
assertEquals "_".fixed(), "<tt>_</tt>"
assertEquals "<".fixed(), "<tt><</tt>"
assertEquals String::fixed.call(0x2a), "<tt>42</tt>"
assertThrows (->
  String::fixed.call `undefined`
  return
), TypeError
assertThrows (->
  String::fixed.call null
  return
), TypeError
assertEquals String::fixed.length, 0
assertEquals "_".fontcolor("b"), "<font color=\"b\">_</font>"
assertEquals "<".fontcolor("<"), "<font color=\"<\"><</font>"
assertEquals "_".fontcolor(0x2a), "<font color=\"42\">_</font>"
assertEquals "_".fontcolor("\""), "<font color=\"&quot;\">_</font>"
assertEquals String::fontcolor.call(0x2a, 0x2a), "<font color=\"42\">42</font>"
assertThrows (->
  String::fontcolor.call `undefined`
  return
), TypeError
assertThrows (->
  String::fontcolor.call null
  return
), TypeError
assertEquals String::fontcolor.length, 1
assertEquals "_".fontsize("b"), "<font size=\"b\">_</font>"
assertEquals "<".fontsize("<"), "<font size=\"<\"><</font>"
assertEquals "_".fontsize(0x2a), "<font size=\"42\">_</font>"
assertEquals "_".fontsize("\""), "<font size=\"&quot;\">_</font>"
assertEquals String::fontsize.call(0x2a, 0x2a), "<font size=\"42\">42</font>"
assertThrows (->
  String::fontsize.call `undefined`
  return
), TypeError
assertThrows (->
  String::fontsize.call null
  return
), TypeError
assertEquals String::fontsize.length, 1
assertEquals "_".italics(), "<i>_</i>"
assertEquals "<".italics(), "<i><</i>"
assertEquals String::italics.call(0x2a), "<i>42</i>"
assertThrows (->
  String::italics.call `undefined`
  return
), TypeError
assertThrows (->
  String::italics.call null
  return
), TypeError
assertEquals String::italics.length, 0
assertEquals "_".link("b"), "<a href=\"b\">_</a>"
assertEquals "<".link("<"), "<a href=\"<\"><</a>"
assertEquals "_".link(0x2a), "<a href=\"42\">_</a>"
assertEquals "_".link("\""), "<a href=\"&quot;\">_</a>"
assertEquals String::link.call(0x2a, 0x2a), "<a href=\"42\">42</a>"
assertThrows (->
  String::link.call `undefined`
  return
), TypeError
assertThrows (->
  String::link.call null
  return
), TypeError
assertEquals String::link.length, 1
assertEquals "_".small(), "<small>_</small>"
assertEquals "<".small(), "<small><</small>"
assertEquals String::small.call(0x2a), "<small>42</small>"
assertThrows (->
  String::small.call `undefined`
  return
), TypeError
assertThrows (->
  String::small.call null
  return
), TypeError
assertEquals String::small.length, 0
assertEquals "_".strike(), "<strike>_</strike>"
assertEquals "<".strike(), "<strike><</strike>"
assertEquals String::strike.call(0x2a), "<strike>42</strike>"
assertThrows (->
  String::strike.call `undefined`
  return
), TypeError
assertThrows (->
  String::strike.call null
  return
), TypeError
assertEquals String::strike.length, 0
assertEquals "_".sub(), "<sub>_</sub>"
assertEquals "<".sub(), "<sub><</sub>"
assertEquals String::sub.call(0x2a), "<sub>42</sub>"
assertThrows (->
  String::sub.call `undefined`
  return
), TypeError
assertThrows (->
  String::sub.call null
  return
), TypeError
assertEquals String::sub.length, 0
assertEquals "_".sup(), "<sup>_</sup>"
assertEquals "<".sup(), "<sup><</sup>"
assertEquals String::sup.call(0x2a), "<sup>42</sup>"
assertThrows (->
  String::sup.call `undefined`
  return
), TypeError
assertThrows (->
  String::sup.call null
  return
), TypeError
assertEquals String::sup.length, 0
