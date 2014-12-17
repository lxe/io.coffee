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
foo = (a, b) ->
  x = 0
  if a.f < b.f
    result = b.g - a.g
    x = not x
    result
  else
    result = a.g - b.g
    x = [x]
    result
description "This tests that if a variable is dead on OSR exit, it will at least contain a valid JS value."
array = []
i = 0

while i < 9
  code = ""
  code += "(function("
  j = 0

  while j < i
    code += ", "  if j
    code += "arg" + j
    ++j
  code += ") {\n"
  code += "    return "
  if i
    j = 0

    while j < i
      code += " + "  if j
      code += "arg" + j
      ++j
  else
    code += "void 0"
  code += ";\n"
  code += "})"
  array[i] = eval(code)
  ++i
firstArg =
  f: 2
  g: 3

secondArg =
  f: 3
  g: 4

i = 0

while i < 300
  code = ""
  code += "array[" + (((i / 2) | 0) % array.length) + "]("
  j = 0

  while j < (((i / 2) | 0) % array.length)
    code += ", "  if j
    code += i + j
    ++j
  if i is 150
    firstArg =
      f: 2
      g: 2.5

    secondArg =
      f: 3
      g: 3.5
  tmp = firstArg
  firstArg = secondArg
  secondArg = tmp
  code += "); foo(firstArg, secondArg)"
  shouldBe code, "1"
  ++i
