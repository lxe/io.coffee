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
noop = ->
common = require("../common")
assert = require("assert")
dns = require("dns")
existing = dns.getServers()
assert existing.length
goog = [
  "8.8.8.8"
  "8.8.4.4"
]
assert.doesNotThrow ->
  dns.setServers goog
  return

assert.deepEqual dns.getServers(), goog
assert.throws ->
  dns.setServers ["foobar"]
  return

assert.deepEqual dns.getServers(), goog
goog6 = [
  "2001:4860:4860::8888"
  "2001:4860:4860::8844"
]
assert.doesNotThrow ->
  dns.setServers goog6
  return

assert.deepEqual dns.getServers(), goog6
goog6.push "4.4.4.4"
dns.setServers goog6
assert.deepEqual dns.getServers(), goog6
ports = [
  "4.4.4.4:53"
  "[2001:4860:4860::8888]:53"
]
portsExpected = [
  "4.4.4.4"
  "2001:4860:4860::8888"
]
dns.setServers ports
assert.deepEqual dns.getServers(), portsExpected
assert.doesNotThrow ->
  dns.setServers []
  return

assert.deepEqual dns.getServers(), []
assert.throws (->
  dns.resolve "test.com", [], noop
  return
), ((err) ->
  (err not instanceof TypeError)
), "Unexpected error"

# dns.lookup should accept falsey and string values
assert.throws (->
  dns.lookup {}, noop
  return
), "invalid arguments: hostname must be a string or falsey"
assert.throws (->
  dns.lookup [], noop
  return
), "invalid arguments: hostname must be a string or falsey"
assert.throws (->
  dns.lookup true, noop
  return
), "invalid arguments: hostname must be a string or falsey"
assert.throws (->
  dns.lookup 1, noop
  return
), "invalid arguments: hostname must be a string or falsey"
assert.throws (->
  dns.lookup noop, noop
  return
), "invalid arguments: hostname must be a string or falsey"
assert.doesNotThrow ->
  dns.lookup "", noop
  return

assert.doesNotThrow ->
  dns.lookup null, noop
  return

assert.doesNotThrow ->
  dns.lookup `undefined`, noop
  return

assert.doesNotThrow ->
  dns.lookup 0, noop
  return

assert.doesNotThrow ->
  dns.lookup NaN, noop
  return


#
# * Make sure that dns.lookup throws if hints does not represent a valid flag.
# * (dns.V4MAPPED | dns.ADDRCONFIG) + 1 is invalid because:
# * - it's different from dns.V4MAPPED and dns.ADDRCONFIG.
# * - it's different from them bitwise ored.
# * - it's different from 0.
# * - it's an odd number different than 1, and thus is invalid, because
# * flags are either === 1 or even.
# 
assert.throws ->
  dns.lookup "www.google.com",
    hints: (dns.V4MAPPED | dns.ADDRCONFIG) + 1
  , noop
  return

assert.throws (->
  dns.lookup "www.google.com"
  return
), "invalid arguments: callback must be passed"
assert.throws (->
  dns.lookup "www.google.com", 4
  return
), "invalid arguments: callback must be passed"
assert.doesNotThrow ->
  dns.lookup "www.google.com", 6, noop
  return

assert.doesNotThrow ->
  dns.lookup "www.google.com", {}, noop
  return

assert.doesNotThrow ->
  dns.lookup "www.google.com",
    family: 4
    hints: 0
  , noop
  return

assert.doesNotThrow ->
  dns.lookup "www.google.com",
    family: 6
    hints: dns.ADDRCONFIG
  , noop
  return

assert.doesNotThrow ->
  dns.lookup "www.google.com",
    hints: dns.V4MAPPED
  , noop
  return

assert.doesNotThrow ->
  dns.lookup "www.google.com",
    hints: dns.ADDRCONFIG | dns.V4MAPPED
  , noop
  return

