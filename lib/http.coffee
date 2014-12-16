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

# Legacy Interface
Client = (port, host) ->
  return new Client(port, host)  unless this instanceof Client
  EventEmitter.call this
  host = host or "localhost"
  port = port or 80
  @host = host
  @port = port
  @agent = new Agent(
    host: host
    port: port
    maxSockets: 1
  )
  return
"use strict"
util = require("util")
EventEmitter = require("events").EventEmitter
exports.IncomingMessage = require("_http_incoming").IncomingMessage
common = require("_http_common")
exports.METHODS = util._extend([], common.methods).sort()
exports.OutgoingMessage = require("_http_outgoing").OutgoingMessage
server = require("_http_server")
exports.ServerResponse = server.ServerResponse
exports.STATUS_CODES = server.STATUS_CODES
agent = require("_http_agent")
Agent = exports.Agent = agent.Agent
exports.globalAgent = agent.globalAgent
client = require("_http_client")
ClientRequest = exports.ClientRequest = client.ClientRequest
exports.request = (options, cb) ->
  new ClientRequest(options, cb)

exports.get = (options, cb) ->
  req = exports.request(options, cb)
  req.end()
  req

exports._connectionListener = server._connectionListener
Server = exports.Server = server.Server
exports.createServer = (requestListener) ->
  new Server(requestListener)

util.inherits Client, EventEmitter
Client::request = (method, path, headers) ->
  self = this
  options = {}
  options.host = self.host
  options.port = self.port
  if method[0] is "/"
    headers = path
    path = method
    method = "GET"
  options.method = method
  options.path = path
  options.headers = headers
  options.agent = self.agent
  c = new ClientRequest(options)
  c.on "error", (e) ->
    self.emit "error", e
    return

  
  # The old Client interface emitted 'end' on socket end.
  # This doesn't map to how we want things to operate in the future
  # but it will get removed when we remove this legacy interface.
  c.on "socket", (s) ->
    s.on "end", ->
      if self._decoder
        ret = self._decoder.end()
        self.emit "data", ret  if ret
      self.emit "end"
      return

    return

  c

exports.Client = util.deprecate(Client, "http.Client will be removed soon. Do not use it.")
exports.createClient = util.deprecate((port, host) ->
  new Client(port, host)
, "http.createClient is deprecated. Use `http.request` instead.")
