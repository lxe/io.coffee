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

# Setup input/output streams

#
# Parser/Serializer for V8 debugger protocol
# http://code.google.com/p/v8/wiki/DebuggerProtocol
#
# Usage:
#    p = new Protocol();
#
#    p.onResponse = function(res) {
#      // do stuff with response from V8
#    };
#
#    socket.setEncoding('utf8');
#    socket.on('data', function(s) {
#      // Pass strings into the protocol
#      p.execute(s);
#    });
#
#
Protocol = ->
  @_newRes()
  return

# pass thru

# JSON parse body?

# Done!
Client = ->
  net.Stream.call this
  protocol = @protocol = new Protocol(this)
  @_reqCallbacks = []
  socket = this
  @currentFrame = NO_FRAME
  @currentSourceLine = -1
  @handles = {}
  @scripts = {}
  @breakpoints = []
  
  # Note that 'Protocol' requires strings instead of Buffers.
  socket.setEncoding "utf8"
  socket.on "data", (d) ->
    protocol.execute d
    return

  protocol.onResponse = @_onResponse.bind(this)
  return

# Request a list of scripts for our own storage.

# ???

# This event is not used anywhere right now, perhaps somewhere in the
# future?

# TODO: We have a cache of handle's we've already seen in this.handles
# This can be used if we're careful.

# This is like reqEval, except it will look up the expression in each of the
# scopes associated with the current frame.

# Only need to eval in global scope.

# Otherwise we need to get the current frame to see which scopes it has.

# ??

# Finds the first scope in the array in which the expression evals.

# Just eval in global scope.

# reqBacktrace(cb)
# TODO: from, to, bottom

# reqSetExceptionBreak(type, cb)
# TODO: from, to, bottom

# Returns an array of objects like this:
#
#   { handle: 11,
#     type: 'script',
#     name: 'node.js',
#     id: 14,
#     lineOffset: 0,
#     columnOffset: 0,
#     lineCount: 562,
#     sourceStart: '(function(process) {\n\n  ',
#     sourceLength: 15939,
#     scriptType: 2,
#     compilationType: 0,
#     context: { ref: 10 },
#     text: 'node.js (lines: 562)' }
#

# client.next(1, cb);

# The handle looks something like this:
# { handle: 8,
#   type: 'object',
#   className: 'Object',
#   constructorFunction: { ref: 9 },
#   protoObject: { ref: 4 },
#   prototypeObject: { ref: 2 },
#   properties: [ { name: 'hello', propertyType: 1, ref: 10 } ],
#   text: '#<an Object>' }

# For now ignore the className and constructor and prototype.
# TJ's method of object inspection would probably be good for this:
# https://groups.google.com/forum/?pli=1#!topic/nodejs-dev/4gkWBOimiOg

# Skip the 'length' property.

# looks like this:
# { type: 'frame',
#   index: 0,
#   receiver: { ref: 1 },
#   func: { ref: 0 },
#   script: { ref: 7 },
#   constructCall: false,
#   atReturn: false,
#   debuggerFrame: false,
#   arguments: [],
#   locals: [],
#   position: 160,
#   line: 7,
#   column: 2,
#   sourceLineText: '  debugger;',
#   scopes: [ { type: 1, index: 0 }, { type: 0, index: 1 } ],
#   text: '#00 blah() /home/ryan/projects/node/test-debug.js l...' }
SourceUnderline = (sourceText, position, repl) ->
  return ""  unless sourceText
  head = sourceText.slice(0, position)
  tail = sourceText.slice(position)
  
  # Colourize char if stdout supports colours
  tail = tail.replace(/(.+?)([^\w]|$)/, "\u001b[32m$1\u001b[39m$2")  if repl.useColors
  
  # Return source line with coloured char at `position`
  [
    head
    tail
  ].join ""
SourceInfo = (body) ->
  result = (if body.exception then "exception in " else "break in ")
  if body.script
    if body.script.name
      name = body.script.name
      dir = path.resolve() + "/"
      
      # Change path to relative, if possible
      name = name.slice(dir.length)  if name.indexOf(dir) is 0
      result += name
    else
      result += "[unnamed]"
  result += ":"
  result += body.sourceLine + 1
  result += "\n" + body.exception.text  if body.exception
  result

# This class is the repl-enabled debugger interface which is invoked on
# "node debug"
Interface = (stdin, stdout, args) ->
  
  # Two eval modes are available: controlEval and debugEval
  # But controlEval is used by default
  
  # Emulate Ctrl+C if we're emulating terminal
  
  # Do not print useless warning
  
  # Kill child process when main process dies
  
  # Handle all possible exits
  defineProperty = (key, protoKey) ->
    
    # Check arity
    fn = proto[protoKey].bind(self)
    if proto[protoKey].length is 0
      Object.defineProperty self.repl.context, key,
        get: fn
        enumerable: true
        configurable: false

    else
      self.repl.context[key] = fn
    return
  self = this
  @stdin = stdin
  @stdout = stdout
  @args = args
  opts =
    prompt: "debug> "
    input: @stdin
    output: @stdout
    eval: @controlEval.bind(this)
    useGlobal: false
    ignoreUndefined: true

  if parseInt(process.env["NODE_NO_READLINE"], 10)
    opts.terminal = false
  else if parseInt(process.env["NODE_FORCE_READLINE"], 10)
    opts.terminal = true
    unless @stdout.isTTY
      process.on "SIGINT", ->
        self.repl.rli.emit "SIGINT"
        return

  opts.useColors = false  if parseInt(process.env["NODE_DISABLE_COLORS"], 10)
  @repl = repl.start(opts)
  repl._builtinLibs.splice repl._builtinLibs.indexOf("repl"), 1
  @repl.on "exit", ->
    process.exit 0
    return

  process.on "exit", @killChild.bind(this)
  process.once "SIGTERM", process.exit.bind(process, 0)
  process.once "SIGHUP", process.exit.bind(process, 0)
  proto = Interface::
  ignored = [
    "pause"
    "resume"
    "exitRepl"
    "handleBreak"
    "requireConnection"
    "killChild"
    "trySpawn"
    "controlEval"
    "debugEval"
    "print"
    "childPrint"
    "clearline"
  ]
  shortcut =
    run: "r"
    cont: "c"
    next: "n"
    step: "s"
    out: "o"
    backtrace: "bt"
    setBreakpoint: "sb"
    clearBreakpoint: "cb"
    pause_: "pause"

  
  # Copy all prototype methods in repl context
  # Setup them as getters if possible
  for i of proto
    if Object::hasOwnProperty.call(proto, i) and ignored.indexOf(i) is -1
      defineProperty i, i
      defineProperty shortcut[i], i  if shortcut[i]
  @killed = false
  @waiting = null
  @paused = 0
  @context = @repl.context
  @history =
    debug: []
    control: []

  @breakpoints = []
  @_watchers = []
  
  # Run script automatically
  @pause()
  
  # XXX Need to figure out why we need this delay
  setTimeout (->
    self.run ->
      self.resume()
      return

    return
  ), 10
  return

# Stream control

# Clear current line

# Print text to output stream

# Format and print text from child process

# Errors formatting

# Debugger's `break` event handler

# Save execution context's data

# Print break data

# Show watchers' values

# And list source

# Internal method for checking connection state

# Evals

# Used for debugger's commands evaluation and execution

# Repeat last command if empty line are going to be evaluated

# Repl should not ask for next command
# if current one was asynchronous.

# Add a callback for asynchronous command
# (it will be automatically invoked by .resume() method

# Used for debugger's remote evaluation (`repl`) commands

# Repl asked for scope variables

# Request remote evaluation globally or in current frame

# Request object by handles (and it's sub-properties)

# Utils

# Adds spaces and prefix to number
# maxN is a maximum number we should have space for
leftPad = (n, prefix, maxN) ->
  s = n.toString()
  nchars = Math.max(2, String(maxN).length) + 1
  nspaces = nchars - s.length - 1
  i = 0

  while i < nspaces
    prefix += " "
    i++
  prefix + s
"use strict"
util = require("util")
path = require("path")
net = require("net")
vm = require("vm")
module = require("module")
repl = module.requireRepl()
inherits = util.inherits
assert = require("assert")
spawn = require("child_process").spawn
exports.start = (argv, stdin, stdout) ->
  argv or (argv = process.argv.slice(2))
  if argv.length < 1
    console.error "Usage: node debug script.js"
    process.exit 1
  stdin = stdin or process.stdin
  stdout = stdout or process.stdout
  args = ["--debug-brk"].concat(argv)
  interface_ = new Interface(stdin, stdout, args)
  stdin.resume()
  process.on "uncaughtException", (e) ->
    console.error "There was an internal error in Node's debugger. " + "Please report this bug."
    console.error e.message
    console.error e.stack
    interface_.child.kill()  if interface_.child
    process.exit 1
    return

  return

exports.port = 5858
exports.Protocol = Protocol
Protocol::_newRes = (raw) ->
  @res =
    raw: raw or ""
    headers: {}

  @state = "headers"
  @reqSeq = 1
  @execute ""
  return

Protocol::execute = (d) ->
  res = @res
  res.raw += d
  switch @state
    when "headers"
      endHeaderIndex = res.raw.indexOf("\r\n\r\n")
      break  if endHeaderIndex < 0
      rawHeader = res.raw.slice(0, endHeaderIndex)
      endHeaderByteIndex = Buffer.byteLength(rawHeader, "utf8")
      lines = rawHeader.split("\r\n")
      i = 0

      while i < lines.length
        kv = lines[i].split(/: +/)
        res.headers[kv[0]] = kv[1]
        i++
      @contentLength = +res.headers["Content-Length"]
      @bodyStartByteIndex = endHeaderByteIndex + 4
      @state = "body"
      len = Buffer.byteLength(res.raw, "utf8")
      break  if len - @bodyStartByteIndex < @contentLength
    when "body"
      resRawByteLength = Buffer.byteLength(res.raw, "utf8")
      if resRawByteLength - @bodyStartByteIndex >= @contentLength
        buf = new Buffer(resRawByteLength)
        buf.write res.raw, 0, resRawByteLength, "utf8"
        res.body = buf.slice(@bodyStartByteIndex, @bodyStartByteIndex + @contentLength).toString("utf8")
        res.body = (if res.body.length then JSON.parse(res.body) else {})
        @onResponse res
        @_newRes buf.slice(@bodyStartByteIndex + @contentLength).toString("utf8")
    else
      throw new Error("Unknown state")
  return

Protocol::serialize = (req) ->
  req.type = "request"
  req.seq = @reqSeq++
  json = JSON.stringify(req)
  "Content-Length: " + Buffer.byteLength(json, "utf8") + "\r\n\r\n" + json

NO_FRAME = -1
inherits Client, net.Stream
exports.Client = Client
Client::_addHandle = (desc) ->
  return  if not util.isObject(desc) or not util.isNumber(desc.handle)
  @handles[desc.handle] = desc
  @_addScript desc  if desc.type is "script"
  return

natives = process.binding("natives")
Client::_addScript = (desc) ->
  @scripts[desc.id] = desc
  desc.isNative = (desc.name.replace(".js", "") of natives) or desc.name is "node.js"  if desc.name
  return

Client::_removeScript = (desc) ->
  @scripts[desc.id] = `undefined`
  return

Client::_onResponse = (res) ->
  cb = undefined
  index = -1
  @_reqCallbacks.some (fn, i) ->
    if fn.request_seq is res.body.request_seq
      cb = fn
      index = i
      true

  self = this
  handled = false
  if res.headers.Type is "connect"
    self.reqScripts()
    self.emit "ready"
    handled = true
  else if res.body and res.body.event is "break"
    @emit "break", res.body
    handled = true
  else if res.body and res.body.event is "exception"
    @emit "exception", res.body
    handled = true
  else if res.body and res.body.event is "afterCompile"
    @_addHandle res.body.body.script
    handled = true
  else if res.body and res.body.event is "scriptCollected"
    @_removeScript res.body.body.script
    handled = true
  else handled = true  if res.body and res.body.event is "compileError"
  if cb
    @_reqCallbacks.splice index, 1
    handled = true
    err = res.success is false and (res.message or true) or res.body.success is false and (res.body.message or true)
    cb err, res.body and res.body.body or res.body, res
  @emit "unhandledResponse", res.body  unless handled
  return

Client::req = (req, cb) ->
  @write @protocol.serialize(req)
  cb.request_seq = req.seq
  @_reqCallbacks.push cb
  return

Client::reqVersion = (cb) ->
  cb = cb or ->

  @req
    command: "version"
  , (err, body, res) ->
    return cb(err)  if err
    cb null, res.body.body.V8Version, res.body.running
    return

  return

Client::reqLookup = (refs, cb) ->
  self = this
  req =
    command: "lookup"
    arguments:
      handles: refs

  cb = cb or ->

  @req req, (err, res) ->
    return cb(err)  if err
    for ref of res
      self._addHandle res[ref]  if util.isObject(res[ref])
    cb null, res
    return

  return

Client::reqScopes = (cb) ->
  self = this
  req =
    command: "scopes"
    arguments: {}

  cb = cb or ->

  @req req, (err, res) ->
    return cb(err)  if err
    refs = res.scopes.map((scope) ->
      scope.object.ref
    )
    self.reqLookup refs, (err, res) ->
      return cb(err)  if err
      globals = Object.keys(res).map((key) ->
        res[key].properties.map (prop) ->
          prop.name

      )
      cb null, globals.reverse()
      return

    return

  return

Client::reqEval = (expression, cb) ->
  self = this
  if @currentFrame is NO_FRAME
    @reqFrameEval expression, NO_FRAME, cb
    return
  cb = cb or ->

  @reqBacktrace (err, bt) ->
    return cb(null, {})  if err or not bt.frames
    frame = bt.frames[self.currentFrame]
    evalFrames = frame.scopes.map((s) ->
      return  unless s
      x = bt.frames[s.index]
      return  unless x
      x.index
    )
    self._reqFramesEval expression, evalFrames, cb
    return

  return

Client::_reqFramesEval = (expression, evalFrames, cb) ->
  if evalFrames.length is 0
    @reqFrameEval expression, NO_FRAME, cb
    return
  self = this
  i = evalFrames.shift()
  cb = cb or ->

  @reqFrameEval expression, i, (err, res) ->
    return cb(null, res)  unless err
    self._reqFramesEval expression, evalFrames, cb
    return

  return

Client::reqFrameEval = (expression, frame, cb) ->
  self = this
  req =
    command: "evaluate"
    arguments:
      expression: expression

  if frame is NO_FRAME
    req.arguments.global = true
  else
    req.arguments.frame = frame
  cb = cb or ->

  @req req, (err, res) ->
    self._addHandle res  unless err
    cb err, res
    return

  return

Client::reqBacktrace = (cb) ->
  @req
    command: "backtrace"
    arguments:
      inlineRefs: true
  , cb
  return

Client::reqSetExceptionBreak = (type, cb) ->
  @req
    command: "setexceptionbreak"
    arguments:
      type: type
      enabled: true
  , cb
  return

Client::reqScripts = (cb) ->
  self = this
  cb = cb or ->

  @req
    command: "scripts"
  , (err, res) ->
    return cb(err)  if err
    i = 0

    while i < res.length
      self._addHandle res[i]
      i++
    cb null
    return

  return

Client::reqContinue = (cb) ->
  @currentFrame = NO_FRAME
  @req
    command: "continue"
  , cb
  return

Client::listbreakpoints = (cb) ->
  @req
    command: "listbreakpoints"
  , cb
  return

Client::setBreakpoint = (req, cb) ->
  req =
    command: "setbreakpoint"
    arguments: req

  @req req, cb
  return

Client::clearBreakpoint = (req, cb) ->
  req =
    command: "clearbreakpoint"
    arguments: req

  @req req, cb
  return

Client::reqSource = (from, to, cb) ->
  req =
    command: "source"
    fromLine: from
    toLine: to

  @req req, cb
  return

Client::step = (action, count, cb) ->
  req =
    command: "continue"
    arguments:
      stepaction: action
      stepcount: count

  @currentFrame = NO_FRAME
  @req req, cb
  return

Client::mirrorObject = (handle, depth, cb) ->
  self = this
  val = undefined
  if handle.type is "object"
    propertyRefs = handle.properties.map((p) ->
      p.ref
    )
    cb = cb or ->

    @reqLookup propertyRefs, (err, res) ->
      waitForOthers = ->
        if --waiting is 0 and cb
          keyValues.forEach (kv) ->
            mirror[kv.name] = kv.value
            return

          cb null, mirror
        return
      if err
        console.error "problem with reqLookup"
        cb null, handle
        return
      mirror = undefined
      waiting = 1
      if handle.className is "Array"
        mirror = []
      else if handle.className is "Date"
        mirror = new Date(handle.value)
      else
        mirror = {}
      keyValues = []
      handle.properties.forEach (prop, i) ->
        value = res[prop.ref]
        mirrorValue = undefined
        if value
          mirrorValue = (if value.value then value.value else value.text)
        else
          mirrorValue = "[?]"
        return  if util.isArray(mirror) and not util.isNumber(prop.name)
        keyValues[i] =
          name: prop.name
          value: mirrorValue

        if value and value.handle and depth > 0
          waiting++
          self.mirrorObject value, depth - 1, (err, result) ->
            keyValues[i].value = result  unless err
            waitForOthers()
            return

        return

      waitForOthers()
      return

    return
  else if handle.type is "function"
    val = ->
  else if handle.type is "null"
    val = null
  else unless util.isUndefined(handle.value)
    val = handle.value
  else if handle.type is "undefined"
    val = `undefined`
  else
    val = handle
  process.nextTick ->
    cb null, val
    return

  return

Client::fullTrace = (cb) ->
  self = this
  cb = cb or ->

  @reqBacktrace (err, trace) ->
    return cb(err)  if err
    return cb(Error("No frames"))  if trace.totalFrames <= 0
    refs = []
    i = 0

    while i < trace.frames.length
      frame = trace.frames[i]
      refs.push frame.script.ref
      refs.push frame.func.ref
      refs.push frame.receiver.ref
      i++
    self.reqLookup refs, (err, res) ->
      return cb(err)  if err
      i = 0

      while i < trace.frames.length
        frame = trace.frames[i]
        frame.script = res[frame.script.ref]
        frame.func = res[frame.func.ref]
        frame.receiver = res[frame.receiver.ref]
        i++
      cb null, trace
      return

    return

  return

commands = [
  [
    "run (r)"
    "cont (c)"
    "next (n)"
    "step (s)"
    "out (o)"
    "backtrace (bt)"
    "setBreakpoint (sb)"
    "clearBreakpoint (cb)"
  ]
  [
    "watch"
    "unwatch"
    "watchers"
    "repl"
    "restart"
    "kill"
    "list"
    "scripts"
    "breakOnException"
    "breakpoints"
    "version"
  ]
]
helpMessage = "Commands: " + commands.map((group) ->
  group.join ", "
).join(",\n")
Interface::pause = ->
  return this  if @killed or @paused++ > 0
  @repl.rli.pause()
  @stdin.pause()
  this

Interface::resume = (silent) ->
  return this  if @killed or @paused is 0 or --@paused isnt 0
  @repl.rli.resume()
  @repl.displayPrompt()  if silent isnt true
  @stdin.resume()
  if @waiting
    @waiting()
    @waiting = null
  this

Interface::clearline = ->
  if @stdout.isTTY
    @stdout.cursorTo 0
    @stdout.clearLine 1
  else
    @stdout.write "\b"
  return

Interface::print = (text, oneline) ->
  return  if @killed
  @clearline()
  @stdout.write (if util.isString(text) then text else util.inspect(text))
  @stdout.write "\n"  if oneline isnt true
  return

Interface::childPrint = (text) ->
  @print text.toString().split(/\r\n|\r|\n/g).filter((chunk) ->
    chunk
  ).map((chunk) ->
    "< " + chunk
  ).join("\n")
  @repl.displayPrompt true
  return

Interface::error = (text) ->
  @print text
  @resume()
  return

Interface::handleBreak = (r) ->
  self = this
  @pause()
  @client.currentSourceLine = r.sourceLine
  @client.currentSourceLineText = r.sourceLineText
  @client.currentSourceColumn = r.sourceColumn
  @client.currentFrame = 0
  @client.currentScript = r.script and r.script.name
  @print SourceInfo(r)
  @watchers true, (err) ->
    return self.error(err)  if err
    self.list 2
    self.resume true
    return

  return

Interface::requireConnection = ->
  unless @client
    @error "App isn't running... Try `run` instead"
    return false
  true

Interface::controlEval = (code, context, filename, callback) ->
  try
    code = @repl.rli.history[0] + "\n"  if code is "\n"  if @repl.rli.history and @repl.rli.history.length > 0
    result = vm.runInContext(code, context, filename)
    return callback(null, result)  if @paused is 0
    @waiting = ->
      callback null, result
      return
  catch e
    callback e
  return

Interface::debugEval = (code, context, filename, callback) ->
  return  unless @requireConnection()
  self = this
  client = @client
  if code is ".scope"
    client.reqScopes callback
    return
  frame = (if client.currentFrame is NO_FRAME then frame else `undefined`)
  self.pause()
  client.reqFrameEval code, frame, (err, res) ->
    if err
      callback err
      self.resume true
      return
    client.mirrorObject res, 3, (err, mirror) ->
      callback null, mirror
      self.resume true
      return

    return

  return


# Commands

# Print help message
Interface::help = ->
  @print helpMessage
  return


# Run script
Interface::run = ->
  callback = arguments[0]
  if @child
    @error "App is already running... Try `restart` instead"
    callback and callback(true)
  else
    @trySpawn callback
  return


# Restart script
Interface::restart = ->
  return  unless @requireConnection()
  self = this
  self.pause()
  self.killChild()
  
  # XXX need to wait a little bit for the restart to work?
  setTimeout (->
    self.trySpawn()
    self.resume()
    return
  ), 1000
  return


# Print version
Interface::version = ->
  return  unless @requireConnection()
  self = this
  @pause()
  @client.reqVersion (err, v) ->
    if err
      self.error err
    else
      self.print v
    self.resume()
    return

  return


# List source code
Interface::list = (delta) ->
  return  unless @requireConnection()
  delta or (delta = 5)
  self = this
  client = @client
  from = client.currentSourceLine - delta + 1
  to = client.currentSourceLine + delta + 1
  self.pause()
  client.reqSource from, to, (err, res) ->
    if err or not res
      self.error "You can't list source code right now"
      self.resume()
      return
    lines = res.source.split("\n")
    i = 0

    while i < lines.length
      lineno = res.fromLine + i + 1
      continue  if lineno < from or lineno > to
      current = lineno is 1 + client.currentSourceLine
      breakpoint = client.breakpoints.some((bp) ->
        (bp.scriptReq is client.currentScript or bp.script is client.currentScript) and bp.line is lineno
      )
      if lineno is 1
        
        # The first line needs to have the module wrapper filtered out of
        # it.
        wrapper = module.wrapper[0]
        lines[i] = lines[i].slice(wrapper.length)
        client.currentSourceColumn -= wrapper.length
      
      # Highlight executing statement
      line = undefined
      if current
        line = SourceUnderline(lines[i], client.currentSourceColumn, self.repl)
      else
        line = lines[i]
      prefixChar = " "
      if current
        prefixChar = ">"
      else prefixChar = "*"  if breakpoint
      self.print leftPad(lineno, prefixChar, to) + " " + line
      i++
    self.resume()
    return

  return


# Print backtrace
Interface::backtrace = ->
  return  unless @requireConnection()
  self = this
  client = @client
  self.pause()
  client.fullTrace (err, bt) ->
    if err
      self.error "Can't request backtrace now"
      self.resume()
      return
    if bt.totalFrames is 0
      self.print "(empty stack)"
    else
      trace = []
      firstFrameNative = bt.frames[0].script.isNative
      i = 0

      while i < bt.frames.length
        frame = bt.frames[i]
        break  if not firstFrameNative and frame.script.isNative
        text = "#" + i + " "
        text += frame.func.inferredName + " "  if frame.func.inferredName and frame.func.inferredName.length > 0
        text += path.basename(frame.script.name) + ":"
        text += (frame.line + 1) + ":" + (frame.column + 1)
        trace.push text
        i++
      self.print trace.join("\n")
    self.resume()
    return

  return


# First argument tells if it should display internal node scripts or not
# (available only for internal debugger's functions)
Interface::scripts = ->
  return  unless @requireConnection()
  client = @client
  displayNatives = arguments[0] or false
  scripts = []
  @pause()
  for id of client.scripts
    script = client.scripts[id]
    scripts.push ((if script.name is client.currentScript then "* " else "  ")) + id + ": " + path.basename(script.name)  if displayNatives or script.name is client.currentScript or not script.isNative  if util.isObject(script) and script.name
  @print scripts.join("\n")
  @resume()
  return


# Continue execution of script
Interface::cont = ->
  return  unless @requireConnection()
  @pause()
  self = this
  @client.reqContinue (err) ->
    self.error err  if err
    self.resume()
    return

  return


# Step commands generator
Interface.stepGenerator = (type, count) ->
  ->
    return  unless @requireConnection()
    self = this
    self.pause()
    self.client.step type, count, (err, res) ->
      self.error err  if err
      self.resume()
      return

    return


# Jump to next command
Interface::next = Interface.stepGenerator("next", 1)

# Step in
Interface::step = Interface.stepGenerator("in", 1)

# Step out
Interface::out = Interface.stepGenerator("out", 1)

# Watch
Interface::watch = (expr) ->
  @_watchers.push expr
  return


# Unwatch
Interface::unwatch = (expr) ->
  index = @_watchers.indexOf(expr)
  
  # Unwatch by expression
  # or
  # Unwatch by watcher number
  @_watchers.splice (if index isnt -1 then index else +expr), 1
  return


# List watchers
Interface::watchers = ->
  wait = ->
    if --waiting is 0
      self.print "Watchers:"  if verbose
      self._watchers.forEach (watcher, i) ->
        self.print leftPad(i, " ", self._watchers.length - 1) + ": " + watcher + " = " + JSON.stringify(values[i])
        return

      self.print ""  if verbose
      self.resume()
      callback null
    return
  self = this
  verbose = arguments[0] or false
  callback = arguments[1] or ->

  waiting = @_watchers.length
  values = []
  @pause()
  unless waiting
    @resume()
    return callback()
  @_watchers.forEach (watcher, i) ->
    self.debugEval watcher, null, null, (err, value) ->
      values[i] = (if err then "<error>" else value)
      wait()
      return

    return

  return


# Break on exception
Interface::breakOnException = breakOnException = ->
  return  unless @requireConnection()
  self = this
  
  # Break on exceptions
  @pause()
  @client.reqSetExceptionBreak "all", (err, res) ->
    self.resume()
    return

  return


# Add breakpoint
Interface::setBreakpoint = (script, line, condition, silent) ->
  return  unless @requireConnection()
  self = this
  scriptId = undefined
  ambiguous = undefined
  
  # setBreakpoint() should insert breakpoint on current line
  if util.isUndefined(script)
    script = @client.currentScript
    line = @client.currentSourceLine + 1
  
  # setBreakpoint(line-number) should insert breakpoint in current script
  if util.isUndefined(line) and util.isNumber(script)
    line = script
    script = @client.currentScript
  if /\(\)$/.test(script)
    
    # setBreakpoint('functionname()');
    req =
      type: "function"
      target: script.replace(/\(\)$/, "")
      condition: condition
  else
    
    # setBreakpoint('scriptname')
    if script isnt +script and not @client.scripts[script]
      scripts = @client.scripts
      keys = Object.keys(scripts)
      v = 0

      while v < keys.length
        id = keys[v]
        if scripts[id] and scripts[id].name and scripts[id].name.indexOf(script) isnt -1
          ambiguous = true  if scriptId
          scriptId = id
        v++
    else
      scriptId = script
    return @error("Script name is ambiguous")  if ambiguous
    return @error("Line should be a positive value")  if line <= 0
    req = undefined
    if scriptId
      req =
        type: "scriptId"
        target: scriptId
        line: line - 1
        condition: condition
    else
      @print "Warning: script '" + script + "' was not loaded yet."
      escapedPath = script.replace(/([/\\.?*()^${}|[\]])/g, "\\$1")
      scriptPathRegex = "^(.*[\\/\\\\])?" + escapedPath + "$"
      req =
        type: "scriptRegExp"
        target: scriptPathRegex
        line: line - 1
        condition: condition
  self.pause()
  self.client.setBreakpoint req, (err, res) ->
    if err
      self.error err  unless silent
    else
      self.list 5  unless silent
      
      # Try load scriptId and line from response
      unless scriptId
        scriptId = res.script_id
        line = res.line + 1
      
      # Remember this breakpoint even if scriptId is not resolved yet
      self.client.breakpoints.push
        id: res.breakpoint
        scriptId: scriptId
        script: (self.client.scripts[scriptId] or {}).name
        line: line
        condition: condition
        scriptReq: script

    self.resume()
    return

  return


# Clear breakpoint
Interface::clearBreakpoint = (script, line) ->
  return  unless @requireConnection()
  ambiguous = undefined
  breakpoint = undefined
  index = undefined
  @client.breakpoints.some (bp, i) ->
    if bp.scriptId is script or bp.scriptReq is script or (bp.script and bp.script.indexOf(script) isnt -1)
      ambiguous = true  unless util.isUndefined(index)
      if bp.line is line
        index = i
        breakpoint = bp.id
        true

  return @error("Script name is ambiguous")  if ambiguous
  return @error("Script : " + script + " not found")  if util.isUndefined(breakpoint)
  self = this
  req = breakpoint: breakpoint
  self.pause()
  self.client.clearBreakpoint req, (err, res) ->
    if err
      self.error err
    else
      self.client.breakpoints.splice index, 1
      self.list 5
    self.resume()
    return

  return


# Show breakpoints
Interface::breakpoints = ->
  return  unless @requireConnection()
  @pause()
  self = this
  @client.listbreakpoints (err, res) ->
    if err
      self.error err
    else
      self.print res
      self.resume()
    return

  return


# Pause child process
Interface::pause_ = ->
  return  unless @requireConnection()
  self = this
  cmd = "process._debugPause();"
  @pause()
  @client.reqFrameEval cmd, NO_FRAME, (err, res) ->
    if err
      self.error err
    else
      self.resume()
    return

  return


# Kill child process
Interface::kill = ->
  return  unless @child
  @killChild()
  return


# Activate debug repl
Interface::repl = ->
  return  unless @requireConnection()
  self = this
  self.print "Press Ctrl + C to leave debug repl"
  
  # Don't display any default messages
  listeners = @repl.rli.listeners("SIGINT").slice(0)
  @repl.rli.removeAllListeners "SIGINT"
  
  # Exit debug repl on Ctrl + C
  @repl.rli.once "SIGINT", ->
    
    # Restore all listeners
    process.nextTick ->
      listeners.forEach (listener) ->
        self.repl.rli.on "SIGINT", listener
        return

      return

    
    # Exit debug repl
    self.exitRepl()
    return

  
  # Set new
  @repl.eval = @debugEval.bind(this)
  @repl.context = {}
  
  # Swap history
  @history.control = @repl.rli.history
  @repl.rli.history = @history.debug
  @repl.rli.setPrompt "> "
  @repl.displayPrompt()
  return


# Exit debug repl
Interface::exitRepl = ->
  
  # Restore eval
  @repl.eval = @controlEval.bind(this)
  
  # Swap history
  @history.debug = @repl.rli.history
  @repl.rli.history = @history.control
  @repl.context = @context
  @repl.rli.setPrompt "debug> "
  @repl.displayPrompt()
  return


# Quit
Interface::quit = ->
  @killChild()
  process.exit 0
  return


# Kills child process
Interface::killChild = ->
  if @child
    @child.kill()
    @child = null
  if @client
    
    # Save breakpoints
    @breakpoints = @client.breakpoints
    @client.destroy()
    @client = null
  return


# Spawns child process (and restores breakpoints)
Interface::trySpawn = (cb) ->
  
  # Connecting to remote debugger
  # `node debug localhost:5858`
  
  # TODO Do we really need to handle it?
  
  # `node debug -p pid`
  
  # TODO Do we really need to handle it?
  
  # Start debugger on custom port
  # `node debug --port=5858 app.js`
  
  # Restore breakpoints
  connectError = ->
    
    # If it's failed to connect 4 times then don't catch the next error
    client.removeListener "error", connectError  if connectionAttempts >= 10
    setTimeout attemptConnect, 500
    return
  attemptConnect = ->
    ++connectionAttempts
    self.stdout.write "."
    client.connect port, host
    return
  self = this
  breakpoints = @breakpoints or []
  port = exports.port
  host = "localhost"
  childArgs = @args
  @killChild()
  assert not @child
  if @args.length is 2
    match = @args[1].match(/^([^:]+):(\d+)$/)
    if match
      host = match[1]
      port = parseInt(match[2], 10)
      @child = kill: ->
  else if @args.length is 3
    if @args[1] is "-p" and /^\d+$/.test(@args[2])
      @child = kill: ->

      process._debugProcess parseInt(@args[2], 10)
    else
      match = @args[1].match(/^--port=(\d+)$/)
      if match
        port = parseInt(match[1], 10)
        childArgs = ["--debug-brk=" + port].concat(@args.slice(2))
  @child = spawn(process.execPath, childArgs)
  @child.stdout.on "data", @childPrint.bind(this)
  @child.stderr.on "data", @childPrint.bind(this)
  @pause()
  client = self.client = new Client()
  connectionAttempts = 0
  client.once "ready", ->
    self.stdout.write " ok\n"
    breakpoints.forEach (bp) ->
      self.print "Restoring breakpoint " + bp.scriptReq + ":" + bp.line
      self.setBreakpoint bp.scriptReq, bp.line, bp.condition, true
      return

    client.on "close", ->
      self.pause()
      self.print "program terminated"
      self.resume()
      self.client = null
      self.killChild()
      return

    cb()  if cb
    self.resume()
    return

  client.on "unhandledResponse", (res) ->
    self.pause()
    self.print "\nunhandled res:" + JSON.stringify(res)
    self.resume()
    return

  client.on "break", (res) ->
    self.handleBreak res.body
    return

  client.on "exception", (res) ->
    self.handleBreak res.body
    return

  client.on "error", connectError
  @child.stderr.once "data", ->
    setImmediate ->
      self.print "connecting to port " + port + "..", true
      attemptConnect()
      return

    return

  return
