# Copyright 2009 the V8 project authors. All rights reserved.
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
ReturnArguments = ->
  arguments
ReturnReceiver = ->
  this
Global = ->
  ReturnArguments.apply this, arguments
Local = ->
  object = f: ReturnArguments
  object.f.apply this, arguments
ShadowArguments = ->
  arguments = [
    3
    4
  ]
  ReturnArguments.apply this, arguments
NonObjectReceiver = (receiver) ->
  ReturnReceiver.apply receiver, arguments
FunctionReceiver = ->
  ReturnReceiver.apply Object, arguments
ShadowApply = ->
  f = ->
    42
  f.apply = ->
    87

  f.apply this, arguments
CallNonFunction = ->
  object = apply: Function::apply
  object.apply this, arguments

# Make sure that the stack after the apply optimization is
# in a valid state.
SimpleStackCheck = ->
  sentinel = 42
  result = ReturnArguments.apply(this, arguments)
  assertTrue result?
  assertEquals 42, sentinel
  return
ShadowArgumentsWithConstant = ->
  arguments = null
  ReturnArguments.apply this, arguments
assertEquals 0, Global().length
assertEquals 1, Global(1).length
assertEquals 2, Global(2)[0]
assertEquals 2, Global(3, 4).length
assertEquals 3, Global(3, 4)[0]
assertEquals 4, Global(3, 4)[1]
assertEquals 0, Local().length
assertEquals 1, Local(1).length
assertEquals 2, Local(2)[0]
assertEquals 2, Local(3, 4).length
assertEquals 3, Local(3, 4)[0]
assertEquals 4, Local(3, 4)[1]
assertEquals 2, ShadowArguments().length
assertEquals 3, ShadowArguments()[0]
assertEquals 4, ShadowArguments()[1]
assertEquals Object(42), NonObjectReceiver(42)
assertEquals "object", typeof NonObjectReceiver(42)
assertInstanceof NonObjectReceiver(42), Number
assertSame this, NonObjectReceiver(null)
assertSame this, NonObjectReceiver(undefined)
assertTrue Object is FunctionReceiver()
assertEquals 87, ShadowApply()
assertEquals 87, ShadowApply(1)
assertEquals 87, ShadowApply(1, 2)
assertThrows CallNonFunction, TypeError
SimpleStackCheck()
assertEquals 0, ShadowArgumentsWithConstant().length
assertEquals 0, ShadowArgumentsWithConstant(1).length
assertEquals 0, ShadowArgumentsWithConstant(1, 2).length

# Make sure we can deal with unfolding lots of arguments on the
# stack even in the presence of the apply optimizations.
array = new Array(2048)
assertEquals 2048, Global.apply(this, array).length
