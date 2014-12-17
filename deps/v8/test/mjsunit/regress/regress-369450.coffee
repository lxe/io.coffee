# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax --enable-slow-asserts
v = [1.3]
v.length = 0
json = JSON.stringify(v)
assertEquals "[]", json
Array::[0] = 5.5
arr = [].concat(v, [{}], [2.3])
assertEquals [
  {
    {}
  }
  2.3
], arr
