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
dead1 = (a, b) ->
  a * b
  a << b
  a >> b
  a >>> b
  a | b
  a & b
  a ^ b
  a
dead2 = (a, b) ->
  (a | 0) * b
  (a | 0) << b
  (a | 0) >> b
  (a | 0) >>> b
  (a | 0) | b
  (a | 0) & b
  (a | 0) ^ b
  a
dead3 = (a, b) ->
  (if a is 2 then (a * b) else (b * a)) # dead
  a
dead4 = (a) ->
  z = 3
  i = 0
  while i < 3
    z * 3 # dead
    i++
  a
dead5 = (a) ->
  z = 3
  i = 0
  while i < 3
    z * 3 # dead
    z++
    i++
  w = z * a
  a # w is dead
assertTrue dead1(33, 32) is 33
assertTrue dead2(33, 32) is 33
assertTrue dead3(33, 32) is 33
assertTrue dead4(33) is 33
assertTrue dead5(33) is 33
assertTrue dead1(34, 7) is 34
assertTrue dead2(34, 7) is 34
assertTrue dead3(34, 7) is 34
assertTrue dead4(34) is 34
assertTrue dead5(34) is 34
assertTrue dead1(3.4, 0.1) is 3.4
assertTrue dead2(3.4, 0.1) is 3.4
assertTrue dead3(3.4, 0.1) is 3.4
assertTrue dead4(3.4) is 3.4
assertTrue dead5(3.4) is 3.4
