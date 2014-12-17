# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
array = []
v = 0
Object.defineProperty Array::, "0",
  get: ->
    "get " + v

  set: (value) ->
    v += value
    return

array[0] = 10
assertEquals 0, array.length
assertEquals 10, v
assertEquals "get 10", array[0]
array.push 100
assertEquals 1, array.length
assertEquals 110, v
assertEquals "get 110", array[0]
