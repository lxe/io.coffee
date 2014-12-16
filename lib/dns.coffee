# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
errnoException = (err, syscall, hostname) ->
  
  # FIXME(bnoordhuis) Remove this backwards compatibility shite and pass
  # the true error to the user. ENOTFOUND is not even a proper POSIX error!
  err = "ENOTFOUND"  if err is uv.UV_EAI_MEMORY or err is uv.UV_EAI_NODATA or err is uv.UV_EAI_NONAME
  ex = null
  if typeof err is "string" # c-ares error code.
    ex = new Error(syscall + " " + err + ((if hostname then " " + hostname else "")))
    ex.code = err
    ex.errno = err
    ex.syscall = syscall
  else
    ex = util._errnoException(err, syscall)
  ex.hostname = hostname  if hostname
  ex

# c-ares invokes a callback either synchronously or asynchronously,
# but the dns API should always invoke a callback asynchronously.
#
# This function makes sure that the callback is invoked asynchronously.
# It returns a function that invokes the callback within nextTick().
#
# To avoid invoking unnecessary nextTick(), `immediately` property of
# returned function should be set to true after c-ares returned.
#
# Usage:
#
# function someAPI(callback) {
#   callback = makeAsync(callback);
#   channel.someAPI(..., callback);
#   callback.immediately = true;
# }
makeAsync = (callback) ->
  return callback  unless util.isFunction(callback)
  asyncCallback = ->
    if asyncCallback.immediately
      
      # The API already returned, we can invoke the callback immediately.
      callback.apply null, arguments
    else
      args = arguments
      process.nextTick ->
        callback.apply null, args
        return

    return
onlookup = (err, addresses) ->
  return @callback(errnoException(err, "getaddrinfo", @hostname))  if err
  if @family
    @callback null, addresses[0], @family
  else
    @callback null, addresses[0], (if addresses[0].indexOf(":") >= 0 then 6 else 4)
  return

# Easy DNS A/AAAA look up
# lookup(hostname, [options,] callback)

# Parse arguments
onlookupservice = (err, host, service) ->
  return @callback(errnoException(err, "getnameinfo", @host))  if err
  @callback null, host, service
  return

# lookupService(address, port, callback)
onresolve = (err, result) ->
  if err
    @callback errnoException(err, @bindingName, @hostname)
  else
    @callback null, result
  return
resolver = (bindingName) ->
  binding = cares[bindingName]
  query = (name, callback) ->
    unless util.isString(name)
      throw new Error("Name must be a string")
    else throw new Error("Callback must be a function")  unless util.isFunction(callback)
    callback = makeAsync(callback)
    req =
      bindingName: bindingName
      callback: callback
      hostname: name
      oncomplete: onresolve

    err = binding(req, name)
    throw errnoException(err, bindingName)  if err
    callback.immediately = true
    req
"use strict"
net = require("net")
util = require("util")
cares = process.binding("cares_wrap")
uv = process.binding("uv")
GetAddrInfoReqWrap = cares.GetAddrInfoReqWrap
GetNameInfoReqWrap = cares.GetNameInfoReqWrap
isIp = net.isIP
exports.lookup = lookup = (hostname, options, callback) ->
  hints = 0
  family = -1
  if hostname and typeof hostname isnt "string"
    throw TypeError("invalid arguments: hostname must be a string or falsey")
  else if typeof options is "function"
    callback = options
    family = 0
  else if typeof callback isnt "function"
    throw TypeError("invalid arguments: callback must be passed")
  else if util.isObject(options)
    hints = options.hints >>> 0
    family = options.family >>> 0
    throw new TypeError("invalid argument: hints must use valid flags")  if hints isnt 0 and hints isnt exports.ADDRCONFIG and hints isnt exports.V4MAPPED and hints isnt (exports.ADDRCONFIG | exports.V4MAPPED)
  else
    family = options >>> 0
  throw new TypeError("invalid argument: family must be 4 or 6")  if family isnt 0 and family isnt 4 and family isnt 6
  callback = makeAsync(callback)
  unless hostname
    callback null, null, (if family is 6 then 6 else 4)
    return {}
  matchedFamily = net.isIP(hostname)
  if matchedFamily
    callback null, hostname, matchedFamily
    return {}
  req = new GetAddrInfoReqWrap()
  req.callback = callback
  req.family = family
  req.hostname = hostname
  req.oncomplete = onlookup
  err = cares.getaddrinfo(req, hostname, family, hints)
  if err
    callback errnoException(err, "getaddrinfo", hostname)
    return {}
  callback.immediately = true
  req

exports.lookupService = (host, port, callback) ->
  throw new Error("invalid arguments")  if arguments.length isnt 3
  throw new TypeError("host needs to be a valid IP address")  if cares.isIP(host) is 0
  callback = makeAsync(callback)
  req = new GetNameInfoReqWrap()
  req.callback = callback
  req.host = host
  req.port = port
  req.oncomplete = onlookupservice
  err = cares.getnameinfo(req, host, port)
  throw errnoException(err, "getnameinfo", host)  if err
  callback.immediately = true
  req

resolveMap = {}
exports.resolve4 = resolveMap.A = resolver("queryA")
exports.resolve6 = resolveMap.AAAA = resolver("queryAaaa")
exports.resolveCname = resolveMap.CNAME = resolver("queryCname")
exports.resolveMx = resolveMap.MX = resolver("queryMx")
exports.resolveNs = resolveMap.NS = resolver("queryNs")
exports.resolveTxt = resolveMap.TXT = resolver("queryTxt")
exports.resolveSrv = resolveMap.SRV = resolver("querySrv")
exports.resolveNaptr = resolveMap.NAPTR = resolver("queryNaptr")
exports.resolveSoa = resolveMap.SOA = resolver("querySoa")
exports.reverse = resolveMap.PTR = resolver("getHostByAddr")
exports.resolve = (hostname, type_, callback_) ->
  resolver = undefined
  callback = undefined
  if util.isString(type_)
    resolver = resolveMap[type_]
    callback = callback_
  else if util.isFunction(type_)
    resolver = exports.resolve4
    callback = type_
  else
    throw new Error("Type must be a string")
  if util.isFunction(resolver)
    resolver hostname, callback
  else
    throw new Error("Unknown type \"" + type_ + "\"")
  return

exports.getServers = ->
  cares.getServers()

exports.setServers = (servers) ->
  
  # cache the original servers because in the event of an error setting the
  # servers cares won't have any servers available for resolution
  orig = cares.getServers()
  newSet = []
  servers.forEach (serv) ->
    ver = isIp(serv)
    if ver
      return newSet.push([
        ver
        serv
      ])
    match = serv.match(/\[(.*)\](:\d+)?/)
    
    # we have an IPv6 in brackets
    if match
      ver = isIp(match[1])
      if ver
        return newSet.push([
          ver
          match[1]
        ])
    s = serv.split(/:\d+$/)[0]
    ver = isIp(s)
    if ver
      return newSet.push([
        ver
        s
      ])
    throw new Error("IP address is not properly formatted: " + serv)return

  r = cares.setServers(newSet)
  if r
    
    # reset the servers to the old servers, because ares probably unset them
    cares.setServers orig.join(",")
    err = cares.strerror(r)
    throw new Error("c-ares failed to set servers: \"" + err + "\" [" + servers + "]")
  return


# uv_getaddrinfo flags
exports.ADDRCONFIG = cares.AI_ADDRCONFIG
exports.V4MAPPED = cares.AI_V4MAPPED

# ERROR CODES
exports.NODATA = "ENODATA"
exports.FORMERR = "EFORMERR"
exports.SERVFAIL = "ESERVFAIL"
exports.NOTFOUND = "ENOTFOUND"
exports.NOTIMP = "ENOTIMP"
exports.REFUSED = "EREFUSED"
exports.BADQUERY = "EBADQUERY"
exports.ADNAME = "EADNAME"
exports.BADFAMILY = "EBADFAMILY"
exports.BADRESP = "EBADRESP"
exports.CONNREFUSED = "ECONNREFUSED"
exports.TIMEOUT = "ETIMEOUT"
exports.EOF = "EOF"
exports.FILE = "EFILE"
exports.NOMEM = "ENOMEM"
exports.DESTRUCTION = "EDESTRUCTION"
exports.BADSTR = "EBADSTR"
exports.BADFLAGS = "EBADFLAGS"
exports.NONAME = "ENONAME"
exports.BADHINTS = "EBADHINTS"
exports.NOTINITIALIZED = "ENOTINITIALIZED"
exports.LOADIPHLPAPI = "ELOADIPHLPAPI"
exports.ADDRGETNETWORKPARAMS = "EADDRGETNETWORKPARAMS"
exports.CANCELLED = "ECANCELLED"
