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

# test unzipping a file that was created by concatenating multiple gzip
# streams.
gzipAppend = (data) ->
  data.copy gzipBuffer, gzipOffset
  gzipOffset += data.length
  return
writeGzipStream = (text, cb) ->
  gzip = zlib.createGzip()
  gzip.on "data", gzipAppend
  gzip.write text, ->
    gzip.flush ->
      gzip.end ->
        cb()
        return

      return

    return

  return
writeGarbageStream = (text, cb) ->
  gzipAppend new Buffer(text)
  cb()
  return
common = require("../common")
assert = require("assert")
zlib = require("zlib")
util = require("util")
gzipBuffer = new Buffer(128)
gzipOffset = 0
stream1 = "123\n"
stream2 = "456\n"
stream3 = "789\n"
writeGzipStream stream1, ->
  writeGzipStream stream2, ->
    writeGarbageStream stream3, ->
      gunzip = zlib.createGunzip()
      gunzippedData = new Buffer(2 * 1024)
      gunzippedOffset = 0
      gunzip.on "data", (data) ->
        data.copy gunzippedData, gunzippedOffset
        gunzippedOffset += data.length
        return

      gunzip.on "error", ->
        assert.equal gunzippedData.toString("utf8", 0, gunzippedOffset), stream1 + stream2
        return

      gunzip.on "end", ->
        assert.fail "end event not expected"
        return

      gunzip.write gzipBuffer.slice(0, gzipOffset), "binary", ->
        gunzip.end()
        return

      return

    return

  return

