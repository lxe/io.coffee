# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
(f = ->
  try
    throw 1
  catch e
    a = 0
    b = 0
    c = 0
    x = 1
    result = eval("eval(\"x\")").toString()
    assertEquals "1", result
  x = 2
  result = eval("eval(\"x\")").toString()
  assertEquals "2", result
  return
)()
