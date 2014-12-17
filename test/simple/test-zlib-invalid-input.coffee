# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

# test uncompressing invalid input
common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
nonStringInputs = [
  1
  true
  {
    a: 1
  }
  ["a"]
]
console.error "Doing the non-strings"
nonStringInputs.forEach (input) ->
  
  # zlib.gunzip should not throw an error when called with bad input.
  assert.doesNotThrow ->
    zlib.gunzip input, (err, buffer) ->
      
      # zlib.gunzip should pass the error to the callback.
      assert.ok err
      return

    return

  return

console.error "Doing the unzips"

# zlib.Unzip classes need to get valid data, or else they'll throw.
unzips = [
  zlib.Unzip()
  zlib.Gunzip()
  zlib.Inflate()
  zlib.InflateRaw()
]
hadError = []
unzips.forEach (uz, i) ->
  console.error "Error for " + uz.constructor.name
  uz.on "error", (er) ->
    console.error "Error event", er
    hadError[i] = true
    return

  uz.on "end", (er) ->
    throw new Error("end event should not be emitted " + uz.constructor.name)return

  
  # this will trigger error event
  uz.write "this is not valid compressed data."
  return

process.on "exit", ->
  assert.deepEqual hadError, [
    true
    true
    true
    true
  ], "expect 4 errors"
  return

