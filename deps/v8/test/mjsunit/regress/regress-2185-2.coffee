# Copyright 2012 the V8 project authors. All rights reserved.
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

# These tests used to time out before this was fixed.
short = ->
  sum = 0
  i = 0

  while i < 1000
    a = [
      1
      4
      34
      23
      6
      123
      3
      2
      11
      515
      4
      33
      22
      2
      2
      1
      0
      123
      23
      42
      43
      1002
      44
      43
      101
      23
      55
      11
      101
      102
      45
      11
      404
      31415
      34
      53
      453
      45
      34
      5
      2
      35
      5
      345
      36
      45
      345
      3
      45
      3
      5
      5
      2
      2342344
      2234
      23
      2718
      1500
      2
      19
      22
      43
      41
      0
      -1
      33
      45
      78
    ]
    a.sort (a, b) ->
      a - b

    sum += a[0]
    i++
  sum
short_bench = (name, array) ->
  start = new Date()
  short()
  end = new Date()
  ms = end - start
  print "Short " + Math.floor(ms) + "ms"
  return
sawseq = (a, tooth) ->
  count = 0
  loop
    i = 0

    while i < tooth
      a.push i
      return a  if ++count >= LEN
      i++
  return
sawseq2 = (a, tooth) ->
  count = 0
  loop
    i = 0

    while i < tooth
      a.push i
      return a  if ++count >= LEN
      i++
    i = 0

    while i < tooth
      a.push tooth - i
      return a  if ++count >= LEN
      i++
  return
sawseq3 = (a, tooth) ->
  count = 0
  loop
    i = 0

    while i < tooth
      a.push tooth - i
      return a  if ++count >= LEN
      i++
  return
up = (a) ->
  i = 0

  while i < LEN
    a.push i
    i++
  a
down = (a) ->
  i = 0

  while i < LEN
    a.push LEN - i
    i++
  a
ran = (a) ->
  i = 0

  while i < LEN
    a.push Math.floor(Math.random() * LEN)
    i++
  a
bench = (name, array) ->
  start = new Date()
  array.sort (a, b) ->
    a - b

  end = new Date()
  i = 0

  while i < array.length - 1
    throw name + " " + i  if array[i] > array[i + 1]
    i++
  ms = end - start
  print name + " " + Math.floor(ms) + "ms"
  return
LEN = 2e4
random = ran([])
asc = up([])
desc = down([])
asc_desc = down(up([]))
desc_asc = up(down([]))
asc_asc = up(up([]))
desc_desc = down(down([]))
saw1 = sawseq([], 1000)
saw2 = sawseq([], 500)
saw3 = sawseq([], 200)
saw4 = sawseq2([], 200)
saw5 = sawseq3([], 200)
short_bench()
bench "random", random
bench "up", asc
bench "down", desc
bench "saw 1000", saw1
bench "saw 500", saw2
bench "saw 200", saw3
bench "saw 200 symmetric", saw4
bench "saw 200 down", saw4
bench "up, down", asc_desc
bench "up, up", asc_asc
bench "down, down", desc_desc
bench "down, up", desc_asc
