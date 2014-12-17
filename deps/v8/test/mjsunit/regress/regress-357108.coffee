# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Flags: --typed-array-max-size-in-heap=64
TestArray = (constructor) ->
  Check = (a) ->
    a[0] = ""
    assertEquals 0, a[0]
    a[0] = {}
    assertEquals 0, a[0]
    a[0] = valueOf: ->
      27

    assertEquals 27, a[0]
    return
  Check new constructor(1)
  Check new constructor(100)
  return
TestArray Uint8Array
