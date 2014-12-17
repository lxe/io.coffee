# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug

# Test reentry of special try catch for Promises.
Debug = debug.Debug
Debug.setBreakOnUncaughtException()
Debug.setListener (event, exec_state, event_data, data) ->

p = new Promise((resolve, reject) ->
  resolve()
  return
)
q = p.chain(->
  new Promise((resolve, reject) ->
    resolve()
    return
  )
  return
)
