# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --track-field-types
b1 = d: 1
b2 = d: 2
f1 = x: 1
f2 = x: 2
f1.b = b1
f2.x = {}
b2.d = 4.2
f2.b = b2
x = f1.x
