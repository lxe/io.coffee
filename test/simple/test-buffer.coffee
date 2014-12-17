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

# counter to ensure unique value is always copied
# safe constructor

# First check Buffer#fill() works as expected.

# Make sure this doesn't hang indefinitely.

# copy 512 bytes, from 0 to 512.

# copy c into b, without specifying sourceEnd

# copy c into b, without specifying sourceStart

# copy longer buffer b to shorter c without targetStart

# copy starting near end of b to c

# try to copy 513 bytes, and check we don't overrun c

# copy 768 bytes from b into b

# copy string longer than buffer length (failure will segfault)

# try to copy from before the beginning of b

# copy throws at negative sourceStart

# check sourceEnd resets to targetEnd if former is greater than the latter

# throw with negative sourceEnd

# when sourceStart is greater than sourceEnd, zero copied

# when targetStart > targetLength, zero copied

# invalid encoding for Buffer.toString

# invalid encoding for Buffer.write

# try to create 0-length buffers

# try to write a 0-length string beyond the end of b

# throw when writing to negative offset

# throw when writing past bounds from the pool

# throw when writing to negative offset

# try to copy 0 bytes worth of data into an empty buffer

# try to copy 0 bytes past the end of the target buffer

# try to copy 0 bytes from past the end of the source buffer

# try to toString() a 0-length slice of a buffer, both within and without the
# valid buffer range

# try toString() with a object as a encoding

# testing for smart defaults and ability to pass string values as offset

# TODO utf8 slice tests

# make sure only top level parent propagates from allocPool

# also from a non-pooled instance

# Bug regression test
# ö日本語

# Test triple  slice
# THUMBS UP SIGN (U+1F44D)

#
# Test toString('base64')
#

# test that regular and URL-safe base64 both work

# big example

# check that the base64 decoder ignores whitespace

# check that the base64 decoder on the constructor works
# even in the presence of whitespace.

# check that the base64 decoder ignores illegal chars

# multiple-of-4 with padding

# no padding, not a multiple of 4

# handle padding graciously, multiple-of-4 or not

# This string encodes single '.' character in UTF-16

# Writing base64 at a position > 0 should not mangle the result.
#
# https://github.com/joyent/node/issues/402

# Creating buffers larger than pool size.

# Single argument slice

# byte length

# slice(0,0).length === 0

# test hex toString

# test an invalid slice end.
buildBuffer = (data) ->
  if Array.isArray(data)
    buffer = new Buffer(data.length)
    data.forEach (v, k) ->
      buffer[k] = v
      return

    return buffer
  null
common = require("../common")
assert = require("assert")
Buffer = require("buffer").Buffer
SlowBuffer = require("buffer").SlowBuffer
smalloc = require("smalloc")
cntr = 0
b = Buffer(1024)
console.log "b.length == %d", b.length
assert.strictEqual 1024, b.length
b[0] = -1
assert.strictEqual b[0], 255
i = 0

while i < 1024
  b[i] = i % 256
  i++
i = 0

while i < 1024
  assert.strictEqual i % 256, b[i]
  i++
c = new Buffer(512)
console.log "c.length == %d", c.length
assert.strictEqual 512, c.length
assert.throws ->
  Buffer(8).fill "a", -1
  return

assert.throws ->
  Buffer(8).fill "a", 0, 9
  return

Buffer(8).fill ""
buf = new Buffer(64)
buf.fill 10
i = 0

while i < buf.length
  assert.equal buf[i], 10
  i++
buf.fill 11, 0, buf.length >> 1
i = 0

while i < buf.length >> 1
  assert.equal buf[i], 11
  i++
i = (buf.length >> 1) + 1

while i < buf.length
  assert.equal buf[i], 10
  i++
buf.fill "h"
i = 0

while i < buf.length
  assert.equal "h".charCodeAt(0), buf[i]
  i++
buf.fill 0
i = 0

while i < buf.length
  assert.equal 0, buf[i]
  i++
buf.fill null
i = 0

while i < buf.length
  assert.equal 0, buf[i]
  i++
buf.fill 1, 16, 32
i = 0

while i < 16
  assert.equal 0, buf[i]
  i++
while i < 32
  assert.equal 1, buf[i]
  i++
while i < buf.length
  assert.equal 0, buf[i]
  i++
buf = new Buffer(10)
buf.fill "abc"
assert.equal buf.toString(), "abcabcabca"
buf.fill "է"
assert.equal buf.toString(), "էէէէէ"
b.fill ++cntr
c.fill ++cntr
copied = b.copy(c, 0, 0, 512)
console.log "copied %d bytes from b into c", copied
assert.strictEqual 512, copied
i = 0

while i < c.length
  assert.strictEqual b[i], c[i]
  i++
b.fill ++cntr
c.fill ++cntr
copied = c.copy(b, 0, 0)
console.log "copied %d bytes from c into b w/o sourceEnd", copied
assert.strictEqual c.length, copied
i = 0

while i < c.length
  assert.strictEqual c[i], b[i]
  i++
b.fill ++cntr
c.fill ++cntr
copied = c.copy(b, 0)
console.log "copied %d bytes from c into b w/o sourceStart", copied
assert.strictEqual c.length, copied
i = 0

while i < c.length
  assert.strictEqual c[i], b[i]
  i++
b.fill ++cntr
c.fill ++cntr
copied = b.copy(c)
console.log "copied %d bytes from b into c w/o targetStart", copied
assert.strictEqual c.length, copied
i = 0

while i < c.length
  assert.strictEqual b[i], c[i]
  i++
b.fill ++cntr
c.fill ++cntr
copied = b.copy(c, 0, b.length - Math.floor(c.length / 2))
console.log "copied %d bytes from end of b into beginning of c", copied
assert.strictEqual Math.floor(c.length / 2), copied
i = 0

while i < Math.floor(c.length / 2)
  assert.strictEqual b[b.length - Math.floor(c.length / 2) + i], c[i]
  i++
i = Math.floor(c.length / 2) + 1

while i < c.length
  assert.strictEqual c[c.length - 1], c[i]
  i++
b.fill ++cntr
c.fill ++cntr
copied = b.copy(c, 0, 0, 513)
console.log "copied %d bytes from b trying to overrun c", copied
assert.strictEqual c.length, copied
i = 0

while i < c.length
  assert.strictEqual b[i], c[i]
  i++
b.fill ++cntr
b.fill ++cntr, 256
copied = b.copy(b, 0, 256, 1024)
console.log "copied %d bytes from b into b", copied
assert.strictEqual 768, copied
i = 0

while i < b.length
  assert.strictEqual cntr, b[i]
  i++
bb = new Buffer(10)
bb.fill "hello crazy world"
caught_error = null
caught_error = null
try
  copied = b.copy(c, 0, 100, 10)
catch err
  caught_error = err
assert.throws (->
  Buffer(5).copy Buffer(5), 0, -1
  return
), RangeError
b.fill ++cntr
c.fill ++cntr
copied = b.copy(c, 0, 0, 1025)
console.log "copied %d bytes from b into c", copied
i = 0

while i < c.length
  assert.strictEqual b[i], c[i]
  i++
console.log "test copy at negative sourceEnd"
assert.throws (->
  b.copy c, 0, 0, -1
  return
), RangeError
assert.equal b.copy(c, 0, 100, 10), 0
assert.equal b.copy(c, 512, 0, 10), 0
caught_error = undefined
caught_error = null
try
  copied = b.toString("invalid")
catch err
  caught_error = err
assert.strictEqual "Unknown encoding: invalid", caught_error.message
caught_error = null
try
  copied = b.write("test string", 0, 5, "invalid")
catch err
  caught_error = err
assert.strictEqual "Unknown encoding: invalid", caught_error.message
new Buffer("")
new Buffer("", "ascii")
new Buffer("", "binary")
new Buffer(0)
assert.throws (->
  b.write "", 2048
  return
), RangeError
assert.throws (->
  b.write "a", -1
  return
), RangeError
assert.throws (->
  b.write "a", 2048
  return
), RangeError
assert.throws (->
  b.write "a", -1
  return
), RangeError
b.copy new Buffer(0), 0, 0, 0
b.copy new Buffer(0), 1, 1, 1
b.copy new Buffer(1), 1, 1, 1
b.copy new Buffer(1), 0, 2048, 2048
assert.equal new Buffer("abc").toString("ascii", 0, 0), ""
assert.equal new Buffer("abc").toString("ascii", -100, -100), ""
assert.equal new Buffer("abc").toString("ascii", 100, 100), ""
assert.equal new Buffer("abc").toString(toString: ->
  "ascii"
), "abc"
writeTest = new Buffer("abcdes")
writeTest.write "n", "ascii"
writeTest.write "o", "ascii", "1"
writeTest.write "d", "2", "ascii"
writeTest.write "e", 3, "ascii"
writeTest.write "j", "ascii", 4
assert.equal writeTest.toString(), "nodejs"
asciiString = "hello world"
offset = 100
j = 0

while j < 500
  i = 0

  while i < asciiString.length
    b[i] = asciiString.charCodeAt(i)
    i++
  asciiSlice = b.toString("ascii", 0, asciiString.length)
  assert.equal asciiString, asciiSlice
  written = b.write(asciiString, offset, "ascii")
  assert.equal asciiString.length, written
  asciiSlice = b.toString("ascii", offset, offset + asciiString.length)
  assert.equal asciiString, asciiSlice
  sliceA = b.slice(offset, offset + asciiString.length)
  sliceB = b.slice(offset, offset + asciiString.length)
  i = 0

  while i < asciiString.length
    assert.equal sliceA[i], sliceB[i]
    i++
  j++
j = 0

while j < 100
  slice = b.slice(100, 150)
  assert.equal 50, slice.length
  i = 0

  while i < 50
    assert.equal b[100 + i], slice[i]
    i++
  j++
b = new Buffer(5)
c = b.slice(0, 4)
d = c.slice(0, 2)
assert.equal b.parent, c.parent
assert.equal b.parent, d.parent
b = new SlowBuffer(5)
c = b.slice(0, 4)
d = c.slice(0, 2)
assert.equal b, c.parent
assert.equal b, d.parent
testValue = "ö日本語"
buffer = new Buffer(32)
size = buffer.write(testValue, 0, "utf8")
console.log "bytes written to buffer: " + size
slice = buffer.toString("utf8", 0, size)
assert.equal slice, testValue
a = new Buffer(8)
i = 0

while i < 8
  a[i] = i
  i++
b = a.slice(4, 8)
assert.equal 4, b[0]
assert.equal 5, b[1]
assert.equal 6, b[2]
assert.equal 7, b[3]
c = b.slice(2, 4)
assert.equal 6, c[0]
assert.equal 7, c[1]
d = new Buffer([
  23
  42
  255
])
assert.equal d.length, 3
assert.equal d[0], 23
assert.equal d[1], 42
assert.equal d[2], 255
assert.deepEqual d, new Buffer(d)
e = new Buffer("über")
console.error "uber: '%s'", e.toString()
assert.deepEqual e, new Buffer([
  195
  188
  98
  101
  114
])
f = new Buffer("über", "ascii")
console.error "f.length: %d     (should be 4)", f.length
assert.deepEqual f, new Buffer([
  252
  98
  101
  114
])
[
  "ucs2"
  "ucs-2"
  "utf16le"
  "utf-16le"
].forEach (encoding) ->
  f = new Buffer("über", encoding)
  console.error "f.length: %d     (should be 8)", f.length
  assert.deepEqual f, new Buffer([
    252
    0
    98
    0
    101
    0
    114
    0
  ])
  f = new Buffer("привет", encoding)
  console.error "f.length: %d     (should be 12)", f.length
  assert.deepEqual f, new Buffer([
    63
    4
    64
    4
    56
    4
    50
    4
    53
    4
    66
    4
  ])
  assert.equal f.toString(encoding), "привет"
  f = new Buffer([
    0
    0
    0
    0
    0
  ])
  assert.equal f.length, 5
  size = f.write("あいうえお", encoding)
  console.error "bytes written to buffer: %d     (should be 4)", size
  assert.equal size, 4
  assert.deepEqual f, new Buffer([
    0x42
    0x30
    0x44
    0x30
    0x00
  ])
  return

f = new Buffer("👍", "utf-16le")
assert.equal f.length, 4
assert.deepEqual f, new Buffer("3DD84DDC", "hex")
arrayIsh =
  0: 0
  1: 1
  2: 2
  3: 3
  length: 4

g = new Buffer(arrayIsh)
assert.deepEqual g, new Buffer([
  0
  1
  2
  3
])
strArrayIsh =
  0: "0"
  1: "1"
  2: "2"
  3: "3"
  length: 4

g = new Buffer(strArrayIsh)
assert.deepEqual g, new Buffer([
  0
  1
  2
  3
])
assert.equal "TWFu", (new Buffer("Man")).toString("base64")
expected = [
  0xff
  0xff
  0xbe
  0xff
  0xef
  0xbf
  0xfb
  0xef
  0xff
]
assert.deepEqual Buffer("//++/++/++//", "base64"), Buffer(expected)
assert.deepEqual Buffer("__--_--_--__", "base64"), Buffer(expected)
quote = "Man is distinguished, not only by his reason, but by this " + "singular passion from other animals, which is a lust " + "of the mind, that by a perseverance of delight in the continued " + "and indefatigable generation of knowledge, exceeds the short " + "vehemence of any carnal pleasure."
expected = "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24s" + "IGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltY" + "WxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZX" + "JzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmR" + "lZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo" + "ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="
assert.equal expected, (new Buffer(quote)).toString("base64")
b = new Buffer(1024)
bytesWritten = b.write(expected, 0, "base64")
assert.equal quote.length, bytesWritten
assert.equal quote, b.toString("ascii", 0, quote.length)
expectedWhite = expected.slice(0, 60) + " \n" + expected.slice(60, 120) + " \n" + expected.slice(120, 180) + " \n" + expected.slice(180, 240) + " \n" + expected.slice(240, 300) + "\n" + expected.slice(300, 360) + "\n"
b = new Buffer(1024)
bytesWritten = b.write(expectedWhite, 0, "base64")
assert.equal quote.length, bytesWritten
assert.equal quote, b.toString("ascii", 0, quote.length)
b = new Buffer(expectedWhite, "base64")
assert.equal quote.length, b.length
assert.equal quote, b.toString("ascii", 0, quote.length)
expectedIllegal = expected.slice(0, 60) + " " + expected.slice(60, 120) + " ÿ" + expected.slice(120, 180) + " \u0000" + expected.slice(180, 240) + " " + expected.slice(240, 300) + "\u0003" + expected.slice(300, 360)
b = new Buffer(expectedIllegal, "base64")
assert.equal quote.length, b.length
assert.equal quote, b.toString("ascii", 0, quote.length)
assert.equal new Buffer("", "base64").toString(), ""
assert.equal new Buffer("K", "base64").toString(), ""
assert.equal new Buffer("Kg==", "base64").toString(), "*"
assert.equal new Buffer("Kio=", "base64").toString(), "**"
assert.equal new Buffer("Kioq", "base64").toString(), "***"
assert.equal new Buffer("KioqKg==", "base64").toString(), "****"
assert.equal new Buffer("KioqKio=", "base64").toString(), "*****"
assert.equal new Buffer("KioqKioq", "base64").toString(), "******"
assert.equal new Buffer("KioqKioqKg==", "base64").toString(), "*******"
assert.equal new Buffer("KioqKioqKio=", "base64").toString(), "********"
assert.equal new Buffer("KioqKioqKioq", "base64").toString(), "*********"
assert.equal new Buffer("KioqKioqKioqKg==", "base64").toString(), "**********"
assert.equal new Buffer("KioqKioqKioqKio=", "base64").toString(), "***********"
assert.equal new Buffer("KioqKioqKioqKioq", "base64").toString(), "************"
assert.equal new Buffer("KioqKioqKioqKioqKg==", "base64").toString(), "*************"
assert.equal new Buffer("KioqKioqKioqKioqKio=", "base64").toString(), "**************"
assert.equal new Buffer("KioqKioqKioqKioqKioq", "base64").toString(), "***************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKg==", "base64").toString(), "****************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKio=", "base64").toString(), "*****************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKioq", "base64").toString(), "******************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKioqKg==", "base64").toString(), "*******************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKioqKio=", "base64").toString(), "********************"
assert.equal new Buffer("Kg", "base64").toString(), "*"
assert.equal new Buffer("Kio", "base64").toString(), "**"
assert.equal new Buffer("KioqKg", "base64").toString(), "****"
assert.equal new Buffer("KioqKio", "base64").toString(), "*****"
assert.equal new Buffer("KioqKioqKg", "base64").toString(), "*******"
assert.equal new Buffer("KioqKioqKio", "base64").toString(), "********"
assert.equal new Buffer("KioqKioqKioqKg", "base64").toString(), "**********"
assert.equal new Buffer("KioqKioqKioqKio", "base64").toString(), "***********"
assert.equal new Buffer("KioqKioqKioqKioqKg", "base64").toString(), "*************"
assert.equal new Buffer("KioqKioqKioqKioqKio", "base64").toString(), "**************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKg", "base64").toString(), "****************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKio", "base64").toString(), "*****************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKioqKg", "base64").toString(), "*******************"
assert.equal new Buffer("KioqKioqKioqKioqKioqKioqKio", "base64").toString(), "********************"
assert.equal new Buffer("72INjkR5fchcxk9+VgdGPFJDxUBFR5/rMFsghgxADiw==", "base64").length, 32
assert.equal new Buffer("72INjkR5fchcxk9+VgdGPFJDxUBFR5/rMFsghgxADiw=", "base64").length, 32
assert.equal new Buffer("72INjkR5fchcxk9+VgdGPFJDxUBFR5/rMFsghgxADiw", "base64").length, 32
assert.equal new Buffer("w69jACy6BgZmaFvv96HG6MYksWytuZu3T1FvGnulPg==", "base64").length, 31
assert.equal new Buffer("w69jACy6BgZmaFvv96HG6MYksWytuZu3T1FvGnulPg=", "base64").length, 31
assert.equal new Buffer("w69jACy6BgZmaFvv96HG6MYksWytuZu3T1FvGnulPg", "base64").length, 31
dot = new Buffer("//4uAA==", "base64")
assert.equal dot[0], 0xff
assert.equal dot[1], 0xfe
assert.equal dot[2], 0x2e
assert.equal dot[3], 0x00
assert.equal dot.toString("base64"), "//4uAA=="
segments = [
  "TWFkbmVzcz8h"
  "IFRoaXM="
  "IGlz"
  "IG5vZGUuanMh"
]
buf = new Buffer(64)
pos = 0
i = 0

while i < segments.length
  pos += b.write(segments[i], pos, "base64")
  ++i
assert.equal b.toString("binary", 0, pos), "Madness?! This is node.js!"
l = Buffer.poolSize + 5
s = ""
i = 0
while i < l
  s += "h"
  i++
b = new Buffer(s)
i = 0
while i < l
  assert.equal "h".charCodeAt(0), b[i]
  i++
sb = b.toString()
assert.equal sb.length, s.length
assert.equal sb, s
b = new Buffer("abcde")
assert.equal "bcde", b.slice(1).toString()
assert.equal 14, Buffer.byteLength("Il était tué")
assert.equal 14, Buffer.byteLength("Il était tué", "utf8")
[
  "ucs2"
  "ucs-2"
  "utf16le"
  "utf-16le"
].forEach (encoding) ->
  assert.equal 24, Buffer.byteLength("Il était tué", encoding)
  return

assert.equal 12, Buffer.byteLength("Il était tué", "ascii")
assert.equal 12, Buffer.byteLength("Il était tué", "binary")
assert.equal 0, Buffer("hello").slice(0, 0).length
console.log "Create hex string from buffer"
hexb = new Buffer(256)
i = 0

while i < 256
  hexb[i] = i
  i++
hexStr = hexb.toString("hex")
assert.equal hexStr, "000102030405060708090a0b0c0d0e0f" + "101112131415161718191a1b1c1d1e1f" + "202122232425262728292a2b2c2d2e2f" + "303132333435363738393a3b3c3d3e3f" + "404142434445464748494a4b4c4d4e4f" + "505152535455565758595a5b5c5d5e5f" + "606162636465666768696a6b6c6d6e6f" + "707172737475767778797a7b7c7d7e7f" + "808182838485868788898a8b8c8d8e8f" + "909192939495969798999a9b9c9d9e9f" + "a0a1a2a3a4a5a6a7a8a9aaabacadaeaf" + "b0b1b2b3b4b5b6b7b8b9babbbcbdbebf" + "c0c1c2c3c4c5c6c7c8c9cacbcccdcecf" + "d0d1d2d3d4d5d6d7d8d9dadbdcdddedf" + "e0e1e2e3e4e5e6e7e8e9eaebecedeeef" + "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
console.log "Create buffer from hex string"
hexb2 = new Buffer(hexStr, "hex")
i = 0

while i < 256
  assert.equal hexb2[i], hexb[i]
  i++
console.log "Try to slice off the end of the buffer"
b = new Buffer([
  1
  2
  3
  4
  5
])
b2 = b.toString("hex", 1, 10000)
b3 = b.toString("hex", 1, 5)
b4 = b.toString("hex", 1)
assert.equal b2, b3
assert.equal b2, b4
x = buildBuffer([
  0x81
  0xa3
  0x66
  0x6f
  0x6f
  0xa3
  0x62
  0x61
  0x72
])
console.log x.inspect()
assert.equal "<Buffer 81 a3 66 6f 6f a3 62 61 72>", x.inspect()
z = x.slice(4)
console.log z.inspect()
console.log z.length
assert.equal 5, z.length
assert.equal 0x6f, z[0]
assert.equal 0xa3, z[1]
assert.equal 0x62, z[2]
assert.equal 0x61, z[3]
assert.equal 0x72, z[4]
z = x.slice(0)
console.log z.inspect()
console.log z.length
assert.equal z.length, x.length
z = x.slice(0, 4)
console.log z.inspect()
console.log z.length
assert.equal 4, z.length
assert.equal 0x81, z[0]
assert.equal 0xa3, z[1]
z = x.slice(0, 9)
console.log z.inspect()
console.log z.length
assert.equal 9, z.length
z = x.slice(1, 4)
console.log z.inspect()
console.log z.length
assert.equal 3, z.length
assert.equal 0xa3, z[0]
z = x.slice(2, 4)
console.log z.inspect()
console.log z.length
assert.equal 2, z.length
assert.equal 0x66, z[0]
assert.equal 0x6f, z[1]
assert.equal 0, Buffer("hello").slice(0, 0).length
[
  "ucs2"
  "ucs-2"
  "utf16le"
  "utf-16le"
].forEach (encoding) ->
  b = new Buffer(10)
  b.write "あいうえお", encoding
  assert.equal b.toString(encoding), "あいうえお"
  return


# Binary encoding should write only one byte per character.
b = Buffer([
  0xde
  0xad
  0xbe
  0xef
])
s = String.fromCharCode(0xffff)
b.write s, 0, "binary"
assert.equal 0xff, b[0]
assert.equal 0xad, b[1]
assert.equal 0xbe, b[2]
assert.equal 0xef, b[3]
s = String.fromCharCode(0xaaee)
b.write s, 0, "binary"
assert.equal 0xee, b[0]
assert.equal 0xad, b[1]
assert.equal 0xbe, b[2]
assert.equal 0xef, b[3]

# #1210 Test UTF-8 string includes null character
buf = new Buffer("\u0000")
assert.equal buf.length, 1
buf = new Buffer("\u0000\u0000")
assert.equal buf.length, 2
buf = new Buffer(2)
written = buf.write("") # 0byte
assert.equal written, 0
written = buf.write("\u0000") # 1byte (v8 adds null terminator)
assert.equal written, 1
written = buf.write("a\u0000") # 1byte * 2
assert.equal written, 2
written = buf.write("あ") # 3bytes
assert.equal written, 0
written = buf.write("\u0000あ") # 1byte + 3bytes
assert.equal written, 1
written = buf.write("\u0000\u0000あ") # 1byte * 2 + 3bytes
assert.equal written, 2
buf = new Buffer(10)
written = buf.write("あいう") # 3bytes * 3 (v8 adds null terminator)
assert.equal written, 9
written = buf.write("あいう\u0000") # 3bytes * 3 + 1byte
assert.equal written, 10

# #243 Test write() with maxLength
buf = new Buffer(4)
buf.fill 0xff
written = buf.write("abcd", 1, 2, "utf8")
console.log buf
assert.equal written, 2
assert.equal buf[0], 0xff
assert.equal buf[1], 0x61
assert.equal buf[2], 0x62
assert.equal buf[3], 0xff
buf.fill 0xff
written = buf.write("abcd", 1, 4)
console.log buf
assert.equal written, 3
assert.equal buf[0], 0xff
assert.equal buf[1], 0x61
assert.equal buf[2], 0x62
assert.equal buf[3], 0x63
buf.fill 0xff
written = buf.write("abcd", "utf8", 1, 2) # legacy style
console.log buf
assert.equal written, 2
assert.equal buf[0], 0xff
assert.equal buf[1], 0x61
assert.equal buf[2], 0x62
assert.equal buf[3], 0xff
buf.fill 0xff
written = buf.write("abcdef", 1, 2, "hex")
console.log buf
assert.equal written, 2
assert.equal buf[0], 0xff
assert.equal buf[1], 0xab
assert.equal buf[2], 0xcd
assert.equal buf[3], 0xff
[
  "ucs2"
  "ucs-2"
  "utf16le"
  "utf-16le"
].forEach (encoding) ->
  buf.fill 0xff
  written = buf.write("abcd", 0, 2, encoding)
  console.log buf
  assert.equal written, 2
  assert.equal buf[0], 0x61
  assert.equal buf[1], 0x00
  assert.equal buf[2], 0xff
  assert.equal buf[3], 0xff
  return


# test offset returns are correct
b = new Buffer(16)
assert.equal 4, b.writeUInt32LE(0, 0)
assert.equal 6, b.writeUInt16LE(0, 4)
assert.equal 7, b.writeUInt8(0, 6)
assert.equal 8, b.writeInt8(0, 7)
assert.equal 16, b.writeDoubleLE(0, 8)

# test unmatched surrogates not producing invalid utf8 output
# ef bf bd = utf-8 representation of unicode replacement character
# see https://codereview.chromium.org/121173009/
buf = new Buffer("ab�cd", "utf8")
assert.equal buf[0], 0x61
assert.equal buf[1], 0x62
assert.equal buf[2], 0xef
assert.equal buf[3], 0xbf
assert.equal buf[4], 0xbd
assert.equal buf[5], 0x63
assert.equal buf[6], 0x64

# test for buffer overrun
buf = new Buffer([ # length: 5
  0
  0
  0
  0
  0
])
sub = buf.slice(0, 4) # length: 4
written = sub.write("12345", "binary")
assert.equal written, 4
assert.equal buf[4], 0

# Check for fractional length args, junk length args, etc.
# https://github.com/joyent/node/issues/1758
Buffer(3.3).toString() # throws bad argument error in commit 43cb4ec
assert.equal Buffer(-1).length, 0
assert.equal Buffer(NaN).length, 0
assert.equal Buffer(3.3).length, 3
assert.equal Buffer(length: 3.3).length, 3
assert.equal Buffer(length: "BAM").length, 0

# Make sure that strings are not coerced to numbers.
assert.equal Buffer("99").length, 2
assert.equal Buffer("13.37").length, 5

# Ensure that the length argument is respected.
"ascii utf8 hex base64 binary".split(" ").forEach (enc) ->
  assert.equal Buffer(1).write("aaaaaa", 0, 1, enc), 1
  return


# Regression test, guard against buffer overrun in the base64 decoder.
a = Buffer(3)
b = Buffer("xxx")
a.write "aaaaaaaa", "base64"
assert.equal b.toString(), "xxx"

# issue GH-3416
Buffer Buffer(0), 0, 0
[
  "hex"
  "utf8"
  "utf-8"
  "ascii"
  "binary"
  "base64"
  "ucs2"
  "ucs-2"
  "utf16le"
  "utf-16le"
].forEach (enc) ->
  assert.equal Buffer.isEncoding(enc), true
  return

[
  "utf9"
  "utf-7"
  "Unicode-FTW"
  "new gnu gun"
].forEach (enc) ->
  assert.equal Buffer.isEncoding(enc), false
  return


# GH-5110
(->
  buffer = new Buffer("test")
  string = JSON.stringify(buffer)
  assert.equal string, "{\"type\":\"Buffer\",\"data\":[116,101,115,116]}"
  assert.deepEqual buffer, JSON.parse(string, (key, value) ->
    (if value and value.type is "Buffer" then new Buffer(value.data) else value)
  )
  return
)()

# issue GH-7849
(->
  buf = new Buffer("test")
  json = JSON.stringify(buf)
  obj = JSON.parse(json)
  copy = new Buffer(obj)
  assert buf.equals(copy)
  return
)()

# issue GH-4331
assert.throws (->
  new Buffer(0xffffffff)
  return
), RangeError
assert.throws (->
  new Buffer(0xfffffffff)
  return
), RangeError

# attempt to overflow buffers, similar to previous bug in array buffers
assert.throws (->
  buf = new Buffer(8)
  buf.readFloatLE 0xffffffff
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.writeFloatLE 0.0, 0xffffffff
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.readFloatLE 0xffffffff
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.writeFloatLE 0.0, 0xffffffff
  return
), RangeError

# ensure negative values can't get past offset
assert.throws (->
  buf = new Buffer(8)
  buf.readFloatLE -1
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.writeFloatLE 0.0, -1
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.readFloatLE -1
  return
), RangeError
assert.throws (->
  buf = new Buffer(8)
  buf.writeFloatLE 0.0, -1
  return
), RangeError

# offset checks
buf = new Buffer(0)
assert.throws (->
  buf.readUInt8 0
  return
), RangeError
assert.throws (->
  buf.readInt8 0
  return
), RangeError
buf = new Buffer([0xff])
assert.equal buf.readUInt8(0), 255
assert.equal buf.readInt8(0), -1
[
  16
  32
].forEach (bits) ->
  buf = new Buffer(bits / 8 - 1)
  assert.throws (->
    buf["readUInt" + bits + "BE"] 0
    return
  ), RangeError, "readUInt" + bits + "BE"
  assert.throws (->
    buf["readUInt" + bits + "LE"] 0
    return
  ), RangeError, "readUInt" + bits + "LE"
  assert.throws (->
    buf["readInt" + bits + "BE"] 0
    return
  ), RangeError, "readInt" + bits + "BE()"
  assert.throws (->
    buf["readInt" + bits + "LE"] 0
    return
  ), RangeError, "readInt" + bits + "LE()"
  return

[
  16
  32
].forEach (bits) ->
  buf = new Buffer([
    0xff
    0xff
    0xff
    0xff
  ])
  assert.equal buf["readUInt" + bits + "BE"](0), (0xffffffff >>> (32 - bits))
  assert.equal buf["readUInt" + bits + "LE"](0), (0xffffffff >>> (32 - bits))
  assert.equal buf["readInt" + bits + "BE"](0), (0xffffffff >> (32 - bits))
  assert.equal buf["readInt" + bits + "LE"](0), (0xffffffff >> (32 - bits))
  return


# test for common read(U)IntLE/BE
(->
  buf = new Buffer([
    0x01
    0x02
    0x03
    0x04
    0x05
    0x06
  ])
  assert.equal buf.readUIntLE(0, 1), 0x01
  assert.equal buf.readUIntBE(0, 1), 0x01
  assert.equal buf.readUIntLE(0, 3), 0x030201
  assert.equal buf.readUIntBE(0, 3), 0x010203
  assert.equal buf.readUIntLE(0, 5), 0x0504030201
  assert.equal buf.readUIntBE(0, 5), 0x0102030405
  assert.equal buf.readUIntLE(0, 6), 0x060504030201
  assert.equal buf.readUIntBE(0, 6), 0x010203040506
  assert.equal buf.readIntLE(0, 1), 0x01
  assert.equal buf.readIntBE(0, 1), 0x01
  assert.equal buf.readIntLE(0, 3), 0x030201
  assert.equal buf.readIntBE(0, 3), 0x010203
  assert.equal buf.readIntLE(0, 5), 0x0504030201
  assert.equal buf.readIntBE(0, 5), 0x0102030405
  assert.equal buf.readIntLE(0, 6), 0x060504030201
  assert.equal buf.readIntBE(0, 6), 0x010203040506
  return
)()

# test for common write(U)IntLE/BE
(->
  buf = new Buffer(3)
  buf.writeUIntLE 0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0x56
    0x34
    0x12
  ]
  assert.equal buf.readUIntLE(0, 3), 0x123456
  buf = new Buffer(3)
  buf.writeUIntBE 0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0x12
    0x34
    0x56
  ]
  assert.equal buf.readUIntBE(0, 3), 0x123456
  buf = new Buffer(3)
  buf.writeIntLE 0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0x56
    0x34
    0x12
  ]
  assert.equal buf.readIntLE(0, 3), 0x123456
  buf = new Buffer(3)
  buf.writeIntBE 0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0x12
    0x34
    0x56
  ]
  assert.equal buf.readIntBE(0, 3), 0x123456
  buf = new Buffer(3)
  buf.writeIntLE -0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0xaa
    0xcb
    0xed
  ]
  assert.equal buf.readIntLE(0, 3), -0x123456
  buf = new Buffer(3)
  buf.writeIntBE -0x123456, 0, 3
  assert.deepEqual buf.toJSON().data, [
    0xed
    0xcb
    0xaa
  ]
  assert.equal buf.readIntBE(0, 3), -0x123456
  buf = new Buffer(5)
  buf.writeUIntLE 0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0x90
    0x78
    0x56
    0x34
    0x12
  ]
  assert.equal buf.readUIntLE(0, 5), 0x1234567890
  buf = new Buffer(5)
  buf.writeUIntBE 0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0x12
    0x34
    0x56
    0x78
    0x90
  ]
  assert.equal buf.readUIntBE(0, 5), 0x1234567890
  buf = new Buffer(5)
  buf.writeIntLE 0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0x90
    0x78
    0x56
    0x34
    0x12
  ]
  assert.equal buf.readIntLE(0, 5), 0x1234567890
  buf = new Buffer(5)
  buf.writeIntBE 0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0x12
    0x34
    0x56
    0x78
    0x90
  ]
  assert.equal buf.readIntBE(0, 5), 0x1234567890
  buf = new Buffer(5)
  buf.writeIntLE -0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0x70
    0x87
    0xa9
    0xcb
    0xed
  ]
  assert.equal buf.readIntLE(0, 5), -0x1234567890
  buf = new Buffer(5)
  buf.writeIntBE -0x1234567890, 0, 5
  assert.deepEqual buf.toJSON().data, [
    0xed
    0xcb
    0xa9
    0x87
    0x70
  ]
  assert.equal buf.readIntBE(0, 5), -0x1234567890
  return
)()

# test Buffer slice
(->
  buf = new Buffer("0123456789")
  assert.equal buf.slice(-10, 10), "0123456789"
  assert.equal buf.slice(-20, 10), "0123456789"
  assert.equal buf.slice(-20, -10), ""
  assert.equal buf.slice(0, -1), "012345678"
  assert.equal buf.slice(2, -2), "234567"
  assert.equal buf.slice(0, 65536), "0123456789"
  assert.equal buf.slice(65536, 0), ""
  i = 0
  s = buf.toString()

  while i < buf.length
    assert.equal buf.slice(-i), s.slice(-i)
    assert.equal buf.slice(0, -i), s.slice(0, -i)
    ++i
  
  # try to slice a zero length Buffer
  # see https://github.com/joyent/node/issues/5881
  SlowBuffer(0).slice 0, 1
  
  # make sure a zero length slice doesn't set the .parent attribute
  assert.equal Buffer(5).slice(0, 0).parent, `undefined`
  
  # and make sure a proper slice does have a parent
  assert.ok typeof Buffer(5).slice(0, 5).parent is "object"
  return
)()

# Make sure byteLength properly checks for base64 padding
assert.equal Buffer.byteLength("aaa=", "base64"), 2
assert.equal Buffer.byteLength("aaaa==", "base64"), 3

# Regression test for #5482: should throw but not assert in C++ land.
assert.throws (->
  Buffer "", "buffer"
  return
), TypeError

# Regression test for #6111. Constructing a buffer from another buffer
# should a) work, and b) not corrupt the source buffer.
(->
  a = [0]
  i = 0

  while i < 7
    a = a.concat(a)
    ++i
  a = a.map((_, i) ->
    i
  )
  b = Buffer(a)
  c = Buffer(b)
  assert.equal b.length, a.length
  assert.equal c.length, a.length
  i = 0
  k = a.length

  while i < k
    assert.equal a[i], i
    assert.equal b[i], i
    assert.equal c[i], i
    ++i
  return
)()
assert.throws (->
  new Buffer(smalloc.kMaxLength + 1)
  return
), RangeError
assert.throws (->
  new SlowBuffer(smalloc.kMaxLength + 1)
  return
), RangeError

# Test truncation after decode
crypto = require("crypto")
b1 = new Buffer("YW55=======", "base64")
b2 = new Buffer("YW55", "base64")
assert.equal crypto.createHash("sha1").update(b1).digest("hex"), crypto.createHash("sha1").update(b2).digest("hex")

# Test Compare
b = new Buffer(1).fill("a")
c = new Buffer(1).fill("c")
d = new Buffer(2).fill("aa")
assert.equal b.compare(c), -1
assert.equal c.compare(d), 1
assert.equal d.compare(b), 1
assert.equal b.compare(d), -1
assert.equal Buffer.compare(b, c), -1
assert.equal Buffer.compare(c, d), 1
assert.equal Buffer.compare(d, b), 1
assert.equal Buffer.compare(b, d), -1
assert.throws ->
  b = new Buffer(1)
  Buffer.compare b, "abc"
  return

assert.throws ->
  b = new Buffer(1)
  Buffer.compare "abc", b
  return

assert.throws ->
  b = new Buffer(1)
  b.compare "abc"
  return


# Test Equals
b = new Buffer(5).fill("abcdf")
c = new Buffer(5).fill("abcdf")
d = new Buffer(5).fill("abcde")
e = new Buffer(6).fill("abcdef")
assert.ok b.equals(c)
assert.ok not c.equals(d)
assert.ok not d.equals(e)
assert.throws ->
  b = new Buffer(1)
  b.equals "abc"
  return

