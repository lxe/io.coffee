# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
__f_17 = (__v_9) ->
  __v_10 = 0
  count = 100000
  until count-- is 0
    l = __v_9.push(0)
    return __v_9  if ++__v_10 >= 2
    __v_10 = {}
  return
__f_17 []
