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

# UTF-8

# A mixed ascii and non-ascii string
# Test stolen from deps/v8/test/cctest/test-strings.cc
# U+02E4 -> CB A4
# U+0064 -> 64
# U+12E4 -> E1 8B A4
# U+0030 -> 30
# U+3045 -> E3 81 85

# CESU-8
# thumbs up

# UCS-2

# UTF-16LE
# thumbs up

# test verifies that StringDecoder will correctly decode the given input
# buffer with the given encoding to the expected output. It will attempt all
# possible ways to write() the input buffer, see writeSequences(). The
# singleSequence allows for easy debugging of a specific sequence which is
# useful in case of test failures.
test = (encoding, input, expected, singleSequence) ->
  sequences = undefined
  unless singleSequence
    sequences = writeSequences(input.length)
  else
    sequences = [singleSequence]
  sequences.forEach (sequence) ->
    decoder = new StringDecoder(encoding)
    output = ""
    sequence.forEach (write) ->
      output += decoder.write(input.slice(write[0], write[1]))
      return

    process.stdout.write "."
    if output isnt expected
      message = "Expected \"" + unicodeEscape(expected) + "\", " + "but got \"" + unicodeEscape(output) + "\"\n" + "Write sequence: " + JSON.stringify(sequence) + "\n" + "Decoder charBuffer: 0x" + decoder.charBuffer.toString("hex") + "\n" + "Full Decoder State: " + JSON.stringify(decoder, null, 2)
      assert.fail output, expected, message
    return

  return

# unicodeEscape prints the str contents as unicode escape codes.
unicodeEscape = (str) ->
  r = ""
  i = 0

  while i < str.length
    r += "\\u" + str.charCodeAt(i).toString(16)
    i++
  r

# writeSequences returns an array of arrays that describes all possible ways a
# buffer of the given length could be split up and passed to sequential write
# calls.
#
# e.G. writeSequences(3) will return: [
#   [ [ 0, 3 ] ],
#   [ [ 0, 2 ], [ 2, 3 ] ],
#   [ [ 0, 1 ], [ 1, 3 ] ],
#   [ [ 0, 1 ], [ 1, 2 ], [ 2, 3 ] ]
# ]
writeSequences = (length, start, sequence) ->
  if start is `undefined`
    start = 0
    sequence = []
  else return [sequence]  if start is length
  sequences = []
  end = length

  while end > start
    subSequence = sequence.concat([[
      start
      end
    ]])
    subSequences = writeSequences(length, end, subSequence, sequences)
    sequences = sequences.concat(subSequences)
    end--
  sequences
common = require("../common")
assert = require("assert")
StringDecoder = require("string_decoder").StringDecoder
process.stdout.write "scanning "
test "utf-8", new Buffer("$", "utf-8"), "$"
test "utf-8", new Buffer("¢", "utf-8"), "¢"
test "utf-8", new Buffer("€", "utf-8"), "€"
test "utf-8", new Buffer("𤭢", "utf-8"), "𤭢"
test "utf-8", new Buffer([
  0xcb
  0xa4
  0x64
  0xe1
  0x8b
  0xa4
  0x30
  0xe3
  0x81
  0x85
]), "ˤdዤ0ぅ"
test "utf-8", new Buffer("EDA0BDEDB18D", "hex"), "👍"
test "ucs2", new Buffer("ababc", "ucs2"), "ababc"
test "ucs2", new Buffer("3DD84DDC", "hex"), "👍"
console.log " crayon!"
