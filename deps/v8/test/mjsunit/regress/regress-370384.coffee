# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --deopt-every-n-times=1 --no-enable_sse4_1
g = (f, x, name) ->
  v2 = f(x)
  i = 0

  while i < 13000
    f i
    i++
  v1 = f(x)
  assertEquals v1, v2
  return
g Math.sin, 6.283185307179586, "Math.sin"
