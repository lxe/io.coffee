# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
description "This test checks for potential edge case bugs with certain math transforms involving multiplication by 1 and unary plus."
values =
  someInt: 42
  someFloat: 42.42
  one: 1
  minusOne: -1
  zero: 0
  minusZero: -0
  infinity: Infinity
  minusInfinity: -Infinity
  notANumber: NaN
  nonNumberString: "x"
  someFloatString: "42.42"

numberForString =
  nonNumberString: "notANumber"
  someFloatString: "someFloat"

for name of values
  numForStr = (if numberForString[name] then numberForString[name] else name)
  shouldBe "values." + name + " * 1", "+values." + name
  shouldBe "values." + name + " * 1", stringify(values[numForStr])
  shouldBe "1 * values." + name, "+values." + name
  shouldBe "1 * values." + name, stringify(values[numForStr])
for name1 of values
  numForStr1 = (if numberForString[name1] then numberForString[name1] else name1)
  for name2 of values
    numForStr2 = (if numberForString[name2] then numberForString[name2] else name2)
    shouldBe "+values." + name1 + " * values." + name2, "values." + name1 + " * values." + name2
    shouldBe "+values." + name1 + " * values." + name2, stringify(values[name1] * values[name2])
    shouldBe "values." + name1 + " * +values." + name2, "values." + name1 + " * values." + name2
    shouldBe "values." + name1 + " * +values." + name2, stringify(values[name1] * values[name2])
    shouldBe "+values." + name1 + " * +values." + name2, "values." + name1 + " * values." + name2
    shouldBe "+values." + name1 + " * +values." + name2, stringify(values[name1] * values[name2])
    shouldBe "+values." + name1 + " / values." + name2, "values." + name1 + " / values." + name2
    shouldBe "+values." + name1 + " / values." + name2, stringify(values[name1] / values[name2])
    shouldBe "values." + name1 + " / +values." + name2, "values." + name1 + " / values." + name2
    shouldBe "values." + name1 + " / +values." + name2, stringify(values[name1] / values[name2])
    shouldBe "+values." + name1 + " / +values." + name2, "values." + name1 + " / values." + name2
    shouldBe "+values." + name1 + " / +values." + name2, stringify(values[name1] / values[name2])
    shouldBe "+values." + name1 + " - values." + name2, "values." + name1 + " - values." + name2
    shouldBe "+values." + name1 + " - values." + name2, stringify(values[name1] - values[name2])
    shouldBe "values." + name1 + " - +values." + name2, "values." + name1 + " - values." + name2
    shouldBe "values." + name1 + " - +values." + name2, stringify(values[name1] - values[name2])
    shouldBe "+values." + name1 + " - +values." + name2, "values." + name1 + " - values." + name2
    shouldBe "+values." + name1 + " - +values." + name2, stringify(values[name1] - values[name2])
