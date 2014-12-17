# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
f = (a, b) ->
  i = 10000

  while i > 0
    arguments[i] = 0
    i--
  return
f 1.5, 2.5
