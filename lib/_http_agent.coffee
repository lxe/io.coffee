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

# New Agent code.

# The largest departure from the previous implementation is that
# an Agent instance holds connections for a variable number of host:ports.
# Surprisingly, this is still API compatible as far as third parties are
# concerned. The only code that really notices the difference is the
# request object.

# Another departure is that all code related to HTTP parsing is in
# ClientRequest.onSocket(). The Agent is now *strictly*
# concerned with managing a connection pool.
Agent = (options) ->
  return new Agent(options)  unless this instanceof Agent
  EventEmitter.call this
  self = this
  self.defaultPort = 80
  self.protocol = "http:"
  self.options = util._extend({}, options)
  
  # don't confuse net and make it think that we're connecting to a pipe
  self.options.path = null
  self.requests = {}
  self.sockets = {}
  self.freeSockets = {}
  self.keepAliveMsecs = self.options.keepAliveMsecs or 1000
  self.keepAlive = self.options.keepAlive or false
  self.maxSockets = self.options.maxSockets or Agent.defaultMaxSockets
  self.maxFreeSockets = self.options.maxFreeSockets or 256
  self.on "free", (socket, options) ->
    name = self.getName(options)
    debug "agent.on(free)", name
    if not socket.destroyed and self.requests[name] and self.requests[name].length
      self.requests[name].shift().onSocket socket
      
      # don't leak
      delete self.requests[name]  if self.requests[name].length is 0
    else
      
      # If there are no pending requests, then put it in
      # the freeSockets pool, but only if we're allowed to do so.
      req = socket._httpMessage
      if req and req.shouldKeepAlive and not socket.destroyed and self.options.keepAlive
        freeSockets = self.freeSockets[name]
        freeLen = (if freeSockets then freeSockets.length else 0)
        count = freeLen
        count += self.sockets[name].length  if self.sockets[name]
        if count >= self.maxSockets or freeLen >= self.maxFreeSockets
          self.removeSocket socket, options
          socket.destroy()
        else
          freeSockets = freeSockets or []
          self.freeSockets[name] = freeSockets
          socket.setKeepAlive true, self.keepAliveMsecs
          socket.unref()
          socket._httpMessage = null
          self.removeSocket socket, options
          freeSockets.push socket
      else
        self.removeSocket socket, options
        socket.destroy()
    return

  return
"use strict"
net = require("net")
util = require("util")
EventEmitter = require("events").EventEmitter
debug = util.debuglog("http")
util.inherits Agent, EventEmitter
exports.Agent = Agent
Agent.defaultMaxSockets = Infinity
Agent::createConnection = net.createConnection

# Get the key for a given set of request options
Agent::getName = (options) ->
  name = ""
  if options.host
    name += options.host
  else
    name += "localhost"
  name += ":"
  name += options.port  if options.port
  name += ":"
  name += options.localAddress  if options.localAddress
  name += ":"
  name

Agent::addRequest = (req, options) ->
  
  # Legacy API: addRequest(req, host, port, path)
  if typeof options is "string"
    options =
      host: options
      port: arguments[2]
      path: arguments[3]
  name = @getName(options)
  @sockets[name] = []  unless @sockets[name]
  freeLen = (if @freeSockets[name] then @freeSockets[name].length else 0)
  sockLen = freeLen + @sockets[name].length
  if freeLen
    
    # we have a free socket, so use that.
    socket = @freeSockets[name].shift()
    debug "have free socket"
    
    # don't leak
    delete @freeSockets[name]  unless @freeSockets[name].length
    socket.ref()
    req.onSocket socket
    @sockets[name].push socket
  else if sockLen < @maxSockets
    debug "call onSocket", sockLen, freeLen
    
    # If we are under maxSockets create a new one.
    req.onSocket @createSocket(req, options)
  else
    debug "wait for socket"
    
    # We are over limit so we'll add it to the queue.
    @requests[name] = []  unless @requests[name]
    @requests[name].push req
  return

Agent::createSocket = (req, options) ->
  onFree = ->
    self.emit "free", s, options
    return
  onClose = (err) ->
    debug "CLIENT socket onClose"
    
    # This is the only place where sockets get removed from the Agent.
    # If you want to remove a socket from the pool, just close it.
    # All socket errors end in a close event anyway.
    self.removeSocket s, options
    return
  onRemove = ->
    
    # We need this function for cases like HTTP 'upgrade'
    # (defined by WebSockets) where we need to remove a socket from the
    # pool because it'll be locked up indefinitely
    debug "CLIENT socket onRemove"
    self.removeSocket s, options
    s.removeListener "close", onClose
    s.removeListener "free", onFree
    s.removeListener "agentRemove", onRemove
    return
  self = this
  options = util._extend({}, options)
  options = util._extend(options, self.options)
  options.servername = options.host
  if req
    hostHeader = req.getHeader("host")
    options.servername = hostHeader.replace(/:.*$/, "")  if hostHeader
  name = self.getName(options)
  debug "createConnection", name, options
  options.encoding = null
  s = self.createConnection(options)
  self.sockets[name] = []  unless self.sockets[name]
  @sockets[name].push s
  debug "sockets", name, @sockets[name].length
  s.on "free", onFree
  s.on "close", onClose
  s.on "agentRemove", onRemove
  s

Agent::removeSocket = (s, options) ->
  name = @getName(options)
  debug "removeSocket", name, "destroyed:", s.destroyed
  sets = [@sockets]
  
  # If the socket was destroyed, remove it from the free buffers too.
  sets.push @freeSockets  if s.destroyed
  sk = 0

  while sk < sets.length
    sockets = sets[sk]
    if sockets[name]
      index = sockets[name].indexOf(s)
      if index isnt -1
        sockets[name].splice index, 1
        
        # Don't leak
        delete sockets[name]  if sockets[name].length is 0
    sk++
  if @requests[name] and @requests[name].length
    debug "removeSocket, have a request, make a socket"
    req = @requests[name][0]
    
    # If we have pending requests and a socket gets closed make a new one
    @createSocket(req, options).emit "free"
  return

Agent::destroy = ->
  sets = [
    this.freeSockets
    this.sockets
  ]
  s = 0

  while s < sets.length
    set = sets[s]
    keys = Object.keys(set)
    v = 0

    while v < keys.length
      setName = set[keys[v]]
      n = 0

      while n < setName.length
        setName[n].destroy()
        n++
      v++
    s++
  return

exports.globalAgent = new Agent()
