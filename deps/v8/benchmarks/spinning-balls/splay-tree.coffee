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

###*
Constructs a Splay tree.  A splay tree is a self-balancing binary
search tree with the additional property that recently accessed
elements are quick to access again. It performs basic operations
such as insertion, look-up and removal in O(log(n)) amortized time.

@constructor
###
SplayTree = ->

###*
Pointer to the root node of the tree.

@type {SplayTree.Node}
@private
###
SplayTree::root_ = null

###*
@return {boolean} Whether the tree is empty.
###
SplayTree::isEmpty = ->
  not @root_


###*
Inserts a node into the tree with the specified key and value if
the tree does not already contain a node with the specified key. If
the value is inserted, it becomes the root of the tree.

@param {number} key Key to insert into the tree.
@param {*} value Value to insert into the tree.
###
SplayTree::insert = (key, value) ->
  if @isEmpty()
    @root_ = new SplayTree.Node(key, value)
    return
  
  # Splay on the key to move the last node on the search path for
  # the key to the root of the tree.
  @splay_ key
  return  if @root_.key is key
  node = new SplayTree.Node(key, value)
  if key > @root_.key
    node.left = @root_
    node.right = @root_.right
    @root_.right = null
  else
    node.right = @root_
    node.left = @root_.left
    @root_.left = null
  @root_ = node
  return


###*
Removes a node with the specified key from the tree if the tree
contains a node with this key. The removed node is returned. If the
key is not found, an exception is thrown.

@param {number} key Key to find and remove from the tree.
@return {SplayTree.Node} The removed node.
###
SplayTree::remove = (key) ->
  throw Error("Key not found: " + key)  if @isEmpty()
  @splay_ key
  throw Error("Key not found: " + key)  unless @root_.key is key
  removed = @root_
  unless @root_.left
    @root_ = @root_.right
  else
    right = @root_.right
    @root_ = @root_.left
    
    # Splay to make sure that the new root has an empty right child.
    @splay_ key
    
    # Insert the original right child as the right child of the new
    # root.
    @root_.right = right
  removed


###*
Returns the node having the specified key or null if the tree doesn't contain
a node with the specified key.

@param {number} key Key to find in the tree.
@return {SplayTree.Node} Node having the specified key.
###
SplayTree::find = (key) ->
  return null  if @isEmpty()
  @splay_ key
  (if @root_.key is key then @root_ else null)


###*
@return {SplayTree.Node} Node having the maximum key value.
###
SplayTree::findMax = (opt_startNode) ->
  return null  if @isEmpty()
  current = opt_startNode or @root_
  current = current.right  while current.right
  current


###*
@return {SplayTree.Node} Node having the maximum key value that
is less than the specified key value.
###
SplayTree::findGreatestLessThan = (key) ->
  return null  if @isEmpty()
  
  # Splay on the key to move the node with the given key or the last
  # node on the search path to the top of the tree.
  @splay_ key
  
  # Now the result is either the root node or the greatest node in
  # the left subtree.
  if @root_.key < key
    @root_
  else if @root_.left
    @findMax @root_.left
  else
    null


###*
@return {Array<*>} An array containing all the keys of tree's nodes.
###
SplayTree::exportKeys = ->
  result = []
  unless @isEmpty()
    @root_.traverse_ (node) ->
      result.push node.key
      return

  result


###*
Perform the splay operation for the given key. Moves the node with
the given key to the top of the tree.  If no node has the given
key, the last node on the search path is moved to the top of the
tree. This is the simplified top-down splaying algorithm from:
"Self-adjusting Binary Search Trees" by Sleator and Tarjan

@param {number} key Key to splay the tree on.
@private
###
SplayTree::splay_ = (key) ->
  return  if @isEmpty()
  
  # Create a dummy node.  The use of the dummy node is a bit
  # counter-intuitive: The right child of the dummy node will hold
  # the L tree of the algorithm.  The left child of the dummy node
  # will hold the R tree of the algorithm.  Using a dummy node, left
  # and right will always be nodes and we avoid special cases.
  dummy = undefined
  left = undefined
  right = undefined
  dummy = left = right = new SplayTree.Node(null, null)
  current = @root_
  loop
    if key < current.key
      break  unless current.left
      if key < current.left.key
        
        # Rotate right.
        tmp = current.left
        current.left = tmp.right
        tmp.right = current
        current = tmp
        break  unless current.left
      
      # Link right.
      right.left = current
      right = current
      current = current.left
    else if key > current.key
      break  unless current.right
      if key > current.right.key
        
        # Rotate left.
        tmp = current.right
        current.right = tmp.left
        tmp.left = current
        current = tmp
        break  unless current.right
      
      # Link left.
      left.right = current
      left = current
      current = current.right
    else
      break
  
  # Assemble.
  left.right = current.left
  right.left = current.right
  current.left = dummy.right
  current.right = dummy.left
  @root_ = current
  return


###*
Constructs a Splay tree node.

@param {number} key Key.
@param {*} value Value.
###
SplayTree.Node = (key, value) ->
  @key = key
  @value = value
  return


###*
@type {SplayTree.Node}
###
SplayTree.Node::left = null

###*
@type {SplayTree.Node}
###
SplayTree.Node::right = null

###*
Performs an ordered traversal of the subtree starting at
this SplayTree.Node.

@param {function(SplayTree.Node)} f Visitor function.
@private
###
SplayTree.Node::traverse_ = (f) ->
  current = this
  while current
    left = current.left
    left.traverse_ f  if left
    f current
    current = current.right
  return

SplayTree::traverseBreadthFirst = (f) ->
  return  if f(@root_.value)
  stack = [@root_]
  length = 1
  while length > 0
    new_stack = new Array(stack.length * 2)
    new_length = 0
    i = 0

    while i < length
      n = stack[i]
      l = n.left
      r = n.right
      if l
        return  if f(l.value)
        new_stack[new_length++] = l
      if r
        return  if f(r.value)
        new_stack[new_length++] = r
      i++
    stack = new_stack
    length = new_length
  return
