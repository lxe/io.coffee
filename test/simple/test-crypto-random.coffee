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

# bump, we register a lot of exit listeners

# assert that the callback is indeed called
checkCall = (cb, desc) ->
  called_ = false
  process.on "exit", ->
    assert.equal true, called_, desc or ("callback not called: " + cb)
    return

  ->
    called_ = true
    cb.apply(cb, Array::slice.call(arguments))
common = require("../common")
assert = require("assert")
try
  crypto = require("crypto")
catch e
  console.log "Not compiled with OPENSSL support."
  process.exit()
crypto.DEFAULT_ENCODING = "buffer"
process.setMaxListeners 256
[
  crypto.randomBytes
  crypto.pseudoRandomBytes
].forEach (f) ->
  [
    -1
    `undefined`
    null
    false
    true
    {
      {}
    }
    []
  ].forEach (value) ->
    assert.throws ->
      f value
      return

    assert.throws ->
      f value, ->

      return

    return

  [
    0
    1
    2
    4
    16
    256
    1024
  ].forEach (len) ->
    f len, checkCall((ex, buf) ->
      assert.equal null, ex
      assert.equal len, buf.length
      assert.ok Buffer.isBuffer(buf)
      return
    )
    return

  return


# #5126, "FATAL ERROR: v8::Object::SetIndexedPropertiesToExternalArrayData()
# length exceeds max acceptable value"
assert.throws (->
  crypto.randomBytes 0x3fffffff + 1
  return
), TypeError
