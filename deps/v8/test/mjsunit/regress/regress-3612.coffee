# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
a = [1]
getterValue = 2
endIndex = 0xffff
Object.defineProperty a, endIndex,
  get: ->
    this[1] = 3
    getterValue

  set: (val) ->
    getterValue = val
    return

  configurable: true
  enumerable: true

a.reverse()
assertFalse a.hasOwnProperty(1)
assertEquals 3, a[endIndex - 1]
