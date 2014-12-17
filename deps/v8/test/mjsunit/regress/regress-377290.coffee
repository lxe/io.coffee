# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-gc
Object::__defineGetter__ "constructor", ->
  throw 42return

__v_7 = [->
  [].push()
  return
]
__v_6 = 0

while __v_6 < 5
  for __v_8 of __v_7
    print __v_8, " -> ", __v_7[__v_8]
    gc()
    try
      __v_7[__v_8]()
  ++__v_6
