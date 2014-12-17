# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-externalize-string --expose-gc
re = /(B)/
cons1 = "0123456789" + "ABCDEFGHIJ"
cons2 = "0123456789ሴ" + "ABCDEFGHIJ"
gc()
gc() # Promote cons.
try
  externalizeString cons1, false
try
  externalizeString cons2, true
slice1 = cons1.slice(1, -1)
slice2 = cons2.slice(1, -1)
i = 0

while i < 10
  assertEquals [
    "B"
    "B"
  ], re.exec(slice1)
  assertEquals [
    "B"
    "B"
  ], re.exec(slice2)
  i++
