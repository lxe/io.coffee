# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
getter = ->
  loop
    return a + 1
    break unless false
  return
a = {}
a.__proto__ = Error("")
a.__defineGetter__ "message", getter
a.message
