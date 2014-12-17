# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --expose-natives-as=builtins
# Should not crash or raise an exception.
s = new Set()
setIterator = new builtins.SetIterator(s, 2)
m = new Map()
mapIterator = new builtins.MapIterator(m, 2)
