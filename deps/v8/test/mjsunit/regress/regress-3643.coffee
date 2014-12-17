# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
newArrayWithGetter = ->
  arr = [
    1
    2
    3
  ]
  Object.defineProperty arr, "1",
    get: ->
      delete this[1]

      `undefined`

    configurable: true

  arr
a = newArrayWithGetter()
s = a.slice(1)
assertTrue "0" of s

# Sparse case should hit the same code as above due to presence of the getter.
a = newArrayWithGetter()
a[0xffff] = 4
s = a.slice(1)
assertTrue "0" of s
a = newArrayWithGetter()
a.shift()
assertTrue "0" of a
a = newArrayWithGetter()
a.unshift 0
assertTrue "2" of a
