# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
join = ->
  b.join()
  return
a = "a"
i = 0

while i < 23
  a += a
  i++
b = []
i = 0

while i < (1 << 5)
  b.push a
  i++
assertThrows join, RangeError
