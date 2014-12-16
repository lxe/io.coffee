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

# lazily loaded
lookup = (address, family, callback) ->
  dns = require("dns")  unless dns
  dns.lookup address, family, callback
lookup4 = (address, callback) ->
  lookup address or "0.0.0.0", 4, callback
lookup6 = (address, callback) ->
  lookup address or "::0", 6, callback
newHandle = (type) ->
  if type is "udp4"
    handle = new UDP
    handle.lookup = lookup4
    return handle
  if type is "udp6"
    handle = new UDP
    handle.lookup = lookup6
    handle.bind = handle.bind6
    handle.send = handle.send6
    return handle
  throw new Error("unix_dgram sockets are not supported any more.")  if type is "unix_dgram"
  throw new Error("Bad socket type specified. Valid types are: udp4, udp6")return

# Opening an existing fd is not supported for UDP handles.
Socket = (type, listener) ->
  events.EventEmitter.call this
  if typeof type is "object"
    options = type
    type = options.type
  handle = newHandle(type)
  handle.owner = this
  @_handle = handle
  @_receiving = false
  @_bindState = BIND_STATE_UNBOUND
  @type = type
  @fd = null # compatibility hack
  
  # If true - UV_UDP_REUSEADDR flag will be set
  @_reuseAddr = options and options.reuseAddr
  @on "message", listener  if util.isFunction(listener)
  return
startListening = (socket) ->
  socket._handle.onmessage = onMessage
  
  # Todo: handle errors
  socket._handle.recvStart()
  socket._receiving = true
  socket._bindState = BIND_STATE_BOUND
  socket.fd = -42 # compatibility hack
  socket.emit "listening"
  return
replaceHandle = (self, newHandle) ->
  
  # Set up the handle that we got from master.
  newHandle.lookup = self._handle.lookup
  newHandle.bind = self._handle.bind
  newHandle.send = self._handle.send
  newHandle.owner = self
  
  # Replace the existing handle by the handle we got from master.
  self._handle.close()
  self._handle = newHandle
  return
#, address, callback

# resolve address first

# handle has been closed in the mean time.
# handle has been closed in the mean time

# Todo: close?

# thin wrapper around `send`, here for compatibility with dgram_legacy.js

# Sending a zero-length datagram is kind of pointless but it _is_
# allowed, hence check that length >= 0 rather than > 0.

# Normalize callback so it's either a function or undefined but not anything
# else.

# If the socket hasn't been bound yet, push the outbound packet onto the
# send queue and send after binding is complete.

# If the send queue hasn't been initialized yet, do it, and install an
# event handler that flushes the send queue after binding is done.

# Flush the send queue.
# Keep reference alive.

# don't emit as error, dgram_legacy.js compatibility
afterSend = (err) ->
  @callback (if err then errnoException(err, "send") else null), @length
  return
# 0.4 compatibility
# error message from dgram_legacy.js
# compatibility hack
onMessage = (nread, handle, buf, rinfo) ->
  self = handle.owner
  return self.emit("error", errnoException(nread, "recvmsg"))  if nread < 0
  rinfo.size = buf.length # compatibility
  self.emit "message", buf, rinfo
  return
"use strict"
assert = require("assert")
util = require("util")
events = require("events")
constants = require("constants")
UDP = process.binding("udp_wrap").UDP
SendWrap = process.binding("udp_wrap").SendWrap
BIND_STATE_UNBOUND = 0
BIND_STATE_BINDING = 1
BIND_STATE_BOUND = 2
cluster = null
dns = null
errnoException = util._errnoException
exports._createSocketHandle = (address, port, addressType, fd) ->
  assert not util.isNumber(fd) or fd < 0
  handle = newHandle(addressType)
  if port or address
    err = handle.bind(address, port or 0, 0)
    if err
      handle.close()
      return err
  handle

util.inherits Socket, events.EventEmitter
exports.Socket = Socket
exports.createSocket = (type, listener) ->
  new Socket(type, listener)

Socket::bind = (port) ->
  self = this
  self._healthCheck()
  throw new Error("Socket is already bound")  unless @_bindState is BIND_STATE_UNBOUND
  @_bindState = BIND_STATE_BINDING
  self.once "listening", arguments[arguments.length - 1]  if util.isFunction(arguments[arguments.length - 1])
  UDP = process.binding("udp_wrap").UDP
  if port instanceof UDP
    replaceHandle self, port
    startListening self
    return
  address = undefined
  exclusive = undefined
  if util.isObject(port)
    address = port.address or ""
    exclusive = !!port.exclusive
    port = port.port
  else
    address = (if util.isFunction(arguments[1]) then "" else arguments[1])
    exclusive = false
  self._handle.lookup address, (err, ip) ->
    if err
      self._bindState = BIND_STATE_UNBOUND
      self.emit "error", err
      return
    cluster = require("cluster")  unless cluster
    if cluster.isWorker and not exclusive
      cluster._getServer self, ip, port, self.type, -1, (err, handle) ->
        if err
          self.emit "error", errnoException(err, "bind")
          self._bindState = BIND_STATE_UNBOUND
          return
        return handle.close()  unless self._handle
        replaceHandle self, handle
        startListening self
        return

    else
      return  unless self._handle
      flags = 0
      flags |= constants.UV_UDP_REUSEADDR  if self._reuseAddr
      err = self._handle.bind(ip, port or 0, flags)
      if err
        self.emit "error", errnoException(err, "bind")
        self._bindState = BIND_STATE_UNBOUND
        return
      startListening self
    return

  return

Socket::sendto = (buffer, offset, length, port, address, callback) ->
  throw new Error("send takes offset and length as args 2 and 3")  if not util.isNumber(offset) or not util.isNumber(length)
  throw new Error(@type + " sockets must send to port, address")  unless util.isString(address)
  @send buffer, offset, length, port, address, callback
  return

Socket::send = (buffer, offset, length, port, address, callback) ->
  self = this
  buffer = new Buffer(buffer)  if util.isString(buffer)
  throw new TypeError("First argument must be a buffer or string.")  unless util.isBuffer(buffer)
  offset = offset | 0
  throw new RangeError("Offset should be >= 0")  if offset < 0
  throw new RangeError("Offset into buffer too large")  if (length is 0 and offset > buffer.length) or (length > 0 and offset >= buffer.length)
  length = length | 0
  throw new RangeError("Length should be >= 0")  if length < 0
  throw new RangeError("Offset + length beyond buffer length")  if offset + length > buffer.length
  port = port | 0
  throw new RangeError("Port should be > 0 and < 65536")  if port <= 0 or port > 65535
  callback = `undefined`  unless util.isFunction(callback)
  self._healthCheck()
  self.bind 0, null  if self._bindState is BIND_STATE_UNBOUND
  unless self._bindState is BIND_STATE_BOUND
    unless self._sendQueue
      self._sendQueue = []
      self.once "listening", ->
        i = 0

        while i < self._sendQueue.length
          self.send.apply self, self._sendQueue[i]
          i++
        self._sendQueue = `undefined`
        return

    self._sendQueue.push [
      buffer
      offset
      length
      port
      address
      callback
    ]
    return
  self._handle.lookup address, (ex, ip) ->
    if ex
      callback ex  if callback
      self.emit "error", ex
    else if self._handle
      req = new SendWrap()
      req.buffer = buffer
      req.length = length
      if callback
        req.callback = callback
        req.oncomplete = afterSend
      err = self._handle.send(req, buffer, offset, length, port, ip, !!callback)
      if err and callback
        process.nextTick ->
          callback errnoException(err, "send")
          return

    return

  return

Socket::close = ->
  @_healthCheck()
  @_stopReceiving()
  @_handle.close()
  @_handle = null
  @emit "close"
  return

Socket::address = ->
  @_healthCheck()
  out = {}
  err = @_handle.getsockname(out)
  throw errnoException(err, "getsockname")  if err
  out

Socket::setBroadcast = (arg) ->
  err = @_handle.setBroadcast((if arg then 1 else 0))
  throw errnoException(err, "setBroadcast")  if err
  return

Socket::setTTL = (arg) ->
  throw new TypeError("Argument must be a number")  unless util.isNumber(arg)
  err = @_handle.setTTL(arg)
  throw errnoException(err, "setTTL")  if err
  arg

Socket::setMulticastTTL = (arg) ->
  throw new TypeError("Argument must be a number")  unless util.isNumber(arg)
  err = @_handle.setMulticastTTL(arg)
  throw errnoException(err, "setMulticastTTL")  if err
  arg

Socket::setMulticastLoopback = (arg) ->
  err = @_handle.setMulticastLoopback((if arg then 1 else 0))
  throw errnoException(err, "setMulticastLoopback")  if err
  arg

Socket::addMembership = (multicastAddress, interfaceAddress) ->
  @_healthCheck()
  throw new Error("multicast address must be specified")  unless multicastAddress
  err = @_handle.addMembership(multicastAddress, interfaceAddress)
  throw errnoException(err, "addMembership")  if err
  return

Socket::dropMembership = (multicastAddress, interfaceAddress) ->
  @_healthCheck()
  throw new Error("multicast address must be specified")  unless multicastAddress
  err = @_handle.dropMembership(multicastAddress, interfaceAddress)
  throw errnoException(err, "dropMembership")  if err
  return

Socket::_healthCheck = ->
  throw new Error("Not running")  unless @_handle
  return

Socket::_stopReceiving = ->
  return  unless @_receiving
  @_handle.recvStop()
  @_receiving = false
  @fd = null
  return

Socket::ref = ->
  @_handle.ref()  if @_handle
  return

Socket::unref = ->
  @_handle.unref()  if @_handle
  return
