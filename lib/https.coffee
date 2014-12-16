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
Server = (opts, requestListener) ->
  return new Server(opts, requestListener)  unless this instanceof Server
  if process.features.tls_npn and not opts.NPNProtocols
    opts.NPNProtocols = [
      "http/1.1"
      "http/1.0"
    ]
  tls.Server.call this, opts, http._connectionListener
  @httpAllowHalfOpen = false
  @addListener "request", requestListener  if requestListener
  @addListener "clientError", (err, conn) ->
    conn.destroy()
    return

  @timeout = 2 * 60 * 1000
  return

# HTTPS agents.
createConnection = (port, host, options) ->
  if util.isObject(port)
    options = port
  else if util.isObject(host)
    options = host
  else if util.isObject(options)
    options = options
  else
    options = {}
  options.port = port  if util.isNumber(port)
  options.host = host  if util.isString(host)
  debug "createConnection", options
  tls.connect options
Agent = (options) ->
  http.Agent.call this, options
  @defaultPort = 443
  @protocol = "https:"
  return
"use strict"
tls = require("tls")
url = require("url")
http = require("http")
util = require("util")
inherits = require("util").inherits
debug = util.debuglog("https")
inherits Server, tls.Server
exports.Server = Server
Server::setTimeout = http.Server::setTimeout
exports.createServer = (opts, requestListener) ->
  new Server(opts, requestListener)

inherits Agent, http.Agent
Agent::createConnection = createConnection
Agent::getName = (options) ->
  name = http.Agent::getName.call(this, options)
  name += ":"
  name += options.ca  if options.ca
  name += ":"
  name += options.cert  if options.cert
  name += ":"
  name += options.ciphers  if options.ciphers
  name += ":"
  name += options.key  if options.key
  name += ":"
  name += options.pfx  if options.pfx
  name += ":"
  name += options.rejectUnauthorized  unless util.isUndefined(options.rejectUnauthorized)
  name

globalAgent = new Agent()
exports.globalAgent = globalAgent
exports.Agent = Agent
exports.request = (options, cb) ->
  if util.isString(options)
    options = url.parse(options)
  else
    options = util._extend({}, options)
  options._defaultAgent = globalAgent
  http.request options, cb

exports.get = (options, cb) ->
  req = exports.request(options, cb)
  req.end()
  req
