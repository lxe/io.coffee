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
"use strict"
binding = process.binding("os")
util = require("util")
isWindows = process.platform is "win32"
exports.hostname = binding.getHostname
exports.loadavg = binding.getLoadAvg
exports.uptime = binding.getUptime
exports.freemem = binding.getFreeMem
exports.totalmem = binding.getTotalMem
exports.cpus = binding.getCPUs
exports.type = binding.getOSType
exports.release = binding.getOSRelease
exports.networkInterfaces = binding.getInterfaceAddresses
exports.arch = ->
  process.arch

exports.platform = ->
  process.platform

exports.tmpdir = ->
  if isWindows
    process.env.TEMP or process.env.TMP or (process.env.SystemRoot or process.env.windir) + "\\temp"
  else
    process.env.TMPDIR or process.env.TMP or process.env.TEMP or "/tmp"

exports.tmpDir = exports.tmpdir
exports.getNetworkInterfaces = util.deprecate(->
  exports.networkInterfaces()
, "getNetworkInterfaces is now called `os.networkInterfaces`.")
exports.EOL = (if isWindows then "\r\n" else "\n")
if binding.isBigEndian
  exports.endianness = ->
    "BE"
else
  exports.endianness = ->
    "LE"
