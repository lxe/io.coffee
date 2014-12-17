# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
if "Intl" of this
  overflow = ->
    overflow() + 1
  Object.defineProperty = overflow
  assertDoesNotThrow ->
    Intl.Collator.supportedLocalesOf "en"
    return

  date = new Date(Date.UTC(2004, 12, 25, 3, 0, 0))
  options =
    weekday: "long"
    year: "numeric"
    month: "long"
    day: "numeric"

  Object.apply = overflow
  assertDoesNotThrow ->
    date.toLocaleDateString "de-DE", options
    return

  options_incomplete = {}
  assertDoesNotThrow ->
    date.toLocaleDateString "de-DE", options_incomplete
    return

  assertTrue options_incomplete.hasOwnProperty("year")
  assertDoesNotThrow ->
    date.toLocaleDateString "de-DE", `undefined`
    return

  assertDoesNotThrow ->
    date.toLocaleDateString "de-DE"
    return

  assertThrows (->
    date.toLocaleDateString "de-DE", null
    return
  ), TypeError
