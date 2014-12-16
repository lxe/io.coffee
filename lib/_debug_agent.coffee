
# Do not let `agent.listen()` request listening from cluster master

# Just to spin-off events
# TODO(indutny): Figure out why node.cc isn't doing this

# We don't care about it, but it prevents loop from cleaning up gently
# NOTE: removeAllListeners won't work, as it doesn't call `removeListener`

# Not used now, but anyway
Agent = ->
  net.Server.call this, @onConnection
  @first = true
  @binding = process._debugAPI
  self = this
  @binding.onmessage = (msg) ->
    self.clients.forEach (client) ->
      client.send {}, msg
      return

    return

  @clients = []
  assert @binding, "Debugger agent running without bindings!"
  return
Client = (agent, socket) ->
  Transform.call this
  @_readableState.objectMode = true
  @agent = agent
  @binding = @agent.binding
  @socket = socket
  
  # Parse incoming data
  @state = "headers"
  @headers = {}
  @buffer = ""
  socket.pipe this
  @on "data", @onCommand
  self = this
  @socket.on "close", ->
    self.destroy()
    return

  return

# Not enough data

# Match:
#   Header-name: header-value\r\n
Command = (headers, body) ->
  @headers = headers
  @body = body
  return
"use strict"
assert = require("assert")
net = require("net")
util = require("util")
Buffer = require("buffer").Buffer
Transform = require("stream").Transform
exports.start = start = ->
  agent = new Agent()
  cluster = require("cluster")
  cluster.isWorker = false
  cluster.isMaster = true
  agent.on "error", (err) ->
    process._rawDebug err.stack or err
    return

  agent.listen process._debugAPI.port, ->
    addr = @address()
    process._rawDebug "Debugger listening on port %d", addr.port
    process._debugAPI.notifyListen()
    return

  setImmediate ->

  process._debugAPI.onclose = ->
    process.listeners("SIGWINCH").forEach (fn) ->
      process.removeListener "SIGWINCH", fn
      return

    agent.close()
    return

  agent

util.inherits Agent, net.Server
Agent::onConnection = onConnection = (socket) ->
  c = new Client(this, socket)
  c.start()
  @clients.push c
  self = this
  c.once "close", ->
    index = self.clients.indexOf(c)
    assert index isnt -1
    self.clients.splice index, 1
    return

  return

Agent::notifyWait = notifyWait = ->
  @binding.notifyWait()  if @first
  @first = false
  return

util.inherits Client, Transform
Client::destroy = destroy = (msg) ->
  @socket.destroy()
  @emit "close"
  return

Client::_transform = _transform = (data, enc, cb) ->
  cb()
  @buffer += data
  loop
    if @state is "headers"
      break  unless /\r\n/.test(@buffer)
      if /^\r\n/.test(@buffer)
        @buffer = @buffer.slice(2)
        @state = "body"
        continue
      match = @buffer.match(/^([^:\s\r\n]+)\s*:\s*([^\s\r\n]+)\r\n/)
      return @destroy("Expected header, but failed to parse it")  unless match
      @headers[match[1].toLowerCase()] = match[2]
      @buffer = @buffer.slice(match[0].length)
    else
      len = @headers["content-length"]
      return @destroy("Expected content-length")  if len is `undefined`
      len = len | 0
      break  if Buffer.byteLength(@buffer) < len
      @push new Command(@headers, @buffer.slice(0, len))
      @state = "headers"
      @buffer = @buffer.slice(len)
      @headers = {}
  return

Client::send = send = (headers, data) ->
  data = ""  unless data
  out = []
  Object.keys(headers).forEach (key) ->
    out.push key + ": " + headers[key]
    return

  out.push "Content-Length: " + Buffer.byteLength(data), ""
  @socket.cork()
  @socket.write out.join("\r\n") + "\r\n"
  @socket.write data  if data.length > 0
  @socket.uncork()
  return

Client::start = start = ->
  @send
    Type: "connect"
    "V8-Version": process.versions.v8
    "Protocol-Version": 1
    "Embedding-Host": "node " + process.version

  return

Client::onCommand = onCommand = (cmd) ->
  @binding.sendCommand cmd.body
  @agent.notifyWait()
  return
