# Copyright (c) 2014, StrongLoop Inc.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Flags: --expose_gc
ongc = (before_, after_) ->
  
  # Try very hard to not create garbage because that could kick off another
  # garbage collection cycle.
  before = before_
  after = after_
  ncalls += 1
  return
common = require("../common")
assert = require("assert")
v8 = require("v8")
assert typeof gc is "function", "Run this test with --expose_gc."
ncalls = 0
before = undefined
after = undefined
gc()
v8.on "gc", ongc
gc()
v8.removeListener "gc", ongc
gc()
assert.equal ncalls, 1
assert.equal typeof before, "object"
assert.equal typeof after, "object"
assert.equal typeof before.timestamp, "number"
assert.equal typeof after.timestamp, "number"
assert.equal before.timestamp <= after.timestamp, true
