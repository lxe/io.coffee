# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
SetupSmiKeys = ->
  keys = new Array(N * 2)
  i = 0

  while i < N * 2
    keys[i] = i
    i++
  return
SetupStringKeys = ->
  keys = new Array(N * 2)
  i = 0

  while i < N * 2
    keys[i] = "s" + i
    i++
  return
SetupObjectKeys = ->
  keys = new Array(N * 2)
  i = 0

  while i < N * 2
    keys[i] = {}
    i++
  return
N = 10
keys = undefined
