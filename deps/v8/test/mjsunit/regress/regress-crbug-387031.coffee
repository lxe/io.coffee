# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax
a = [1]
b = []
a.__defineGetter__ 0, ->
  b.length = 0xffffffff
  return

c = a.concat(b)
i = 0

while i < 20
  assertEquals `undefined`, (c[i])
  i++
