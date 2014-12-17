# Copyright 2010 the V8 project authors. All rights reserved.
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

# Flags: --always-opt --nocompilation-cache

# Given a binary operation string and an ordered array of leaf
# strings, return an array of all binary tree strings with the leaves
# (in order) as the fringe.
makeTrees = (op, leaves) ->
  len = leaves.length
  if len is 1
    
    # One leaf is a leaf.
    leaves
  else
    
    # More than one leaf requires an interior node.
    result = []
    
    # Split the leaves into left and right subtrees in all possible
    # ways.  For each split recursively compute all possible subtrees.
    i = 1

    while i < len
      leftTrees = makeTrees(op, leaves.slice(0, i))
      rightTrees = makeTrees(op, leaves.slice(i, len))
      
      # Adjoin every possible left and right subtree.
      j = 0

      while j < leftTrees.length
        k = 0

        while k < rightTrees.length
          string = "(" + leftTrees[j] + op + rightTrees[k] + ")"
          result.push string
          ++k
        ++j
      ++i
    result

# All possible bitwise OR trees with six leaves, i.e. CatalanNumber[5] = 42,
# see http://mathworld.wolfram.com/CatalanNumber.html.
identifiers = [
  "a"
  "b"
  "c"
  "d"
  "e"
  "f"
]
or_trees = makeTrees("|", identifiers)
and_trees = makeTrees("&", identifiers)

# Set up leaf masks to set 6 least-significant bits.
a = 1 << 0
b = 1 << 1
c = 1 << 2
d = 1 << 3
e = 1 << 4
f = 1 << 5
i = 0

while i < or_trees.length
  j = 0

  while j < 6
    or_fun = new Function("return " + or_trees[i])
    assertEquals 63, or_fun()  if j is 0
    
    # Set the j'th variable to a string to force a bailout.
    eval identifiers[j] + "+= ''"
    assertEquals 63, or_fun()
    
    # Set it back to a number for the next iteration.
    eval identifiers[j] + "= +" + identifiers[j]
    ++j
  ++i

# Set up leaf masks to clear 6 least-significant bits.
a ^= 63
b ^= 63
c ^= 63
d ^= 63
e ^= 63
f ^= 63
i = 0
while i < and_trees.length
  j = 0

  while j < 6
    and_fun = new Function("return " + and_trees[i])
    assertEquals 0, and_fun()  if j is 0
    
    # Set the j'th variable to a string to force a bailout.
    eval identifiers[j] + "+= ''"
    assertEquals 0, and_fun()
    
    # Set it back to a number for the next iteration.
    eval identifiers[j] + "= +" + identifiers[j]
    ++j
  ++i
