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
check_enumeration_order = (obj) ->
  value = 0
  for name of obj
    assertTrue value < obj[name]
  value = obj[name]
  return
make_object = (size) ->
  a = new Object()
  i = 0

  while i < size
    a["a_" + i] = i + 1
    i++
  check_enumeration_order a
  i = 0

  while i < size
    delete a["a_" + i]
    i += 3
  check_enumeration_order a
  return

# Validate the enumeration order for object up to 100 named properties.
make_literal_object = (size) ->
  code = "{ "
  i = 0

  while i < size - 1
    code += " a_" + i + " : " + (i + 1) + ", "
    i++
  code += "a_" + (size - 1) + " : " + size
  code += " }"
  eval "var a = " + code
  check_enumeration_order a
  return
j = 1

while j < 100
  make_object j
  j++

# Validate the enumeration order for object literals up to 100 named
# properties.
j = 1

while j < 100
  make_literal_object j
  j++

# We enumerate indexed properties in numerical order followed by
# named properties in insertion order, followed by indexed properties
# of the prototype object in numerical order, followed by named
# properties of the prototype object in insertion order, and so on.
#
# This enumeration order is not required by the specification, so
# this just documents our choice.
proto2 = {}
proto2[140000] = 0
proto2.a = 0
proto2[2] = 0
proto2[3] = 0 # also on the 'proto1' object
proto2.b = 0
proto2[4294967295] = 0
proto2.c = 0
proto2[4294967296] = 0
proto1 = {}
proto1[5] = 0
proto1.d = 0
proto1[3] = 0
proto1.e = 0
proto1.f = 0 # also on the 'o' object
o = {}
o[-23] = 0
o[300000000000] = 0
o[23] = 0
o.f = 0
o.g = 0
o[-4] = 0
o[42] = 0
o.__proto__ = proto1
proto1.__proto__ = proto2
expected = [ # indexed from 'o'
  "23"
  "42"
  "-23" # named from 'o'
  "300000000000"
  "f"
  "g"
  "-4"
  "3" # indexed from 'proto1'
  "5"
  "d" # named from 'proto1'
  "e"
  "2" # indexed from 'proto2'
  "140000"
  "4294967295"
  "a" # named from 'proto2'
  "b"
  "c"
  "4294967296"
]
actual = []
for p of o
  actual.push p
assertArrayEquals expected, actual
