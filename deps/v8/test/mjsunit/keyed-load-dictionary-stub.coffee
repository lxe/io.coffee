# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Flags: --allow-natives-syntax
generate_dictionary_array = ->
  result = [
    0
    1
    2
    3
    4
  ]
  result[256 * 1024] = 5
  result
get_accessor = (a, i) ->
  a[i]
array1 = generate_dictionary_array()
get_accessor array1, 1
get_accessor array1, 2
get_accessor 12345, 2
