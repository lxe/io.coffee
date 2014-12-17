# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --harmony-proxies --expose-gc
f = ->
  @x = 23
  return
proxy = Proxy.create(getPropertyDescriptor: (key) ->
  gc()
  return
)
f:: = proxy
new f()
new f()
