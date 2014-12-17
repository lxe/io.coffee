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

# Remove manually, the test runner won't do it
# for us like it does for files in test/tmp.

# Ignore.

#for (var i in exports) global[i] = exports[i];
protoCtrChain = (o) ->
  result = []
  while o
    result.push o.constructor
    o = o.__proto__
  result.join()
# Enumerable in V8 3.21.

# Harmony features.
leakedGlobals = ->
  leaked = []
  for val of global
    continue
  leaked

# Turn this off if the test should not check for global leaks.
runCallChecks = (exitCode) ->
  return  if exitCode isnt 0
  failed = mustCallChecks.filter((context) ->
    context.actual isnt context.expected
  )
  failed.forEach (context) ->
    console.log "Mismatched %s function calls. Expected %d, actual %d.", context.name, context.expected, context.actual
    console.log context.stack.split("\n").slice(2).join("\n")
    return

  process.exit 1  if failed.length
  return
path = require("path")
fs = require("fs")
assert = require("assert")
os = require("os")
exports.testDir = path.dirname(__filename)
exports.fixturesDir = path.join(exports.testDir, "fixtures")
exports.libDir = path.join(exports.testDir, "../lib")
exports.tmpDir = path.join(exports.testDir, "tmp")
exports.PORT = +process.env.NODE_COMMON_PORT or 12346
exports.opensslCli = path.join(path.dirname(process.execPath), "openssl-cli")
if process.platform is "win32"
  exports.PIPE = "\\\\.\\pipe\\libuv-test"
  exports.opensslCli += ".exe"
else
  exports.PIPE = exports.tmpDir + "/test.sock"
if process.env.NODE_COMMON_PIPE
  exports.PIPE = process.env.NODE_COMMON_PIPE
  try
    fs.unlinkSync exports.PIPE
exports.opensslCli = false  unless fs.existsSync(exports.opensslCli)
if process.platform is "win32"
  exports.faketimeCli = false
else
  exports.faketimeCli = path.join(__dirname, "..", "tools", "faketime", "src", "faketime")
ifaces = os.networkInterfaces()
exports.hasIPv6 = Object.keys(ifaces).some((name) ->
  /lo/.test(name) and ifaces[name].some((info) ->
    info.family is "IPv6"
  )
)
util = require("util")
for i of util
  exports[i] = util[i]
exports.indirectInstanceOf = (obj, cls) ->
  return true  if obj instanceof cls
  clsChain = protoCtrChain(cls::)
  objChain = protoCtrChain(obj)
  objChain.slice(-clsChain.length) is clsChain

exports.ddCommand = (filename, kilobytes) ->
  if process.platform is "win32"
    p = path.resolve(exports.fixturesDir, "create-file.js")
    "\"" + process.argv[0] + "\" \"" + p + "\" \"" + filename + "\" " + (kilobytes * 1024)
  else
    "dd if=/dev/zero of=\"" + filename + "\" bs=1024 count=" + kilobytes

exports.spawnCat = (options) ->
  spawn = require("child_process").spawn
  if process.platform is "win32"
    spawn "more", [], options
  else
    spawn "cat", [], options

exports.spawnPwd = (options) ->
  spawn = require("child_process").spawn
  if process.platform is "win32"
    spawn "cmd.exe", [
      "/c"
      "cd"
    ], options
  else
    spawn "pwd", [], options

knownGlobals = [
  setTimeout
  setInterval
  setImmediate
  clearTimeout
  clearInterval
  clearImmediate
  console
  constructor
  Buffer
  process
  global
]
knownGlobals.push gc  if global.gc
if global.DTRACE_HTTP_SERVER_RESPONSE
  knownGlobals.push DTRACE_HTTP_SERVER_RESPONSE
  knownGlobals.push DTRACE_HTTP_SERVER_REQUEST
  knownGlobals.push DTRACE_HTTP_CLIENT_RESPONSE
  knownGlobals.push DTRACE_HTTP_CLIENT_REQUEST
  knownGlobals.push DTRACE_NET_STREAM_END
  knownGlobals.push DTRACE_NET_SERVER_CONNECTION
  knownGlobals.push DTRACE_NET_SOCKET_READ
  knownGlobals.push DTRACE_NET_SOCKET_WRITE
if global.COUNTER_NET_SERVER_CONNECTION
  knownGlobals.push COUNTER_NET_SERVER_CONNECTION
  knownGlobals.push COUNTER_NET_SERVER_CONNECTION_CLOSE
  knownGlobals.push COUNTER_HTTP_SERVER_REQUEST
  knownGlobals.push COUNTER_HTTP_SERVER_RESPONSE
  knownGlobals.push COUNTER_HTTP_CLIENT_REQUEST
  knownGlobals.push COUNTER_HTTP_CLIENT_RESPONSE
if global.ArrayBuffer
  knownGlobals.push ArrayBuffer
  knownGlobals.push Int8Array
  knownGlobals.push Uint8Array
  knownGlobals.push Uint8ClampedArray
  knownGlobals.push Int16Array
  knownGlobals.push Uint16Array
  knownGlobals.push Int32Array
  knownGlobals.push Uint32Array
  knownGlobals.push Float32Array
  knownGlobals.push Float64Array
  knownGlobals.push DataView
knownGlobals.push Proxy  if global.Proxy
knownGlobals.push Symbol  if global.Symbol
exports.leakedGlobals = leakedGlobals
exports.globalCheck = true
process.on "exit", ->
  return  unless exports.globalCheck
  leaked = leakedGlobals()
  if leaked.length > 0
    console.error "Unknown globals: %s", leaked
    assert.ok false, "Unknown global found"
  return

mustCallChecks = []
exports.mustCall = (fn, expected) ->
  expected = 1  if typeof expected isnt "number"
  context =
    expected: expected
    actual: 0
    stack: (new Error).stack
    name: fn.name or "<anonymous>"

  
  # add the exit listener only once to avoid listener leak warnings
  process.on "exit", runCallChecks  if mustCallChecks.length is 0
  mustCallChecks.push context
  ->
    context.actual++
    fn.apply this, arguments

exports.checkSpawnSyncRet = (ret) ->
  assert.strictEqual ret.status, 0
  assert.strictEqual ret.error, `undefined`
  return

etcServicesFileName = path.join("/etc", "services")
etcServicesFileName = path.join(process.env.SystemRoot, "System32", "drivers", "etc", "services")  if process.platform is "win32"

#
# * Returns a string that represents the service name associated
# * to the service bound to port "port" and using protocol "protocol".
# *
# * If the service is not defined in the services file, it returns
# * the port number as a string.
# *
# * Returns undefined if /etc/services (or its equivalent on non-UNIX
# * platforms) can't be read.
# 
exports.getServiceName = getServiceName = (port, protocol) ->
  throw new Error("Missing port number")  unless port?
  throw new Error("Protocol must be a string")  if typeof protocol isnt "string"
  
  #
  #   * By default, if a service can't be found in /etc/services,
  #   * its name is considered to be its port number.
  #   
  serviceName = port.toString()
  try
    
    #
    #     * I'm not a big fan of readFileSync, but reading /etc/services asynchronously
    #     * here would require implementing a simple line parser, which seems overkill
    #     * for a simple utility function that is not running concurrently with any
    #     * other one.
    #     
    servicesContent = fs.readFileSync(etcServicesFileName,
      encoding: "utf8"
    )
    regexp = util.format("^(\\w+)\\s+\\s%d/%s\\s", port, protocol)
    re = new RegExp(regexp, "m")
    matches = re.exec(servicesContent)
    serviceName = matches[1]  if matches and matches.length > 1
  catch e
    console.error "Cannot read file: ", etcServicesFileName
    return `undefined`
  serviceName

exports.isValidHostname = (str) ->
  
  # See http://stackoverflow.com/a/3824105
  re = new RegExp("^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])" + "(\\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$")
  !!str.match(re) and str.length <= 255
