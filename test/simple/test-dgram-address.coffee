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
common = require("../common")
assert = require("assert")
dgram = require("dgram")

# IPv4 Test
localhost_ipv4 = "127.0.0.1"
socket_ipv4 = dgram.createSocket("udp4")
family_ipv4 = "IPv4"
socket_ipv4.on "listening", ->
  address_ipv4 = socket_ipv4.address()
  assert.strictEqual address_ipv4.address, localhost_ipv4
  assert.strictEqual address_ipv4.port, common.PORT
  assert.strictEqual address_ipv4.family, family_ipv4
  socket_ipv4.close()
  return

socket_ipv4.on "error", (e) ->
  console.log "Error on udp4 socket. " + e.toString()
  socket_ipv4.close()
  return

socket_ipv4.bind common.PORT, localhost_ipv4

# IPv6 Test
localhost_ipv6 = "::1"
socket_ipv6 = dgram.createSocket("udp6")
family_ipv6 = "IPv6"
socket_ipv6.on "listening", ->
  address_ipv6 = socket_ipv6.address()
  assert.strictEqual address_ipv6.address, localhost_ipv6
  assert.strictEqual address_ipv6.port, common.PORT
  assert.strictEqual address_ipv6.family, family_ipv6
  socket_ipv6.close()
  return

socket_ipv6.on "error", (e) ->
  console.log "Error on udp6 socket. " + e.toString()
  socket_ipv6.close()
  return

socket_ipv6.bind common.PORT, localhost_ipv6
