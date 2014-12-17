# Copyright 2010 the V8 project authors. All rights reserved.
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

# Flags: --use-osr
f1 = ->
  sum = 0
  i = 0

  while i < 1000000
    x = i + 2
    y = x + 5
    z = y + 3
    sum += z
    i++
  sum
f2 = ->
  sum = 0
  i = 0

  while i < 1000000
    x = i + 2
    y = x + 5
    z = y + 3
    sum += z
    i++
  sum
f3 = ->
  sum = 0
  i = 0

  while i < 1000000
    x = i + 2
    y = x + 5
    z = y + 3
    sum += z
    i++
  sum
test1 = ->
  j = 11
  i = 0

  while i < 2
    assertEquals 500009500000, f1()
    i++
  return
test2 = ->
  i = 0

  while i < 2
    j = 11
    k = 12
    assertEquals 500009500000, f2()
    i++
  return
test3 = ->
  i = 0

  while i < 2
    j = 11
    k = 13
    m = 14
    assertEquals 500009500000, f3()
    i++
  return
test1()
test2()
test3()
