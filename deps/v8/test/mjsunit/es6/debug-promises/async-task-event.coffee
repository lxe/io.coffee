# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-debug-as debug
assertLog = (msg) ->
  print msg
  assertTrue expected.length > 0
  assertEquals expected.shift(), msg
  Debug.setListener null  unless expected.length
  return
listener = (event, exec_state, event_data, data) ->
  return  unless event is Debug.DebugEvent.AsyncTaskEvent
  try
    base_id = event_data.id()  if base_id < 0
    id = event_data.id() - base_id + 1
    assertEquals "Promise.resolve", event_data.name()
    assertLog event_data.type() + " #" + id
  catch e
    print e + e.stack
    exception = e
  return
Debug = debug.Debug
base_id = -1
exception = null
expected = [
  "enqueue #1"
  "willHandle #1"
  "then #1"
  "enqueue #2"
  "didHandle #1"
  "willHandle #2"
  "then #2"
  "enqueue #3"
  "didHandle #2"
  "willHandle #3"
  "didHandle #3"
]
Debug.setListener listener
resolver = undefined
p = new Promise((resolve, reject) ->
  resolver = resolve
  return
)
p.then(->
  assertLog "then #1"
  return
).then ->
  assertLog "then #2"
  return

resolver()
assertNull exception
