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

# verify that the string decoder works getting 1 byte at a time,
# the whole buffer at once, and that both match the .toString(enc)
# result of the entire buffer.

# also test just arbitrary bytes from 0-15.
testEncoding = (encoding) ->
  bufs.forEach (buf) ->
    testBuf encoding, buf
    return

  return
testBuf = (encoding, buf) ->
  console.error "# %s", encoding, buf
  
  # write one byte at a time.
  s = new SD(encoding)
  res1 = ""
  i = 0

  while i < buf.length
    res1 += s.write(buf.slice(i, i + 1))
    i++
  res1 += s.end()
  
  # write the whole buffer at once.
  res2 = ""
  s = new SD(encoding)
  res2 += s.write(buf)
  res2 += s.end()
  
  # .toString() on the buffer
  res3 = buf.toString(encoding)
  console.log "expect=%j", res3
  assert.equal res1, res3, "one byte at a time should match toString"
  assert.equal res2, res3, "all bytes at once should match toString"
  return
assert = require("assert")
SD = require("string_decoder").StringDecoder
encodings = [
  "base64"
  "hex"
  "utf8"
  "utf16le"
  "ucs2"
]
bufs = [
  "☃💩"
  "asdf"
].map((b) ->
  new Buffer(b)
)
i = 1

while i <= 16
  bytes = new Array(i).join(".").split(".").map((_, j) ->
    j + 0x78
  )
  bufs.push new Buffer(bytes)
  i++
encodings.forEach testEncoding
console.log "ok"
