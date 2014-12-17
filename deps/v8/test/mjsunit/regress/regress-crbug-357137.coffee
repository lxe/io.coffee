# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
locals = ""
i = 0

while i < 1024
  locals += "var v" + i + ";"
  i++
eval "function f() {" + locals + "f();}"
assertThrows "f()", RangeError
