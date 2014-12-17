# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --stack_size=150
f = (a) ->
  f a + 1
  return
Error.__defineGetter__ "stackTraceLimit", ->

try
  f 0
