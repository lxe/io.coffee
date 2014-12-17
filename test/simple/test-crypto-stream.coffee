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

# Small stream to buffer converter
Stream2buffer = (callback) ->
  stream.Writable.call this
  @_buffers = []
  @once "finish", ->
    callback null, Buffer.concat(@_buffers)
    return

  return
common = require("../common")
assert = require("assert")
stream = require("stream")
util = require("util")
try
  crypto = require("crypto")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
util.inherits Stream2buffer, stream.Writable
Stream2buffer::_write = (data, encodeing, done) ->
  @_buffers.push data
  done null


# Create an md5 hash of "Hallo world"
hasher1 = crypto.createHash("md5")
hasher1.pipe new Stream2buffer(common.mustCall(end = (err, hash) ->
  assert.equal err, null
  assert.equal hash.toString("hex"), "06460dadb35d3d503047ce750ceb2d07"
  return
))
hasher1.end "Hallo world"

# Simpler check for unpipe, setEncoding, pause and resume
crypto.createHash("md5").unpipe {}
crypto.createHash("md5").setEncoding "utf8"
crypto.createHash("md5").pause()
crypto.createHash("md5").resume()

# Decipher._flush() should emit an error event, not an exception.
key = new Buffer("48fb56eb10ffeb13fc0ef551bbca3b1b", "hex")
badkey = new Buffer("12341234123412341234123412341234", "hex")
iv = new Buffer("6d358219d1f488f5f4eb12820a66d146", "hex")
cipher = crypto.createCipheriv("aes-128-cbc", key, iv)
decipher = crypto.createDecipheriv("aes-128-cbc", badkey, iv)
cipher.pipe(decipher).on "error", common.mustCall(end = (err) ->
  assert /Unsupported/.test(err)
  return
)
cipher.end "Papaya!" # Should not cause an unhandled exception.
