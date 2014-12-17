# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax --enable-slow-asserts
f = ->
  x = new Array(0)
  x[-1] = -1
  Object.observe x, ->

  return
f()
f()
