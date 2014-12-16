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
Worker = (options) ->
  return new Worker(options)  unless this instanceof Worker
  EventEmitter.call this
  options = {}  unless util.isObject(options)
  @suicide = `undefined`
  @state = options.state or "none"
  @id = options.id | 0
  if options.process
    @process = options.process
    @process.on "error", @emit.bind(this, "error")
    @process.on "message", @emit.bind(this, "message")
  return

# Master/worker specific methods are defined in the *Init() functions.
SharedHandle = (key, address, port, addressType, backlog, fd) ->
  @key = key
  @workers = []
  @handle = null
  @errno = 0
  
  # FIXME(bnoordhuis) Polymorphic return type for lack of a better solution.
  rval = undefined
  if addressType is "udp4" or addressType is "udp6"
    rval = dgram._createSocketHandle(address, port, addressType, fd)
  else
    rval = net._createServerHandle(address, port, addressType, fd)
  if util.isNumber(rval)
    @errno = rval
  else
    @handle = rval
  return

# Start a round-robin server. Master accepts connections and distributes
# them over the workers.
RoundRobinHandle = (key, address, port, addressType, backlog, fd) ->
  @key = key
  @all = {}
  @free = []
  @handles = []
  @handle = null
  @server = net.createServer(assert.fail)
  if fd >= 0
    @server.listen fd: fd
  else if port >= 0
    @server.listen port, address
  else # UNIX socket path.
    @server.listen address
  self = this
  @server.once "listening", ->
    self.handle = self.server._handle
    self.handle.onconnection = self.distribute.bind(self)
    self.server._handle = null
    self.server = null
    return

  return

# TODO(bnoordhuis) Check err.
# UNIX socket.
# In case there are connections pending.

# Still busy binding.

# Hack: translate 'EADDRINUSE' error string back to numeric error code.
# It works but ideally we'd have some backchannel between the net and
# cluster modules for stuff like this.
# Worker is closing (or has closed) the server.
# Add to ready queue again.
# Worker is shutting down. Send to another.
masterInit = ->
  
  # XXX(bnoordhuis) Fold cluster.schedulingPolicy into cluster.settings?
  
  # FIXME Round-robin doesn't perform well on Windows right now due to the
  # way IOCP is wired up. Bert is going to fix that, eventually.
  # Leave it to the operating system.
  # Master distributes connections.
  
  # Keyed on address:port:etc. When a worker dies, we walk over the handles
  # and remove() the worker from each one. remove() may do a linear scan
  # itself so we might end up with an O(n*m) operation. Ergo, FIXME.
  
  # Tell V8 to write profile data for each process to a separate file.
  # Without --logfile=v8-%p.log, everything ends up in a single, unusable
  # file. (Unusable because what V8 logs are memory addresses and each
  # process has its own memory mappings.)
  # Freeze policy.
  
  # Send debug signal only if not started in debug mode, this helps a lot
  # on windows, because RegisterDebugHandler is not called when node starts
  # with --debug.* arg.
  createWorkerProcess = (id, env) ->
    workerEnv = util._extend({}, process.env)
    execArgv = cluster.settings.execArgv.slice()
    debugPort = process.debugPort + id
    hasDebugArg = false
    workerEnv = util._extend(workerEnv, env)
    workerEnv.NODE_UNIQUE_ID = "" + id
    i = 0

    while i < execArgv.length
      match = execArgv[i].match(/^(--debug|--debug-brk)(=\d+)?$/)
      if match
        execArgv[i] = match[1] + "=" + debugPort
        hasDebugArg = true
      i++
    execArgv = ["--debug-port=" + debugPort].concat(execArgv)  unless hasDebugArg
    fork cluster.settings.exec, cluster.settings.args,
      env: workerEnv
      silent: cluster.settings.silent
      execArgv: execArgv
      gid: cluster.settings.gid
      uid: cluster.settings.uid

  
  #
  #       * Remove the worker from the workers list only
  #       * if it has disconnected, otherwise we might
  #       * still want to access it.
  #       
  
  #
  #       * Now is a good time to remove the handles
  #       * associated with this worker because it is
  #       * not connected to the master anymore.
  #       
  
  #
  #       * Remove the worker from the workers list only
  #       * if its process has exited. Otherwise, we might
  #       * still want to access it.
  #       
  onmessage = (message, handle) ->
    worker = this
    if message.act is "online"
      online worker
    else if message.act is "queryServer"
      queryServer worker, message
    else if message.act is "listening"
      listening worker, message
    else if message.act is "suicide"
      worker.suicide = true
    else close worker, message  if message.act is "close"
    return
  online = (worker) ->
    worker.state = "online"
    worker.emit "online"
    cluster.emit "online", worker
    return
  queryServer = (worker, message) ->
    args = [
      message.address
      message.port
      message.addressType
      message.fd
    ]
    key = args.join(":")
    handle = handles[key]
    if util.isUndefined(handle)
      constructor = RoundRobinHandle
      
      # UDP is exempt from round-robin connection balancing for what should
      # be obvious reasons: it's connectionless. There is nothing to send to
      # the workers except raw datagrams and that's pointless.
      constructor = SharedHandle  if schedulingPolicy isnt SCHED_RR or message.addressType is "udp4" or message.addressType is "udp6"
      handles[key] = handle = new constructor(key, message.address, message.port, message.addressType, message.backlog, message.fd)
    handle.data = message.data  unless handle.data
    
    # Set custom server data
    handle.add worker, (errno, reply, handle) ->
      reply = util._extend(
        errno: errno
        key: key
        ack: message.seq
        data: handles[key].data
      , reply)
      delete handles[key]  if errno # Gives other workers a chance to retry.
      send worker, reply, handle
      return

    return
  listening = (worker, message) ->
    info =
      addressType: message.addressType
      address: message.address
      port: message.port
      fd: message.fd

    worker.state = "listening"
    worker.emit "listening", info
    cluster.emit "listening", worker, info
    return
  
  # Round-robin only. Server in worker is closing, remove from list.
  close = (worker, message) ->
    key = message.key
    handle = handles[key]
    delete handles[key]  if handle.remove(worker)
    return
  send = (worker, message, handle, cb) ->
    sendHelper worker.process, message, handle, cb
    return
  cluster.workers = {}
  intercom = new EventEmitter
  cluster.settings = {}
  schedulingPolicy =
    none: SCHED_NONE
    rr: SCHED_RR
  [{process.env.NODE_CLUSTER_SCHED_POLICY}]
  schedulingPolicy = (if (process.platform is "win32") then SCHED_NONE else SCHED_RR)  if util.isUndefined(schedulingPolicy)
  cluster.schedulingPolicy = schedulingPolicy
  cluster.SCHED_NONE = SCHED_NONE
  cluster.SCHED_RR = SCHED_RR
  handles = {}
  initialized = false
  cluster.setupMaster = (options) ->
    settings =
      args: process.argv.slice(2)
      exec: process.argv[1]
      execArgv: process.execArgv
      silent: false

    settings = util._extend(settings, cluster.settings)
    settings = util._extend(settings, options or {})
    settings.execArgv = settings.execArgv.concat(["--logfile=v8-%p.log"])  if settings.execArgv.some((s) ->
      /^--prof/.test s
    ) and not settings.execArgv.some((s) ->
      /^--logfile=/.test s
    )
    cluster.settings = settings
    if initialized is true
      return process.nextTick(->
        cluster.emit "setup", settings
        return
      )
    initialized = true
    schedulingPolicy = cluster.schedulingPolicy
    assert schedulingPolicy is SCHED_NONE or schedulingPolicy is SCHED_RR, "Bad cluster.schedulingPolicy: " + schedulingPolicy
    hasDebugArg = process.execArgv.some((argv) ->
      /^(--debug|--debug-brk)(=\d+)?$/.test argv
    )
    process.nextTick ->
      cluster.emit "setup", settings
      return

    return  if hasDebugArg
    process.on "internalMessage", (message) ->
      return  if message.cmd isnt "NODE_DEBUG_ENABLED"
      key = undefined
      for key of cluster.workers
        worker = cluster.workers[key]
        if worker.state is "online"
          process._debugProcess worker.process.pid
        else
          worker.once "online", ->
            process._debugProcess @process.pid
            return

      return

    return

  ids = 0
  cluster.fork = (env) ->
    removeWorker = (worker) ->
      assert worker
      delete cluster.workers[worker.id]

      if Object.keys(cluster.workers).length is 0
        assert Object.keys(handles).length is 0, "Resource leak detected."
        intercom.emit "disconnect"
      return
    removeHandlesForWorker = (worker) ->
      assert worker
      for key of handles
        handle = handles[key]
        delete handles[key]  if handle.remove(worker)
      return
    cluster.setupMaster()
    id = ++ids
    workerProcess = createWorkerProcess(id, env)
    worker = new Worker(
      id: id
      process: workerProcess
    )
    worker.process.once "exit", (exitCode, signalCode) ->
      removeWorker worker  unless worker.isConnected()
      worker.suicide = !!worker.suicide
      worker.state = "dead"
      worker.emit "exit", exitCode, signalCode
      cluster.emit "exit", worker, exitCode, signalCode
      return

    worker.process.once "disconnect", ->
      removeHandlesForWorker worker
      removeWorker worker  if worker.isDead()
      worker.suicide = !!worker.suicide
      worker.state = "disconnected"
      worker.emit "disconnect"
      cluster.emit "disconnect", worker
      return

    worker.process.on "internalMessage", internal(worker, onmessage)
    process.nextTick ->
      cluster.emit "fork", worker
      return

    cluster.workers[worker.id] = worker
    worker

  cluster.disconnect = (cb) ->
    workers = Object.keys(cluster.workers)
    if workers.length is 0
      process.nextTick intercom.emit.bind(intercom, "disconnect")
    else
      for key of workers
        key = workers[key]
        cluster.workers[key].disconnect()
    intercom.once "disconnect", cb  if cb
    return

  Worker::disconnect = ->
    @suicide = true
    send this,
      act: "disconnect"

    return

  Worker::destroy = (signo) ->
    signo = signo or "SIGTERM"
    proc = @process
    if @isConnected()
      @once "disconnect", proc.kill.bind(proc, signo)
      @disconnect()
      return
    proc.kill signo
    return

  return
workerInit = ->
  
  # Called from src/node.js
  
  # Unexpected disconnect, master exited, or some such nastiness, so
  # worker exits immediately.
  
  # obj is a net#Server or a dgram#Socket object.
  
  # Set custom data on handle (i.e. tls tickets key)
  # Shared listen socket.
  # Round-robin.
  
  # Shared listen socket.
  shared = (message, handle, cb) ->
    key = message.key
    
    # Monkey-patch the close() method so we can keep track of when it's
    # closed. Avoids resource leaks when the handle is short-lived.
    close = handle.close
    handle.close = ->
      delete handles[key]

      close.apply this, arguments

    assert util.isUndefined(handles[key])
    handles[key] = handle
    cb message.errno, handle
    return
  
  # Round-robin. Master distributes handles across workers.
  rr = (message, cb) ->
    listen = (backlog) ->
      
      # TODO(bnoordhuis) Send a message to the master that tells it to
      # update the backlog size. The actual backlog should probably be
      # the largest requested size by any worker.
      0
    close = ->
      
      # lib/net.js treats server._handle.close() as effectively synchronous.
      # That means there is a time window between the call to close() and
      # the ack by the master process in which we can still receive handles.
      # onconnection() below handles that by sending those handles back to
      # the master.
      return  if util.isUndefined(key)
      send
        act: "close"
        key: key

      delete handles[key]

      key = `undefined`
      return
    getsockname = (out) ->
      util._extend out, message.sockname  if key
      0
    return cb(message.errno, null)  if message.errno
    key = message.key
    
    # Faux handle. Mimics a TCPWrap with just enough fidelity to get away
    # with it. Fools net.Server into thinking that it's backed by a real
    # handle.
    handle =
      close: close
      listen: listen

    handle.getsockname = getsockname  if message.sockname # TCP handles only.
    assert util.isUndefined(handles[key])
    handles[key] = handle
    cb 0, handle
    return
  
  # Round-robin connection.
  onconnection = (message, handle) ->
    key = message.key
    server = handles[key]
    accepted = not util.isUndefined(server)
    send
      ack: message.seq
      accepted: accepted

    server.onconnection 0, handle  if accepted
    return
  send = (message, cb) ->
    sendHelper process, message, null, cb
    return
  handles = {}
  cluster._setupWorker = ->
    onmessage = (message, handle) ->
      if message.act is "newconn"
        onconnection message, handle
      else worker.disconnect()  if message.act is "disconnect"
      return
    worker = new Worker(
      id: +process.env.NODE_UNIQUE_ID | 0
      process: process
      state: "online"
    )
    cluster.worker = worker
    process.once "disconnect", ->
      process.exit 0  unless worker.suicide
      return

    process.on "internalMessage", internal(worker, onmessage)
    send act: "online"
    return

  cluster._getServer = (obj, address, port, addressType, fd, cb) ->
    message =
      addressType: addressType
      address: address
      port: port
      act: "queryServer"
      fd: fd
      data: null

    message.data = obj._getServerData()  if obj._getServerData
    send message, (reply, handle) ->
      obj._setServerData reply.data  if obj._setServerData
      if handle
        shared reply, handle, cb
      else
        rr reply, cb
      return

    obj.once "listening", ->
      cluster.worker.state = "listening"
      address = obj.address()
      message.act = "listening"
      message.port = address and address.port or port
      send message
      return

    return

  Worker::disconnect = ->
    @suicide = true
    for key of handles
      handle = handles[key]
      delete handles[key]

      handle.close()
    process.disconnect()
    return

  Worker::destroy = ->
    @suicide = true
    process.exit 0  unless @isConnected()
    exit = process.exit.bind(null, 0)
    send
      act: "suicide"
    , exit
    process.once "disconnect", exit
    process.disconnect()
    return

  return
sendHelper = (proc, message, handle, cb) ->
  
  # Mark message as internal. See INTERNAL_PREFIX in lib/child_process.js
  message = util._extend(
    cmd: "NODE_CLUSTER"
  , message)
  callbacks[seq] = cb  if cb
  message.seq = seq
  seq += 1
  proc.send message, handle
  return

# Returns an internalMessage listener that hands off normal messages
# to the callback but intercepts and redirects ACK messages.
internal = (worker, cb) ->
  (message, handle) ->
    return  if message.cmd isnt "NODE_CLUSTER"
    fn = cb
    unless util.isUndefined(message.ack)
      fn = callbacks[message.ack]
      delete callbacks[message.ack]
    fn.apply worker, arguments
    return
"use strict"
EventEmitter = require("events").EventEmitter
assert = require("assert")
dgram = require("dgram")
fork = require("child_process").fork
net = require("net")
util = require("util")
SCHED_NONE = 1
SCHED_RR = 2
cluster = new EventEmitter
module.exports = cluster
cluster.Worker = Worker
cluster.isWorker = ("NODE_UNIQUE_ID" of process.env)
cluster.isMaster = (cluster.isWorker is false)
util.inherits Worker, EventEmitter
Worker::kill = ->
  @destroy.apply this, arguments
  return

Worker::send = ->
  @process.send.apply @process, arguments
  return

Worker::isDead = isDead = ->
  @process.exitCode? or @process.signalCode?

Worker::isConnected = isConnected = ->
  @process.connected

SharedHandle::add = (worker, send) ->
  assert @workers.indexOf(worker) is -1
  @workers.push worker
  send @errno, null, @handle
  return

SharedHandle::remove = (worker) ->
  index = @workers.indexOf(worker)
  assert index isnt -1
  @workers.splice index, 1
  return false  if @workers.length isnt 0
  @handle.close()
  @handle = null
  true

RoundRobinHandle::add = (worker, send) ->
  done = ->
    if self.handle.getsockname
      out = {}
      err = self.handle.getsockname(out)
      send null,
        sockname: out
      , null
    else
      send null, null, null
    self.handoff worker
    return
  assert worker.id of @all is false
  @all[worker.id] = worker
  self = this
  return done()  if util.isNull(@server)
  @server.once "listening", done
  @server.once "error", (err) ->
    errno = process.binding("uv")["UV_" + err.errno]
    send errno, null
    return

  return

RoundRobinHandle::remove = (worker) ->
  return false  if worker.id of @all is false
  delete @all[worker.id]

  index = @free.indexOf(worker)
  @free.splice index, 1  if index isnt -1
  return false  if Object.getOwnPropertyNames(@all).length isnt 0
  handle = undefined

  while handle = @handles.shift()
    handle.close()
  @handle.close()
  @handle = null
  true

RoundRobinHandle::distribute = (err, handle) ->
  @handles.push handle
  worker = @free.shift()
  @handoff worker  if worker
  return

RoundRobinHandle::handoff = (worker) ->
  return  if worker.id of @all is false
  handle = @handles.shift()
  if util.isUndefined(handle)
    @free.push worker
    return
  message =
    act: "newconn"
    key: @key

  self = this
  sendHelper worker.process, message, handle, (reply) ->
    if reply.accepted
      handle.close()
    else
      self.distribute 0, handle
    self.handoff worker
    return

  return

if cluster.isMaster
  masterInit()
else
  workerInit()
seq = 0
callbacks = {}
