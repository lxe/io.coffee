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

# test unzipping a file that was created with a non-node gzip lib,
# piped in as fast as possible.
common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
path = require("path")
gunzip = zlib.createGunzip()
fs = require("fs")
fixture = path.resolve(common.fixturesDir, "person.jpg.gz")
unzippedFixture = path.resolve(common.fixturesDir, "person.jpg")
outputFile = path.resolve(common.tmpDir, "person.jpg")
expect = fs.readFileSync(unzippedFixture)
inp = fs.createReadStream(fixture)
out = fs.createWriteStream(outputFile)
inp.pipe(gunzip).pipe out
out.on "close", ->
  actual = fs.readFileSync(outputFile)
  assert.equal actual.length, expect.length, "length should match"
  i = 0
  l = actual.length

  while i < l
    assert.equal actual[i], expect[i], "byte[" + i + "]"
    i++
  return

