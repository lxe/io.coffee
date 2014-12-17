# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
testError = (error) ->
  
  # Reconfigure e.stack to be non-configurable
  desc1 = Object.getOwnPropertyDescriptor(error, "stack")
  Object.defineProperty error, "stack",
    get: desc1.get
    set: desc1.set
    configurable: false

  desc2 = Object.getOwnPropertyDescriptor(error, "stack")
  assertFalse desc2.configurable
  assertEquals desc1.get, desc2.get
  assertEquals desc2.get, desc2.get
  return
stackOverflow = ->
  f = ->
    f()
    return
  try
    f()
  catch e
    return e
  return
referenceError = ->
  try
    g()
  catch e
    return e
  return
testError referenceError()
testError stackOverflow()
