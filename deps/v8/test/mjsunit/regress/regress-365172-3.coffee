# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-gc --track-field-types
f1 = (a) ->
  x: a
  v: ""
f2 = (a) ->
  x:
    v: a

  v: ""
f3 = (a) ->
  x: []
  v:
    v: ""
f3 [0]
a = f1(1)
a.__defineGetter__ "v", ->
  gc()
  f2 this

a.v
f3 1
