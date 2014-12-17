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

# Allocate a very large object that is guaranteed to overflow the
# instance_size field in the map resulting in an object that is smaller
# than what was called for.
LargeObject = (i) ->
  @a = i
  @b = i
  @c = i
  @d = i
  @e = i
  @f = i
  @g = i
  @h = i
  @i = i
  @j = i
  @k = i
  @l = i
  @m = i
  @n = i
  @o = i
  @p = i
  @q = i
  @r = i
  @s = i
  @t = i
  @u = i
  @v = i
  @w = i
  @x = i
  @y = i
  @z = i
  @a1 = i
  @b1 = i
  @c1 = i
  @d1 = i
  @e1 = i
  @f1 = i
  @g1 = i
  @h1 = i
  @i1 = i
  @j1 = i
  @k1 = i
  @l1 = i
  @m1 = i
  @n1 = i
  @o1 = i
  @p1 = i
  @q1 = i
  @r1 = i
  @s1 = i
  @t1 = i
  @u1 = i
  @v1 = i
  @w1 = i
  @x1 = i
  @y1 = i
  @z1 = i
  @a2 = i
  @b2 = i
  @c2 = i
  @d2 = i
  @e2 = i
  @f2 = i
  @g2 = i
  @h2 = i
  @i2 = i
  @j2 = i
  @k2 = i
  @l2 = i
  @m2 = i
  @n2 = i
  @o2 = i
  @p2 = i
  @q2 = i
  @r2 = i
  @s2 = i
  @t2 = i
  @u2 = i
  @v2 = i
  @w2 = i
  @x2 = i
  @y2 = i
  @z2 = i
  @a3 = i
  @b3 = i
  @c3 = i
  @d3 = i
  @e3 = i
  @f3 = i
  @g3 = i
  @h3 = i
  @i3 = i
  @j3 = i
  @k3 = i
  @l3 = i
  @m3 = i
  @n3 = i
  @o3 = i
  @p3 = i
  @q3 = i
  @r3 = i
  @s3 = i
  @t3 = i
  @u3 = i
  @v3 = i
  @w3 = i
  @x3 = i
  @y3 = i
  @z3 = i
  @a4 = i
  @b4 = i
  @c4 = i
  @d4 = i
  @e4 = i
  @f4 = i
  @g4 = i
  @h4 = i
  @i4 = i
  @j4 = i
  @k4 = i
  @l4 = i
  @m4 = i
  @n4 = i
  @o4 = i
  @p4 = i
  @q4 = i
  @r4 = i
  @s4 = i
  @t4 = i
  @u4 = i
  @v4 = i
  @w4 = i
  @x4 = i
  @y4 = i
  @z4 = i
  @a5 = i
  @b5 = i
  @c5 = i
  @d5 = i
  @e5 = i
  @f5 = i
  @g5 = i
  @h5 = i
  @i5 = i
  @j5 = i
  @k5 = i
  @l5 = i
  @m5 = i
  @n5 = i
  @o5 = i
  @p5 = i
  @q5 = i
  @r5 = i
  @s5 = i
  @t5 = i
  @u5 = i
  @v5 = i
  @w5 = i
  @x5 = i
  @y5 = i
  @z5 = i
  @a6 = i
  @b6 = i
  @c6 = i
  @d6 = i
  @e6 = i
  @f6 = i
  @g6 = i
  @h6 = i
  @i6 = i
  @j6 = i
  @k6 = i
  @l6 = i
  @m6 = i
  @n6 = i
  @o6 = i
  @p6 = i
  @q6 = i
  @r6 = i
  @s6 = i
  @t6 = i
  @u6 = i
  @v6 = i
  @w6 = i
  @x6 = i
  @y6 = i
  @z6 = i
  @a7 = i
  @b7 = i
  @c7 = i
  @d7 = i
  @e7 = i
  @f7 = i
  @g7 = i
  @h7 = i
  @i7 = i
  @j7 = i
  @k7 = i
  @l7 = i
  @m7 = i
  @n7 = i
  @o7 = i
  @p7 = i
  @q7 = i
  @r7 = i
  @s7 = i
  @t7 = i
  @u7 = i
  @v7 = i
  @w7 = i
  @x7 = i
  @y7 = i
  @z7 = i
  @a8 = i
  @b8 = i
  @c8 = i
  @d8 = i
  @e8 = i
  @f8 = i
  @g8 = i
  @h8 = i
  @i8 = i
  @j8 = i
  @k8 = i
  @l8 = i
  @m8 = i
  @n8 = i
  @o8 = i
  @p8 = i
  @q8 = i
  @r8 = i
  @s8 = i
  @t8 = i
  @u8 = i
  @v8 = i
  @w8 = i
  @x8 = i
  @y8 = i
  @z8 = i
  @a9 = i
  @b9 = i
  @c9 = i
  @d9 = i
  @e9 = i
  @f9 = i
  @g9 = i
  @h9 = i
  @i9 = i
  @j9 = i
  @k9 = i
  @l9 = i
  @m9 = i
  @n9 = i
  @o9 = i
  @p9 = i
  @q9 = i
  return

# With this number of properties the object perfectly wraps around if the
# instance size is not checked when allocating the initial map for MultiProp.
# Meaning that the instance will be smaller than a minimal JSObject and we
# will suffer a bus error in the release build or an assertion in the debug
# build.
ExpectAllFields = (o, val) ->
  for x of o
    assertEquals o[x], val
  return
a = new LargeObject(1)
b = new LargeObject(2)
ExpectAllFields a, 1
ExpectAllFields b, 2
