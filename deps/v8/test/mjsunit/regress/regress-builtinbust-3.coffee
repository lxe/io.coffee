# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
produce_object = ->
  set_length = ->
    real_length = "boom"
    return
  get_length = ->
    real_length
  real_length = 1
  o =
    __proto__: Array::
    0: "x"

  Object.defineProperty o, "length",
    set: set_length
    get: get_length

  o
assertEquals 2, produce_object().push("y")
assertEquals 2, produce_object().unshift("y")
