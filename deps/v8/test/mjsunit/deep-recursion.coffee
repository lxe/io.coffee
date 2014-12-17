# Copyright 2008 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

###*
@fileoverview Check that flattening deep trees of cons strings does not
cause stack overflows.
###
newdeep = (start, depth) ->
  d = start
  i = 0

  while i < depth
    d = d + "f"
    i++
  d
default_depth = 110000
deep = newdeep("foo", default_depth)
assertEquals "f", deep[0]
cmp1 = newdeep("a", default_depth)
cmp2 = newdeep("b", default_depth)
assertEquals -1, cmp1.localeCompare(cmp2), "ab"
cmp2empty = newdeep("c", default_depth)
assertTrue cmp2empty.localeCompare("") > 0, "c"
cmp3empty = newdeep("d", default_depth)
assertTrue("".localeCompare(cmp3empty) < 0)
"d"

slicer_depth = 1100
slicer = newdeep("slice", slicer_depth)
i = 0
while i < slicer_depth + 4
  slicer = slicer.slice(1, -1)
  i += 2
assertEquals "f", slicer[0]
assertEquals 1, slicer.length
