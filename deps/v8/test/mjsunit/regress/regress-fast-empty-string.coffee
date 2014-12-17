# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
o = {}
o[""] = 1
x = __proto__: o
i = 0
while i < 3
  o[""]
  i++
i = 0
while i < 3
  assertEquals `undefined`, o.x
  i++
