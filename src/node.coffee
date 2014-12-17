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

# Hello, and welcome to hacking node.js!
#
# This file is invoked by node::Load in src/node.cc, and responsible for
# bootstrapping the node.js core. Special caution is given to the performance
# of the startup process, so many dependencies are invoked lazily.
"use strict"
(process) ->
  startup = ->
    EventEmitter = NativeModule.require("events").EventEmitter
    process.__proto__ = Object.create(EventEmitter::,
      constructor:
        value: process.constructor
    )
    EventEmitter.call process
    process.EventEmitter = EventEmitter # process.EventEmitter is deprecated
    
    # do this good and early, since it handles errors.
    startup.processFatal()
    startup.globalVariables()
    startup.globalTimeouts()
    startup.globalConsole()
    startup.processAssert()
    startup.processConfig()
    startup.processNextTick()
    startup.processStdio()
    startup.processKillAndExit()
    startup.processSignalHandlers()
    
    # Do not initialize channel in debugger agent, it deletes env variable
    # and the main thread won't see it.
    startup.processChannel()  if process.argv[1] isnt "--debug-agent"
    startup.processRawDebug()
    startup.resolveArgv0()
    
    # There are various modes that Node can run in. The most common two
    # are running from a script and running the REPL - but there are a few
    # others like the debugger or running --eval arguments. Here we decide
    # which mode we run in.
    if NativeModule.exists("_third_party_main")
      
      # To allow people to extend Node in different ways, this hook allows
      # one to drop a file lib/_third_party_main.js into the build
      # directory which will be executed instead of Node's normal loading.
      process.nextTick ->
        NativeModule.require "_third_party_main"
        return

    else if process.argv[1] is "debug"
      
      # Start the debugger agent
      d = NativeModule.require("_debugger")
      d.start()
    else if process.argv[1] is "--debug-agent"
      
      # Start the debugger agent
      d = NativeModule.require("_debug_agent")
      d.start()
    else if process._eval?
      
      # User passed '-e' or '--eval' arguments to Node.
      evalScript "[eval]"
    else if process.argv[1]
      
      # make process.argv[1] into a full path
      path = NativeModule.require("path")
      process.argv[1] = path.resolve(process.argv[1])
      
      # If this is a worker in cluster mode, start up the communication
      # channel.
      if process.env.NODE_UNIQUE_ID
        cluster = NativeModule.require("cluster")
        cluster._setupWorker()
        
        # Make sure it's not accidentally inherited by child processes.
        delete process.env.NODE_UNIQUE_ID
      Module = NativeModule.require("module")
      if global.v8debug and process.execArgv.some((arg) ->
        arg.match /^--debug-brk(=[0-9]*)?$/
      )
        
        # XXX Fix this terrible hack!
        #
        # Give the client program a few ticks to connect.
        # Otherwise, there's a race condition where `node debug foo.js`
        # will not be able to connect in time to catch the first
        # breakpoint message on line 1.
        #
        # A better fix would be to somehow get a message from the
        # global.v8debug object about a connection, and runMain when
        # that occurs.  --isaacs
        debugTimeout = +process.env.NODE_DEBUG_TIMEOUT or 50
        setTimeout Module.runMain, debugTimeout
      else
        
        # Main entry point into most programs:
        Module.runMain()
    else
      Module = NativeModule.require("module")
      
      # If -i or --interactive were passed, or stdin is a TTY.
      if process._forceRepl or NativeModule.require("tty").isatty(0)
        
        # REPL
        opts =
          useGlobal: true
          ignoreUndefined: false

        opts.terminal = false  if parseInt(process.env["NODE_NO_READLINE"], 10)
        opts.useColors = false  if parseInt(process.env["NODE_DISABLE_COLORS"], 10)
        repl = Module.requireRepl().start(opts)
        repl.on "exit", ->
          process.exit()
          return

      else
        
        # Read all of stdin - execute it.
        process.stdin.setEncoding "utf8"
        code = ""
        process.stdin.on "data", (d) ->
          code += d
          return

        process.stdin.on "end", ->
          process._eval = code
          evalScript "[stdin]"
          return

    return
  
  # If someone handled it, then great.  otherwise, die in C++ land
  # since that means that we'll exit the process, emit the 'exit' event
  
  # nothing to be done about it at this point.
  
  # if we handled an error, then make sure any ticks get processed
  
  # used for `process.config`, but not a real module
  
  # strip the gyp comment line at the beginning
  
  # Used to run V8's micro task queue.
  
  # This tickInfo thing is used so that the C++ code in src/node.cc
  # can have easy accesss to our nextTick state, and avoid unnecessary
  
  # *Must* match Environment::TickInfo::Fields in src/env.h.
  
  # Needs to be accessible from beyond this scope.
  
  # Run callbacks that have no domain.
  # Using domains will cause this to be overridden.
  
  # on the way out, don't bother. it won't get fired anyway.
  evalScript = (name) ->
    Module = NativeModule.require("module")
    path = NativeModule.require("path")
    cwd = process.cwd()
    module = new Module(name)
    module.filename = path.join(cwd, name)
    module.paths = Module._nodeModulePaths(cwd)
    script = process._eval
    unless Module._contextLoad
      body = script
      script = "global.__filename = " + JSON.stringify(name) + ";\n" + "global.exports = exports;\n" + "global.module = module;\n" + "global.__dirname = __dirname;\n" + "global.require = require;\n" + "return require(\"vm\").runInThisContext(" + JSON.stringify(body) + ", { filename: " + JSON.stringify(name) + " });\n"
    result = module._compile(script, name + "-wrapper")
    console.log result  if process._print_eval
    return
  createWritableStdioStream = (fd) ->
    stream = undefined
    tty_wrap = process.binding("tty_wrap")
    
    # Note stream._type is used for test-module-load-list.js
    switch tty_wrap.guessHandleType(fd)
      when "TTY"
        tty = NativeModule.require("tty")
        stream = new tty.WriteStream(fd)
        stream._type = "tty"
        
        # Hack to have stream not keep the event loop alive.
        # See https://github.com/joyent/node/issues/1726
        stream._handle.unref()  if stream._handle and stream._handle.unref
      when "FILE"
        fs = NativeModule.require("fs")
        stream = new fs.SyncWriteStream(fd,
          autoClose: false
        )
        stream._type = "fs"
      when "PIPE", "TCP"
        net = NativeModule.require("net")
        stream = new net.Socket(
          fd: fd
          readable: false
          writable: true
        )
        
        # FIXME Should probably have an option in net.Socket to create a
        # stream from an existing fd which is writable only. But for now
        # we'll just add this hack and set the `readable` member to false.
        # Test: ./node test/fixtures/echo.js < /etc/passwd
        stream.readable = false
        stream.read = null
        stream._type = "pipe"
        
        # FIXME Hack to have stream not keep the event loop alive.
        # See https://github.com/joyent/node/issues/1726
        stream._handle.unref()  if stream._handle and stream._handle.unref
      else
        
        # Probably an error on in uv_guess_handle()
        throw new Error("Implement me. Unknown stream file type!")
    
    # For supporting legacy API we put the FD here.
    stream.fd = fd
    stream._isStdio = true
    stream
  
  # It could be that process has been started with an IPC channel
  # sitting on fd=0, in such case the pipe for this fd is already
  # present and creating a new one will lead to the assertion failure
  # in libuv.
  
  # Probably an error on in uv_guess_handle()
  
  # For supporting legacy API we put the FD here.
  
  # stdin starts out life in a paused state, but node doesn't
  # know yet.  Explicitly to readStop() it to put it in the
  # not-reading state.
  
  # if the user calls stdin.pause(), then we need to stop reading
  # immediately, so that the process can close down.
  
  # preserve null signal
  
  # Load events module in order to access prototype elements on process like
  # process.addListener.
  
  # Wrap addListener for the special signal types
  
  # If we were spawned with env NODE_CHANNEL_FD then load that up and
  # start parsing data from that stream.
  
  # Make sure it's not accidentally inherited by child processes.
  
  # Load tcp_wrap to avoid situation where we might immediately receive
  # a message.
  # FIXME is this really necessary?
  
  # Make process.argv[0] into a full path, but only touch argv[0] if it's
  # not a system $PATH lookup.
  # TODO: Make this work on Windows as well.  Note that "node" might
  # execute cwd\node.exe, or some %PATH%\node.exe on Windows,
  # and that every directory has its own cwd, so d:node.exe is valid.
  
  # Below you find a minimal module system, which is used to load the node
  # core modules found in lib/*.js. All core modules are compiled into the
  # node binary, so they can be loaded faster.
  runInThisContext = (code, options) ->
    script = new ContextifyScript(code, options)
    script.runInThisContext()
  NativeModule = (id) ->
    @filename = id + ".js"
    @id = id
    @exports = {}
    @loaded = false
    return
  @global = this
  startup.globalVariables = ->
    global.process = process
    global.global = global
    global.GLOBAL = global
    global.root = global
    global.Buffer = NativeModule.require("buffer").Buffer
    process.domain = null
    process._exiting = false
    return

  startup.globalTimeouts = ->
    global.setTimeout = ->
      t = NativeModule.require("timers")
      t.setTimeout.apply this, arguments

    global.setInterval = ->
      t = NativeModule.require("timers")
      t.setInterval.apply this, arguments

    global.clearTimeout = ->
      t = NativeModule.require("timers")
      t.clearTimeout.apply this, arguments

    global.clearInterval = ->
      t = NativeModule.require("timers")
      t.clearInterval.apply this, arguments

    global.setImmediate = ->
      t = NativeModule.require("timers")
      t.setImmediate.apply this, arguments

    global.clearImmediate = ->
      t = NativeModule.require("timers")
      t.clearImmediate.apply this, arguments

    return

  startup.globalConsole = ->
    global.__defineGetter__ "console", ->
      NativeModule.require "console"

    return

  startup._lazyConstants = null
  startup.lazyConstants = ->
    startup._lazyConstants = process.binding("constants")  unless startup._lazyConstants
    startup._lazyConstants

  startup.processFatal = ->
    process._fatalException = (er) ->
      caught = undefined
      caught = process.domain._errorHandler(er) or caught  if process.domain and process.domain._errorHandler
      caught = process.emit("uncaughtException", er)  unless caught
      unless caught
        try
          unless process._exiting
            process._exiting = true
            process.emit "exit", 1
      else
        NativeModule.require("timers").setImmediate process._tickCallback
      caught

    return

  assert = undefined
  startup.processAssert = ->
    assert = process.assert = (x, msg) ->
      throw new Error(msg or "assertion error")  unless x
      return

    return

  startup.processConfig = ->
    config = NativeModule._source.config
    delete NativeModule._source.config

    config = config.split("\n").slice(1).join("\n").replace(/"/g, "\\\"").replace(/'/g, "\"")
    process.config = JSON.parse(config, (key, value) ->
      return true  if value is "true"
      return false  if value is "false"
      value
    )
    return

  startup.processNextTick = ->
    tickDone = ->
      if tickInfo[kLength] isnt 0
        if tickInfo[kLength] <= tickInfo[kIndex]
          nextTickQueue = []
          tickInfo[kLength] = 0
        else
          nextTickQueue.splice 0, tickInfo[kIndex]
          tickInfo[kLength] = nextTickQueue.length
      tickInfo[kIndex] = 0
      return
    scheduleMicrotasks = ->
      return  if microtasksScheduled
      nextTickQueue.push
        callback: runMicrotasksCallback
        domain: null

      tickInfo[kLength]++
      microtasksScheduled = true
      return
    runMicrotasksCallback = ->
      microtasksScheduled = false
      _runMicrotasks()
      scheduleMicrotasks()  if tickInfo[kIndex] < tickInfo[kLength]
      return
    _tickCallback = ->
      callback = undefined
      threw = undefined
      tock = undefined
      scheduleMicrotasks()
      while tickInfo[kIndex] < tickInfo[kLength]
        tock = nextTickQueue[tickInfo[kIndex]++]
        callback = tock.callback
        threw = true
        try
          callback()
          threw = false
        finally
          tickDone()  if threw
        tickDone()  if 1e4 < tickInfo[kIndex]
      tickDone()
      return
    _tickDomainCallback = ->
      callback = undefined
      domain = undefined
      threw = undefined
      tock = undefined
      scheduleMicrotasks()
      while tickInfo[kIndex] < tickInfo[kLength]
        tock = nextTickQueue[tickInfo[kIndex]++]
        callback = tock.callback
        domain = tock.domain
        domain.enter()  if domain
        threw = true
        try
          callback()
          threw = false
        finally
          tickDone()  if threw
        tickDone()  if 1e4 < tickInfo[kIndex]
        domain.exit()  if domain
      tickDone()
      return
    nextTick = (callback) ->
      return  if process._exiting
      obj =
        callback: callback
        domain: process.domain or null

      nextTickQueue.push obj
      tickInfo[kLength]++
      return
    nextTickQueue = []
    microtasksScheduled = false
    _runMicrotasks = {}
    tickInfo = {}
    kIndex = 0
    kLength = 1
    process.nextTick = nextTick
    process._tickCallback = _tickCallback
    process._tickDomainCallback = _tickDomainCallback
    process._setupNextTick tickInfo, _tickCallback, _runMicrotasks
    _runMicrotasks = _runMicrotasks.runMicrotasks
    return

  startup.processStdio = ->
    stdin = undefined
    stdout = undefined
    stderr = undefined
    process.__defineGetter__ "stdout", ->
      return stdout  if stdout
      stdout = createWritableStdioStream(1)
      stdout.destroy = stdout.destroySoon = (er) ->
        er = er or new Error("process.stdout cannot be closed.")
        stdout.emit "error", er
        return

      if stdout.isTTY
        process.on "SIGWINCH", ->
          stdout._refreshSize()
          return

      stdout

    process.__defineGetter__ "stderr", ->
      return stderr  if stderr
      stderr = createWritableStdioStream(2)
      stderr.destroy = stderr.destroySoon = (er) ->
        er = er or new Error("process.stderr cannot be closed.")
        stderr.emit "error", er
        return

      stderr

    process.__defineGetter__ "stdin", ->
      return stdin  if stdin
      tty_wrap = process.binding("tty_wrap")
      fd = 0
      switch tty_wrap.guessHandleType(fd)
        when "TTY"
          tty = NativeModule.require("tty")
          stdin = new tty.ReadStream(fd,
            highWaterMark: 0
            readable: true
            writable: false
          )
        when "FILE"
          fs = NativeModule.require("fs")
          stdin = new fs.ReadStream(null,
            fd: fd
            autoClose: false
          )
        when "PIPE", "TCP"
          net = NativeModule.require("net")
          if process._channel and process._channel.fd is fd
            stdin = new net.Socket(
              handle: process._channel
              readable: true
              writable: false
            )
          else
            stdin = new net.Socket(
              fd: fd
              readable: true
              writable: false
            )
        else
          throw new Error("Implement me. Unknown stdin file type!")
      stdin.fd = fd
      if stdin._handle and stdin._handle.readStop
        stdin._handle.reading = false
        stdin._readableState.reading = false
        stdin._handle.readStop()
      stdin.on "pause", ->
        return  unless stdin._handle
        stdin._readableState.reading = false
        stdin._handle.reading = false
        stdin._handle.readStop()
        return

      stdin

    process.openStdin = ->
      process.stdin.resume()
      process.stdin

    return

  startup.processKillAndExit = ->
    process.exit = (code) ->
      process.exitCode = code  if code or code is 0
      unless process._exiting
        process._exiting = true
        process.emit "exit", process.exitCode or 0
      process.reallyExit process.exitCode or 0
      return

    process.kill = (pid, sig) ->
      err = undefined
      throw new TypeError("invalid pid")  unless pid is (pid | 0)
      if 0 is sig
        err = process._kill(pid, 0)
      else
        sig = sig or "SIGTERM"
        if startup.lazyConstants()[sig] and sig.slice(0, 3) is "SIG"
          err = process._kill(pid, startup.lazyConstants()[sig])
        else
          throw new Error("Unknown signal: " + sig)
      if err
        errnoException = NativeModule.require("util")._errnoException
        throw errnoException(err, "kill")
      true

    return

  startup.processSignalHandlers = ->
    isSignal = (event) ->
      event.slice(0, 3) is "SIG" and startup.lazyConstants().hasOwnProperty(event)
    signalWraps = {}
    addListener = process.addListener
    removeListener = process.removeListener
    process.on = process.addListener = (type, listener) ->
      if isSignal(type) and not signalWraps.hasOwnProperty(type)
        Signal = process.binding("signal_wrap").Signal
        wrap = new Signal()
        wrap.unref()
        wrap.onsignal = ->
          process.emit type
          return

        signum = startup.lazyConstants()[type]
        err = wrap.start(signum)
        if err
          wrap.close()
          errnoException = NativeModule.require("util")._errnoException
          throw errnoException(err, "uv_signal_start")
        signalWraps[type] = wrap
      addListener.apply this, arguments

    process.removeListener = (type, listener) ->
      ret = removeListener.apply(this, arguments)
      if isSignal(type)
        assert signalWraps.hasOwnProperty(type)
        if NativeModule.require("events").listenerCount(this, type) is 0
          signalWraps[type].close()
          delete signalWraps[type]
      ret

    return

  startup.processChannel = ->
    if process.env.NODE_CHANNEL_FD
      fd = parseInt(process.env.NODE_CHANNEL_FD, 10)
      assert fd >= 0
      delete process.env.NODE_CHANNEL_FD

      cp = NativeModule.require("child_process")
      process.binding "tcp_wrap"
      cp._forkChild fd
      assert process.send
    return

  startup.processRawDebug = ->
    format = NativeModule.require("util").format
    rawDebug = process._rawDebug
    process._rawDebug = ->
      rawDebug format.apply(null, arguments)
      return

    return

  startup.resolveArgv0 = ->
    cwd = process.cwd()
    isWindows = process.platform is "win32"
    argv0 = process.argv[0]
    if not isWindows and argv0.indexOf("/") isnt -1 and argv0.charAt(0) isnt "/"
      path = NativeModule.require("path")
      process.argv[0] = path.join(cwd, process.argv[0])
    return

  ContextifyScript = process.binding("contextify").ContextifyScript
  NativeModule._source = process.binding("natives")
  NativeModule._cache = {}
  NativeModule.require = (id) ->
    return NativeModule  if id is "native_module"
    cached = NativeModule.getCached(id)
    return cached.exports  if cached
    throw new Error("No such native module " + id)  unless NativeModule.exists(id)
    process.moduleLoadList.push "NativeModule " + id
    nativeModule = new NativeModule(id)
    nativeModule.cache()
    nativeModule.compile()
    nativeModule.exports

  NativeModule.getCached = (id) ->
    NativeModule._cache[id]

  NativeModule.exists = (id) ->
    NativeModule._source.hasOwnProperty id

  NativeModule.getSource = (id) ->
    NativeModule._source[id]

  NativeModule.wrap = (script) ->
    NativeModule.wrapper[0] + script + NativeModule.wrapper[1]

  NativeModule.wrapper = [
    "(function (exports, require, module, __filename, __dirname) { "
    "\n});"
  ]
  NativeModule::compile = ->
    source = NativeModule.getSource(@id)
    source = NativeModule.wrap(source)
    fn = runInThisContext(source,
      filename: @filename
    )
    fn @exports, NativeModule.require, this, @filename
    @loaded = true
    return

  NativeModule::cache = ->
    NativeModule._cache[@id] = this
    return

  startup()
  return
