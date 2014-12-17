# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax
funky = (array) ->
  array[0] = 1
crash = ->
  q = [0]
  
  # The failing ASSERT was only triggered when compiling for OSR.
  i = 0

  while i < 100000
    funky q
    i++
  q[0] = 0
  funky q
  return
a = ["string"]
funky a
crash()
