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
os = require("os")
process.env.TMPDIR = "/tmpdir"
process.env.TMP = "/tmp"
process.env.TEMP = "/temp"
if process.platform is "win32"
  assert.equal os.tmpdir(), "/temp"
  process.env.TEMP = ""
  assert.equal os.tmpdir(), "/tmp"
  process.env.TMP = ""
  expected = (process.env.SystemRoot or process.env.windir) + "\\temp"
  assert.equal os.tmpdir(), expected
else
  assert.equal os.tmpdir(), "/tmpdir"
  process.env.TMPDIR = ""
  assert.equal os.tmpdir(), "/tmp"
  process.env.TMP = ""
  assert.equal os.tmpdir(), "/temp"
  process.env.TEMP = ""
  assert.equal os.tmpdir(), "/tmp"
endianness = os.endianness()
console.log "endianness = %s", endianness
assert.ok /[BL]E/.test(endianness)
hostname = os.hostname()
console.log "hostname = %s", hostname
assert.ok hostname.length > 0
uptime = os.uptime()
console.log "uptime = %d", uptime
assert.ok uptime > 0
cpus = os.cpus()
console.log "cpus = ", cpus
assert.ok cpus.length > 0
type = os.type()
console.log "type = ", type
assert.ok type.length > 0
release = os.release()
console.log "release = ", release
assert.ok release.length > 0
platform = os.platform()
console.log "platform = ", platform
assert.ok platform.length > 0
arch = os.arch()
console.log "arch = ", arch
assert.ok arch.length > 0
unless process.platform is "sunos"
  
  # not implemeneted yet
  assert.ok os.loadavg().length > 0
  assert.ok os.freemem() > 0
  assert.ok os.totalmem() > 0
interfaces = os.networkInterfaces()
console.error interfaces
switch platform
  when "linux"
    filter = (e) ->
      e.address is "127.0.0.1"

    actual = interfaces.lo.filter(filter)
    expected = [
      address: "127.0.0.1"
      netmask: "255.0.0.0"
      mac: "00:00:00:00:00:00"
      family: "IPv4"
      internal: true
    ]
    assert.deepEqual actual, expected
  when "win32"
    filter = (e) ->
      e.address is "127.0.0.1"

    actual = interfaces["Loopback Pseudo-Interface 1"].filter(filter)
    expected = [
      address: "127.0.0.1"
      netmask: "255.0.0.0"
      mac: "00:00:00:00:00:00"
      family: "IPv4"
      internal: true
    ]
    assert.deepEqual actual, expected
EOL = os.EOL
assert.ok EOL.length > 0
