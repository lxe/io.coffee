# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = /x/
    store b
    b[1]
  store []
  c = /x/
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new Date()
    store b
    b[1]
  store []
  c = new Date()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new Number(1)
    store b
    b[1]
  store []
  c = new Number(1)
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new Boolean()
    store b
    b[1]
  store []
  c = new Boolean()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new Map()
    store b
    b[1]
  store []
  c = new Map()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new Set()
    store b
    b[1]
  store []
  c = new Set()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new WeakMap()
    store b
    b[1]
  store []
  c = new WeakMap()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
(->
  store = (x) ->
    x[0] = 0
    return
  get_hole = ->
    b = new WeakSet()
    store b
    b[1]
  store []
  c = new WeakSet()
  store c
  assertEquals `undefined`, get_hole()
  assertEquals `undefined`, get_hole()
  return
)()
