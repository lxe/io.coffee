# Copyright 2013 the V8 project authors. All rights reserved.
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

# Segment plain Chinese sentence and check results.
iterator = new Intl.v8BreakIterator(["zh"])
textToSegment = "国务院关于《土地" + "房屋管理条例》"
iterator.adoptText textToSegment
slices = []
types = []
pos = iterator.first()
while pos isnt -1
  nextPos = iterator.next()
  break  if nextPos is -1
  slices.push textToSegment.slice(pos, nextPos)
  types.push iterator.breakType()
  pos = nextPos
assertEquals "国务院", slices[0]
assertEquals "关于", slices[1]
assertEquals "《", slices[2]
assertEquals "土地", slices[3]
assertEquals "房屋", slices[4]
assertEquals "管理", slices[5]
assertEquals "条例", slices[6]
assertEquals "》", slices[7]
assertEquals "ideo", types[0]
assertEquals "ideo", types[1]
assertEquals "none", types[2]
assertEquals "ideo", types[3]
assertEquals "ideo", types[4]
assertEquals "none", types[types.length - 1]
