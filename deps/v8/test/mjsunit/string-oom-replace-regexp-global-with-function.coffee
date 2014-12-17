# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
replace = ->
  a.replace /a/g, ->
    b

  return
a = "a"
i = 0

while i < 5
  a += a
  i++
b = "b"
i = 0

while i < 23
  b += b
  i++
assertThrows replace, RangeError
