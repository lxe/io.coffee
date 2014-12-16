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

# A repl library that you can include in your own code to get a runtime
# * interface to your program.
# *
# *   var repl = require("repl");
# *   // start repl on stdin
# *   repl.start("prompt> ");
# *
# *   // listen for unix socket connections and start repl on them
# *   net.createServer(function(socket) {
# *     repl.start("node via Unix socket> ", socket);
# *   }).listen("/tmp/node-repl-sock");
# *
# *   // listen for TCP socket connections and start repl on them
# *   net.createServer(function(socket) {
# *     repl.start("node via TCP socket> ", socket);
# *   }).listen(5001);
# *
# *   // expose foo to repl context
# *   repl.start("node > ").context.foo = "stdin is fun";
# 

# If obj.hasOwnProperty has been overridden, then calling
# obj.hasOwnProperty(prop) will break.
# See: https://github.com/joyent/node/issues/1707
hasOwnProperty = (obj, prop) ->
  Object::hasOwnProperty.call obj, prop

# hack for require.resolve("./relative") to work properly.

# hack for repl require to work properly with node_modules folders

# Can overridden with custom print functions, such as `probe` or `eyes.js`.
# This is the default "writer" value if none is passed in the REPL options.
REPLServer = (prompt, stream, eval_, useGlobal, ignoreUndefined) ->
  
  # an options object was given
  
  # just for backwards compat, see github.com/joyent/node/pull/7127
  defaultEval = (code, context, file, cb) ->
    err = undefined
    result = undefined
    
    # first, create the Script object to check the syntax
    try
      script = vm.createScript(code,
        filename: file
        displayErrors: false
      )
    catch e
      debug "parse error %j", code, e
      if isRecoverableError(e)
        err = new Recoverable(e)
      else
        err = e
    unless err
      try
        if self.useGlobal
          result = script.runInThisContext(displayErrors: false)
        else
          result = script.runInContext(context,
            displayErrors: false
          )
      catch e
        err = e
        if err and process.domain
          debug "not recoverable, send to domain"
          process.domain.emit "error", err
          process.domain.exit()
          return
    cb err, result
    return
  
  # legacy API, passing a 'stream'/'socket' option
  
  # use stdin and stdout as the default streams if none were given
  
  # We're given custom object with 2 streams, or the `process` object
  
  # We're given a duplex readable/writable Stream, like a `net.Socket`
  complete = (text, callback) ->
    self.complete text, callback
    return
  return new REPLServer(prompt, stream, eval_, useGlobal, ignoreUndefined)  unless this instanceof REPLServer
  options = undefined
  input = undefined
  output = undefined
  dom = undefined
  if util.isObject(prompt)
    options = prompt
    stream = options.stream or options.socket
    input = options.input
    output = options.output
    eval_ = options.eval
    useGlobal = options.useGlobal
    ignoreUndefined = options.ignoreUndefined
    prompt = options.prompt
    dom = options.domain
  else unless util.isString(prompt)
    throw new Error("An options Object, or a prompt String are required")
  else
    options = {}
  self = this
  self._domain = dom or domain.create()
  self.useGlobal = !!useGlobal
  self.ignoreUndefined = !!ignoreUndefined
  self.rli = this
  eval_ = eval_ or defaultEval
  self.eval = self._domain.bind(eval_)
  self._domain.on "error", (e) ->
    debug "domain error"
    self.outputStream.write (e.stack or e) + "\n"
    self.bufferedCommand = ""
    self.lines.level = []
    self.displayPrompt()
    return

  if not input and not output
    stream = process  unless stream
    if stream.stdin and stream.stdout
      input = stream.stdin
      output = stream.stdout
    else
      input = stream
      output = stream
  self.inputStream = input
  self.outputStream = output
  self.resetContext()
  self.bufferedCommand = ""
  self.lines.level = []
  rl.Interface.apply this, [
    self.inputStream
    self.outputStream
    complete
    options.terminal
  ]
  self.setPrompt (if not util.isUndefined(prompt) then prompt else "> ")
  @commands = {}
  defineDefaultCommands this
  
  # figure out which "writer" function to use
  self.writer = options.writer or exports.writer
  options.useColors = self.terminal  if util.isUndefined(options.useColors)
  self.useColors = !!options.useColors
  if self.useColors and self.writer is util.inspect
    
    # Turn on ANSI coloring.
    self.writer = (obj, showHidden, depth) ->
      util.inspect obj, showHidden, depth, true
  self.setPrompt self._prompt
  self.on "close", ->
    self.emit "exit"
    return

  sawSIGINT = false
  self.on "SIGINT", ->
    empty = self.line.length is 0
    self.clearLine()
    if not (self.bufferedCommand and self.bufferedCommand.length > 0) and empty
      if sawSIGINT
        self.close()
        sawSIGINT = false
        return
      self.output.write "(^C again to quit)\n"
      sawSIGINT = true
    else
      sawSIGINT = false
    self.bufferedCommand = ""
    self.lines.level = []
    self.displayPrompt()
    return

  self.on "line", (cmd) ->
    
    # Check to see if a REPL keyword was used. If it returns true,
    # display next prompt and return.
    
    # It's confusing for `{ a : 1 }` to be interpreted as a block
    # statement rather than an object literal.  So, we first try
    # to wrap it in parentheses, so that it will be interpreted as
    # an expression.
    
    # otherwise we just append a \n so that it will be either
    # terminated, or continued onto the next expression if it's an
    # unexpected end of input.
    finish = (e, ret) ->
      debug "finish", e, ret
      self.memory cmd
      if e and not self.bufferedCommand and cmd.trim().match(/^npm /)
        self.outputStream.write "npm should be run outside of the " + "node repl, in your normal shell.\n" + "(Press Control-D to exit.)\n"
        self.bufferedCommand = ""
        self.displayPrompt()
        return
      
      # If error was SyntaxError and not JSON.parse error
      if e
        if e instanceof Recoverable
          
          # Start buffering data like that:
          # {
          # ...  x: 1
          # ... }
          self.bufferedCommand += cmd + "\n"
          self.displayPrompt()
          return
        else
          self._domain.emit "error", e
      
      # Clear buffer if no SyntaxErrors
      self.bufferedCommand = ""
      
      # If we got any output - print it (if no error)
      if not e and (not self.ignoreUndefined or not util.isUndefined(ret))
        self.context._ = ret
        self.outputStream.write self.writer(ret) + "\n"
      
      # Display prompt again
      self.displayPrompt()
      return
    debug "line %j", cmd
    sawSIGINT = false
    skipCatchall = false
    cmd = trimWhitespace(cmd)
    if cmd and cmd.charAt(0) is "." and isNaN(parseFloat(cmd))
      matches = cmd.match(/^\.([^\s]+)\s*(.*)$/)
      keyword = matches and matches[1]
      rest = matches and matches[2]
      if self.parseREPLKeyword(keyword, rest) is true
        return
      else
        self.outputStream.write "Invalid REPL keyword\n"
        skipCatchall = true
    unless skipCatchall
      evalCmd = self.bufferedCommand + cmd
      if /^\s*\{/.test(evalCmd) and /\}\s*$/.test(evalCmd)
        evalCmd = "(" + evalCmd + ")\n"
      else
        evalCmd = evalCmd + "\n"
      debug "eval %j", evalCmd
      self.eval evalCmd, self.context, "repl", finish
    else
      finish null
    return

  self.on "SIGCONT", ->
    self.displayPrompt true
    return

  self.displayPrompt()
  return

# prompt is a string to print on each line for the prompt,
# source is a stream to use for I/O, defaulting to stdin/stdout.

# make built-in modules available directly
# (loaded lazily)

# allow the creation of other globals with this name

# Allow REPL extensions to extend the new context

# Do not overwrite `_initialPrompt` here

# When invoked as an API method, overwrite _initialPrompt

# A stream to push an array into a REPL
# used in REPLServer.complete
ArrayStream = ->
  Stream.call this
  @run = (data) ->
    self = this
    data.forEach (line) ->
      self.emit "data", line + "\n"
      return

    return

  return

# Provide a list of completions for the given leading text. This is
# given to the readline interface for handling tab completion.
#
# Example:
#  complete('var foo = util.')
#    -> [['util.print', 'util.debug', 'util.log', 'util.inspect', 'util.pump'],
#        'util.' ]
#
# Warning: This eval's code like "foo.bar.baz", so it will run property
# getter code.

# There may be local variables to evaluate, try a nested REPL

# Get a new array of inputed lines

# Kill off all function declarations to push all local variables into
# global scope
# make a new "input" stream
# make a nested REPL
# eval the flattened code
# all this is only profitable if the nested REPL
# does not have a bufferedCommand

# list of completion lists, one for each inheritance "level"

# REPL commands (e.g. ".break").

# require('...<Tab>')

# Exclude versioned names that 'npm' installs.

# Handle variable member lookup.
# We support simple chained expressions like the following (no function
# calls, etc.). That is for simplicity and also because we *eval* that
# leading expression so for safety (see WARNING above) don't want to
# eval function calls.
#
#   foo.bar<|>     # completions for 'foo' with filter 'bar'
#   spam.eggs.<|>  # completions for 'spam.eggs' with filter ''
#   foo<|>         # all scope vars with filter 'foo'
#   foo.<|>        # completions for 'foo' with filter ''

# Resolve expr and get its completions.

# If context is instance of vm.ScriptContext
# Get global vars synchronously

# Add grouped globals

# if (e) console.log(e);

# works for non-objects

# Circular refs possible? Let's guard against that.

#console.log("completion error walking prototype chain:" + e);

# Will be called when all completionGroups are in place
# Useful for async autocompletion

# Filter, sort (within each group), uniq and merge the completion groups.
# unique completions across all groups

# Completion group 0 is the "closest"
# (least far up the inheritance chain)
# so we put its completions last: to be closest in the REPL.
# separator btwn groups

###*
Used to parse and execute the Node REPL commands.

@param {keyword} keyword The command entered to check.
@return {Boolean} If true it means don't continue parsing the command.
###

# save the line so I can do magic later

# TODO should I tab the level?

# I don't want to not change the format too much...

# I need to know "depth."
# Because I can not tell the difference between a } that
# closes an object literal and a } that closes a function

# going down is { and (   e.g. function() {
# going up is } and )

# going... down.
# push the line#, depth count, and if the line is a function.
# Since JS only has functional scope I only need to remove
# "function() {" lines, clearly this will not work for
# "function()
# {" but nothing should break, only tab completion for local
# scope will not work for this function.

# going... up.

#more to go, recurse

#remove and push back

# it is possible to determine a syntax error at this point.
# if the REPL still has a bufferedCommand and
# self.lines.level.length === 0
# TODO? keep a log of level so that any syntax breaking lines can
# be cleared on .break and in the case of a syntax error?
# TODO? if a log was kept, then I could clear the bufferedComand and
# eval these lines and throw the syntax error
addStandardGlobals = (completionGroups, filter) ->
  
  # Global object properties
  # (http://www.ecma-international.org/publications/standards/Ecma-262.htm)
  completionGroups.push [
    "NaN"
    "Infinity"
    "undefined"
    "eval"
    "parseInt"
    "parseFloat"
    "isNaN"
    "isFinite"
    "decodeURI"
    "decodeURIComponent"
    "encodeURI"
    "encodeURIComponent"
    "Object"
    "Function"
    "Array"
    "String"
    "Boolean"
    "Number"
    "Date"
    "RegExp"
    "Error"
    "EvalError"
    "RangeError"
    "ReferenceError"
    "SyntaxError"
    "TypeError"
    "URIError"
    "Math"
    "JSON"
  ]
  
  # Common keywords. Exclude for completion on the empty string, b/c
  # they just get in the way.
  if filter
    completionGroups.push [
      "break"
      "case"
      "catch"
      "const"
      "continue"
      "debugger"
      "default"
      "delete"
      "do"
      "else"
      "export"
      "false"
      "finally"
      "for"
      "function"
      "if"
      "import"
      "in"
      "instanceof"
      "let"
      "new"
      "null"
      "return"
      "switch"
      "this"
      "throw"
      "true"
      "try"
      "typeof"
      "undefined"
      "var"
      "void"
      "while"
      "with"
      "yield"
    ]
  return
defineDefaultCommands = (repl) ->
  
  # TODO remove me after 0.3.x
  repl.defineCommand "break",
    help: "Sometimes you get stuck, this gets you out"
    action: ->
      @bufferedCommand = ""
      @displayPrompt()
      return

  clearMessage = undefined
  if repl.useGlobal
    clearMessage = "Alias for .break"
  else
    clearMessage = "Break, and also clear the local context"
  repl.defineCommand "clear",
    help: clearMessage
    action: ->
      @bufferedCommand = ""
      unless @useGlobal
        @outputStream.write "Clearing context...\n"
        @resetContext()
      @displayPrompt()
      return

  repl.defineCommand "exit",
    help: "Exit the repl"
    action: ->
      @close()
      return

  repl.defineCommand "help",
    help: "Show repl options"
    action: ->
      self = this
      Object.keys(@commands).sort().forEach (name) ->
        cmd = self.commands[name]
        self.outputStream.write name + "\t" + (cmd.help or "") + "\n"
        return

      @displayPrompt()
      return

  repl.defineCommand "save",
    help: "Save all evaluated commands in this REPL session to a file"
    action: (file) ->
      try
        fs.writeFileSync file, @lines.join("\n") + "\n"
        @outputStream.write "Session saved to:" + file + "\n"
      catch e
        @outputStream.write "Failed to save:" + file + "\n"
      @displayPrompt()
      return

  repl.defineCommand "load",
    help: "Load JS from a file into the REPL session"
    action: (file) ->
      try
        stats = fs.statSync(file)
        if stats and stats.isFile()
          self = this
          data = fs.readFileSync(file, "utf8")
          lines = data.split("\n")
          @displayPrompt()
          lines.forEach (line) ->
            self.write line + "\n"  if line
            return

      catch e
        @outputStream.write "Failed to load:" + file + "\n"
      @displayPrompt()
      return

  return
trimWhitespace = (cmd) ->
  trimmer = /^\s*(.+)\s*$/m
  matches = trimmer.exec(cmd)
  return matches[1]  if matches and matches.length is 2
  ""
regexpEscape = (s) ->
  s.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

###*
Converts commands that use var and function <name>() to use the
local exports.context when evaled. This provides a local context
on the REPL.

@param {String} cmd The cmd to convert.
@return {String} The converted command.
###

# Replaces: var foo = "bar";  with: self.context.foo = bar;

# Replaces: function foo() {};  with: foo = function foo() {};

# If the error is that we've unexpectedly ended the input,
# then let the user try to recover by adding more input.
isRecoverableError = (e) ->
  e and e.name is "SyntaxError" and /^(Unexpected end of input|Unexpected token :)/.test(e.message)
Recoverable = (err) ->
  @err = err
  return
"use strict"
util = require("util")
inherits = require("util").inherits
Stream = require("stream")
vm = require("vm")
path = require("path")
fs = require("fs")
rl = require("readline")
Console = require("console").Console
domain = require("domain")
debug = util.debuglog("repl")
module.filename = path.resolve("repl")
module.paths = require("module")._nodeModulePaths(module.filename)
exports.writer = util.inspect
exports._builtinLibs = [
  "assert"
  "buffer"
  "child_process"
  "cluster"
  "crypto"
  "dgram"
  "dns"
  "domain"
  "events"
  "fs"
  "http"
  "https"
  "net"
  "os"
  "path"
  "punycode"
  "querystring"
  "readline"
  "stream"
  "string_decoder"
  "tls"
  "tty"
  "url"
  "util"
  "v8"
  "vm"
  "zlib"
  "smalloc"
]
inherits REPLServer, rl.Interface
exports.REPLServer = REPLServer
exports.start = (prompt, source, eval_, useGlobal, ignoreUndefined) ->
  repl = new REPLServer(prompt, source, eval_, useGlobal, ignoreUndefined)
  exports.repl = repl  unless exports.repl
  repl

REPLServer::createContext = ->
  context = undefined
  if @useGlobal
    context = global
  else
    context = vm.createContext()
    for i of global
      context[i] = global[i]
    context.console = new Console(@outputStream)
    context.global = context
    context.global.global = context
  context.module = module
  context.require = require
  @lines = []
  @lines.level = []
  exports._builtinLibs.forEach (name) ->
    Object.defineProperty context, name,
      get: ->
        lib = require(name)
        context._ = context[name] = lib
        lib

      set: (val) ->
        delete context[name]

        context[name] = val
        return

      configurable: true

    return

  context

REPLServer::resetContext = ->
  @context = @createContext()
  @emit "reset", @context
  return

REPLServer::displayPrompt = (preserveCursor) ->
  prompt = @_initialPrompt
  if @bufferedCommand.length
    prompt = "..."
    levelInd = new Array(@lines.level.length).join("..")
    prompt += levelInd + " "
  REPLServer.super_::setPrompt.call this, prompt
  @prompt preserveCursor
  return

REPLServer::setPrompt = setPrompt = (prompt) ->
  @_initialPrompt = prompt
  REPLServer.super_::setPrompt.call this, prompt
  return

util.inherits ArrayStream, Stream
ArrayStream::readable = true
ArrayStream::writable = true
ArrayStream::resume = ->

ArrayStream::write = ->

requireRE = /\brequire\s*\(['"](([\w\.\/-]+\/)?([\w\.\/-]*))/
simpleExpressionRE = /(([a-zA-Z_$](?:\w|\$)*)\.)*([a-zA-Z_$](?:\w|\$)*)\.?$/
REPLServer::complete = (line, callback) ->
  completionGroupsLoaded = (err) ->
    throw err  if err
    if completionGroups.length and filter
      newCompletionGroups = []
      i = 0
      while i < completionGroups.length
        group = completionGroups[i].filter((elem) ->
          elem.indexOf(filter) is 0
        )
        newCompletionGroups.push group  if group.length
        i++
      completionGroups = newCompletionGroups
    if completionGroups.length
      uniq = {}
      completions = []
      i = completionGroups.length - 1
      while i >= 0
        group = completionGroups[i]
        group.sort()
        j = 0

        while j < group.length
          c = group[j]
          unless hasOwnProperty(uniq, c)
            completions.push c
            uniq[c] = true
          j++
        completions.push ""
        i--
      completions.pop()  while completions.length and completions[completions.length - 1] is ""
    callback null, [
      completions or []
      completeOn
    ]
    return
  if not util.isUndefined(@bufferedCommand) and @bufferedCommand.length
    tmp = @lines.slice()
    @lines.level.forEach (kill) ->
      tmp[kill.line] = ""  if kill.isFunction
      return

    flat = new ArrayStream()
    magic = new REPLServer("", flat)
    magic.context = magic.createContext()
    flat.run tmp
    return magic.complete(line, callback)  unless magic.bufferedCommand
  completions = undefined
  completionGroups = []
  completeOn = undefined
  match = undefined
  filter = undefined
  i = undefined
  group = undefined
  c = undefined
  match = null
  match = line.match(/^\s*(\.\w*)$/)
  if match
    completionGroups.push Object.keys(@commands)
    completeOn = match[1]
    filter = match[1]  if match[1].length > 1
    completionGroupsLoaded()
  else if match = line.match(requireRE)
    exts = Object.keys(require.extensions)
    indexRe = new RegExp("^index(" + exts.map(regexpEscape).join("|") + ")$")
    completeOn = match[1]
    subdir = match[2] or ""
    filter = match[1]
    dir = undefined
    files = undefined
    f = undefined
    name = undefined
    base = undefined
    ext = undefined
    abs = undefined
    subfiles = undefined
    s = undefined
    group = []
    paths = module.paths.concat(require("module").globalPaths)
    i = 0
    while i < paths.length
      dir = path.resolve(paths[i], subdir)
      try
        files = fs.readdirSync(dir)
      catch e
        continue
      f = 0
      while f < files.length
        name = files[f]
        ext = path.extname(name)
        base = name.slice(0, -ext.length)
        continue  if base.match(/-\d+\.\d+(\.\d+)?/) or name is ".npm"
        if exts.indexOf(ext) isnt -1
          group.push subdir + base  if not subdir or base isnt "index"
        else
          abs = path.resolve(dir, name)
          try
            if fs.statSync(abs).isDirectory()
              group.push subdir + name + "/"
              subfiles = fs.readdirSync(abs)
              s = 0
              while s < subfiles.length
                group.push subdir + name  if indexRe.test(subfiles[s])
                s++
        f++
      i++
    completionGroups.push group  if group.length
    completionGroups.push exports._builtinLibs  unless subdir
    completionGroupsLoaded()
  else if line.length is 0 or line[line.length - 1].match(/\w|\.|\$/)
    match = simpleExpressionRE.exec(line)
    if line.length is 0 or match
      expr = undefined
      completeOn = ((if match then match[0] else ""))
      if line.length is 0
        filter = ""
        expr = ""
      else if line[line.length - 1] is "."
        filter = ""
        expr = match[0].slice(0, match[0].length - 1)
      else
        bits = match[0].split(".")
        filter = bits.pop()
        expr = bits.join(".")
      memberGroups = []
      unless expr
        if @useGlobal or @context.constructor and @context.constructor.name is "Context"
          contextProto = @context
          completionGroups.push Object.getOwnPropertyNames(contextProto)  while contextProto = Object.getPrototypeOf(contextProto)
          completionGroups.push Object.getOwnPropertyNames(@context)
          addStandardGlobals completionGroups, filter
          completionGroupsLoaded()
        else
          @eval ".scope", @context, "repl", (err, globals) ->
            if err or not globals
              addStandardGlobals completionGroups, filter
            else if util.isArray(globals[0])
              globals.forEach (group) ->
                completionGroups.push group
                return

            else
              completionGroups.push globals
              addStandardGlobals completionGroups, filter
            completionGroupsLoaded()
            return

      else
        @eval expr, @context, "repl", (e, obj) ->
          if obj?
            memberGroups.push Object.getOwnPropertyNames(obj)  if util.isObject(obj) or util.isFunction(obj)
            try
              sentinel = 5
              p = undefined
              if util.isObject(obj) or util.isFunction(obj)
                p = Object.getPrototypeOf(obj)
              else
                p = (if obj.constructor then obj.constructor:: else null)
              until util.isNull(p)
                memberGroups.push Object.getOwnPropertyNames(p)
                p = Object.getPrototypeOf(p)
                sentinel--
                break  if sentinel <= 0
          if memberGroups.length
            i = 0
            while i < memberGroups.length
              completionGroups.push memberGroups[i].map((member) ->
                expr + "." + member
              )
              i++
            filter = expr + "." + filter  if filter
          completionGroupsLoaded()
          return

    else
      completionGroupsLoaded()
  else
    completionGroupsLoaded()
  return

REPLServer::parseREPLKeyword = (keyword, rest) ->
  cmd = @commands[keyword]
  if cmd
    cmd.action.call this, rest
    return true
  false

REPLServer::defineCommand = (keyword, cmd) ->
  if util.isFunction(cmd)
    cmd = action: cmd
  else throw new Error("bad argument, action must be a function")  unless util.isFunction(cmd.action)
  @commands[keyword] = cmd
  return

REPLServer::memory = memory = (cmd) ->
  self = this
  self.lines = self.lines or []
  self.lines.level = self.lines.level or []
  if cmd
    self.lines.push new Array(self.lines.level.length).join("  ") + cmd
  else
    self.lines.push ""
  if cmd
    dw = cmd.match(/{|\(/g)
    up = cmd.match(/}|\)/g)
    up = (if up then up.length else 0)
    dw = (if dw then dw.length else 0)
    depth = dw - up
    if depth
      (workIt = ->
        if depth > 0
          self.lines.level.push
            line: self.lines.length - 1
            depth: depth
            isFunction: /\s*function\s*/.test(cmd)

        else if depth < 0
          curr = self.lines.level.pop()
          if curr
            tmp = curr.depth + depth
            if tmp < 0
              depth += curr.depth
              workIt()
            else if tmp > 0
              curr.depth += depth
              self.lines.level.push curr
        return
      )()
  else
    self.lines.level = []
  return

REPLServer::convertToContext = (cmd) ->
  self = this
  matches = undefined
  scopeVar = /^\s*var\s*([_\w\$]+)(.*)$/m
  scopeFunc = /^\s*function\s*([_\w\$]+)/
  matches = scopeVar.exec(cmd)
  return "self.context." + matches[1] + matches[2]  if matches and matches.length is 3
  matches = scopeFunc.exec(self.bufferedCommand)
  return matches[1] + " = " + self.bufferedCommand  if matches and matches.length is 2
  cmd

inherits Recoverable, SyntaxError
