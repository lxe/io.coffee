# Copyright 2013 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
A = ->
  Object.defineProperty this, "x",
    set: ->

    get: ->

  @a = ->
    1

  return
B = ->
  A.apply this
  @a = ->
    2

  return
b = new B()
assertTrue Object.getOwnPropertyDescriptor(b, "a").enumerable
