# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
concat = ->
  a = " "
  i = 0

  while i < 100
    a += a
    i++
  a
assertThrows concat, RangeError
