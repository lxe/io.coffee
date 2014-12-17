# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Flags: --harmony-proxies
proxy = Proxy.create(fix: ->
  {}
)
Object.preventExtensions proxy
Object.observe proxy, ->

functionProxy = Proxy.createFunction(
  fix: ->
    {}
, ->
)
Object.preventExtensions functionProxy
Object.observe functionProxy, ->

