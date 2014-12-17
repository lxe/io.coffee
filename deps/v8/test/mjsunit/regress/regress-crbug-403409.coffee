# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
Array::[0] = 777
kElements = 10
input_array = []
i = 1

while i < kElements
  input_array[i] = 0.5
  i++
output_array = input_array.concat(0.5)
assertEquals kElements + 1, output_array.length
assertEquals 777, output_array[0]
j = 1

while j < kElements
  assertEquals 0.5, output_array[j]
  j++
