# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
args = (arg) ->
  arguments
a = args(false)
(->
  "use strict"
  a["const" + 0] = 0
  return
)()
(->
  "use strict"
  a[0] = 0
  return
)()
