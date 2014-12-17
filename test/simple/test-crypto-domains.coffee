# Copyright Joyent, Inc. and other Node contributors.

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
crypto = require("crypto")
domain = require("domain")
assert = require("assert")
d = domain.create()
expect = [
  "pbkdf2"
  "randomBytes"
  "pseudoRandomBytes"
]
errors = 0
process.on "exit", ->
  assert.equal errors, 3
  return

d.on "error", (e) ->
  assert.equal e.message, expect.shift()
  errors += 1
  return

d.run ->
  one = ->
    crypto.pbkdf2 "a", "b", 1, 8, ->
      two()
      throw new Error("pbkdf2")return

    return
  two = ->
    crypto.randomBytes 4, ->
      three()
      throw new Error("randomBytes")return

    return
  three = ->
    crypto.pseudoRandomBytes 4, ->
      throw new Error("pseudoRandomBytes")return

    return
  one()
  return

