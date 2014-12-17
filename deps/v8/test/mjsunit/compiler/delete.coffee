# Copyright 2011 the V8 project authors. All rights reserved.
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

# Tests of unary delete in cases where it is always true or always false.

# In an effect context, expression is always true.
assertEquals `undefined`, undefined

# In an effect context, expression is always false.
assertEquals `undefined`, ((x) ->
  delete x

  return
)(0)

# In a pure test context, expression is always true.
assertEquals 1, (if (delete 0
) then 1 else 2)

# In a pure test context, expression is always false.
assertEquals 2, ((x) ->
  (if (delete x
  ) then 1 else 2)
)(0)

# In a negated test context, expression is always false.
assertEquals 1, ((x) ->
  (if not (delete x
  ) then 1 else 2)
)(0)

# In a hybrid test/value context, expression is always true, value
# expected in accumulator.
assertEquals 3, 1 + ((delete 0
) and 2)

# In a hybrid test/value context, expression is always false, value
# expected in accumulator.
assertEquals false, ((x) ->
  (delete x
  ) and 2
)(0)

# In a hybrid test/value context, expression is always true, value
# expected on stack.
assertEquals 3, ((delete 0
) and 2) + 1

# In a hybrid test/value context, expression is always false, value
# expected on stack.
assertEquals 1, ((x) ->
  ((delete x
  ) and 2) + 1
)(0)

# In a hybrid value/test context, expression is always true, value
# expected in accumulator.
assertEquals 2, 1 + ((delete 0
) or 2)

# In a hybrid value/test context, expression is always false, value
# expected in accumulator.
assertEquals 2, ((x) ->
  (delete x
  ) or 2
)(0)

# In a hybrid value/test context, expression is always true, value
# expected on stack.
assertEquals 2, ((delete 0
) or 2) + 1

# In a hybrid value/test context, expression is always false, value
# expected on stack.
assertEquals 3, ((x) ->
  ((delete x
  ) or 2) + 1
)(0)

# 'this' is not a Reference so delete returns true (see section 11.4.1,
# step 2 of ES 5.1).
assertEquals true, delete this

assertEquals true, (->
  delete this
)()
