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

# Maintainers, keep in mind that octal literals are not allowed
# in strict mode. Use the decimal value and add a comment with
# the octal value. Example:
#
#   var mode = 438; /* mode=0666 */
rethrow = ->
  
  # Only enable in debug mode. A backtrace uses ~1000 bytes of heap space and
  # is fairly slow to generate.
  if DEBUG
    backtrace = new Error
    return (err) ->
      if err
        backtrace.stack = err.name + ": " + err.message + backtrace.stack.substr(backtrace.name.length)
        err = backtrace
        throw err
      return
  (err) ->
    throw err  if err # Forgot a callback but don't know where? Use NODE_DEBUG=fs
    return
maybeCallback = (cb) ->
  (if util.isFunction(cb) then cb else rethrow())

# Ensure that callbacks run in the global context. Only use this function
# for callbacks that are passed to the binding layer, callbacks that are
# invoked from JS already run in the proper scope.
makeCallback = (cb) ->
  return rethrow()  unless util.isFunction(cb)
  ->
    cb.apply null, arguments
assertEncoding = (encoding) ->
  throw new Error("Unknown encoding: " + encoding)  if encoding and not Buffer.isEncoding(encoding)
  return
nullCheck = (path, callback) ->
  if ("" + path).indexOf("\u0000") isnt -1
    er = new Error("Path must be a string without null bytes.")
    throw er  unless callback
    process.nextTick ->
      callback er
      return

    return false
  true

# Static method to set the stats properties on a Stats object.

# Create a C++ binding to the function which creates a Stats object.

# first, stat the file, so we know the size.
# single buffer with file data
# list for when size is unknown
#=0666

# the kernel lies about many files.
# Go ahead and try to read some bytes.

# unknown size, just read until we don't get bytes.

# collected the data into the buffers list.
#=0666
# single buffer with file data
# list for when size is unknown

# the kernel lies about many files.
# Go ahead and try to read some bytes.

# data was collected into the buffers list.

# Used by binding.open and friends
stringToFlags = (flag) ->
  
  # Only mess with strings
  return flag  unless util.isString(flag)
  switch flag
    when "r"
      return O_RDONLY
    # fall through
    when "rs", "sr"
      return O_RDONLY | O_SYNC
    when "r+"
      return O_RDWR
    # fall through
    when "rs+", "sr+"
      return O_RDWR | O_SYNC
    when "w"
      return O_TRUNC | O_CREAT | O_WRONLY
    # fall through
    when "wx", "xw"
      return O_TRUNC | O_CREAT | O_WRONLY | O_EXCL
    when "w+"
      return O_TRUNC | O_CREAT | O_RDWR
    # fall through
    when "wx+", "xw+"
      return O_TRUNC | O_CREAT | O_RDWR | O_EXCL
    when "a"
      return O_APPEND | O_CREAT | O_WRONLY
    # fall through
    when "ax", "xa"
      return O_APPEND | O_CREAT | O_WRONLY | O_EXCL
    when "a+"
      return O_APPEND | O_CREAT | O_RDWR
    # fall through
    when "ax+", "xa+"
      return O_APPEND | O_CREAT | O_RDWR | O_EXCL
  throw new Error("Unknown file open flag: " + flag)return

# exported but hidden, only used by test/simple/test-fs-open-flags.js

# Yes, the follow could be easily DRYed up but I provide the explicit
# list to make the arguments clear.
modeNum = (m, def) ->
  return m  if util.isNumber(m)
  return parseInt(m, 8)  if util.isString(m)
  return modeNum(def)  if def
  `undefined`
#=0666
#=0666

# legacy string interface (fd, length, position, encoding, callback)

# Retain a reference to buffer so that it can't be GC'ed too soon.

# legacy string interface (fd, length, position, encoding, callback)

# usage:
#  fs.write(fd, buffer, offset, length[, position], callback);
# OR
#  fs.write(fd, string[, position[, encoding]], callback);

# Retain a reference to buffer so that it can't be GC'ed too soon.

# retain reference to string in case it's external

# if no position is passed then assume null

# usage:
#  fs.writeSync(fd, buffer, offset, length[, position]);
# OR
#  fs.writeSync(fd, string[, position[, encoding]]);

# legacy

# allow error to be thrown, but still close fd.
#=0777
#=0777
preprocessSymlinkDestination = (path, type, linkPath) ->
  unless isWindows
    
    # No preprocessing is needed on Unix.
    path
  else if type is "junction"
    
    # Junctions paths need to be absolute and \\?\-prefixed.
    # A relative target is relative to the link's parent directory.
    path = pathModule.resolve(linkPath, "..", path)
    pathModule._makeLong path
  else
    
    # Windows symlinks don't tolerate forward slashes.
    ("" + path).replace /\//g, "\\"

# prefer to return the chmod error, if one occurs,
# but still try to close, and report closing errors if they occur.

# prefer to return the chmod error, if one occurs,
# but still try to close, and report closing errors if they occur.

# converts Date or number to a fractional UNIX timestamp
toUnixTimestamp = (time) ->
  return time  if util.isNumber(time)
  
  # convert to 123.456 UNIX timestamp
  return time.getTime() / 1000  if util.isDate(time)
  throw new Error("Cannot parse time: " + time)return

# exported for unit tests, not for public consumption
writeAll = (fd, buffer, offset, length, position, callback) ->
  callback = maybeCallback(arguments[arguments.length - 1])
  
  # write(fd, buffer, offset, length, position, callback)
  fs.write fd, buffer, offset, length, position, (writeErr, written) ->
    if writeErr
      fs.close fd, ->
        callback writeErr  if callback
        return

    else
      if written is length
        fs.close fd, callback
      else
        offset += written
        length -= written
        position += written
        writeAll fd, buffer, offset, length, position, callback
    return

  return
#=0666
#=0666
#=0666
#=0666
FSWatcher = ->
  EventEmitter.call this
  self = this
  FSEvent = process.binding("fs_event_wrap").FSEvent
  @_handle = new FSEvent()
  @_handle.owner = this
  @_handle.onchange = (status, event, filename) ->
    if status < 0
      self._handle.close()
      self.emit "error", errnoException(status, "watch")
    else
      self.emit "change", event, filename
    return

  return

# Stat Change Watchers
StatWatcher = ->
  EventEmitter.call this
  self = this
  @_handle = new binding.StatWatcher()
  
  # uv_fs_poll is a little more powerful than ev_stat but we curb it for
  # the sake of backwards compatibility
  oldStatus = -1
  @_handle.onchange = (current, previous, newStatus) ->
    return  if oldStatus is -1 and newStatus is -1 and current.nlink is previous.nlink
    oldStatus = newStatus
    self.emit "change", current, previous
    return

  @_handle.onstop = ->
    self.emit "stop"
    return

  return
inStatWatchers = (filename) ->
  Object::hasOwnProperty.call(statWatchers, filename) and statWatchers[filename]

# Poll interval in milliseconds. 5007 is what libev used to use. It's
# a little on the slow side but let's stick with it for now to keep
# behavioral changes to a minimum.

# Regexp that finds the next partion of a (partial) path
# result is [base_with_slash, base], e.g. ['somedir/', 'somedir']

# Regex to find the device root, including trailing slash. E.g. 'c:\\'.

# make p is absolute

# current character position in p

# the partial path so far, including a trailing slash if any

# the partial path without a trailing slash (except when pointing at a root)

# the partial path scanned in the previous round, with slash

# Skip over roots

# On windows, check that the root exists. On unix there is no need.

# walk down the path, swapping out linked pathparts for their real
# values
# NB: p.length changes.

# find the next part

# continue if not a symlink

# some known symbolic link.  no need to stat again.

# read the link if it wasn't read before
# dev/ino always return 0 on windows, so skip the check.

# track this, if given a cache.

# resolve the link, then start over

# make p is absolute

# current character position in p

# the partial path so far, including a trailing slash if any

# the partial path without a trailing slash (except when pointing at a root)

# the partial path scanned in the previous round, with slash

# Skip over roots

# On windows, check that the root exists. On unix there is no need.

# walk down the path, swapping out linked pathparts for their real
# values

# stop if scanned past end of path

# find the next part

# continue if not a symlink

# known symbolic link.  no need to stat again.

# if not a symlink, skip to the next path part

# stat & read the link if not read before
# call gotTarget as soon as the link target is known
# dev/ino always return 0 on windows, so skip the check.

# resolve the link, then start over
allocNewPool = (poolSize) ->
  pool = new Buffer(poolSize)
  pool.used = 0
  return
ReadStream = (path, options) ->
  return new ReadStream(path, options)  unless this instanceof ReadStream
  
  # a little bit bigger buffer and water marks by default
  options = util._extend(
    highWaterMark: 64 * 1024
  , options or {})
  Readable.call this, options
  @path = path
  @fd = (if options.hasOwnProperty("fd") then options.fd else null)
  @flags = (if options.hasOwnProperty("flags") then options.flags else "r")
  @mode = (if options.hasOwnProperty("mode") then options.mode else 438) #=0666
  @start = (if options.hasOwnProperty("start") then options.start else `undefined`)
  @end = (if options.hasOwnProperty("end") then options.end else `undefined`)
  @autoClose = (if options.hasOwnProperty("autoClose") then options.autoClose else true)
  @pos = `undefined`
  unless util.isUndefined(@start)
    throw TypeError("start must be a Number")  unless util.isNumber(@start)
    if util.isUndefined(@end)
      @end = Infinity
    else throw TypeError("end must be a Number")  unless util.isNumber(@end)
    throw new Error("start must be <= end")  if @start > @end
    @pos = @start
  @open()  unless util.isNumber(@fd)
  @on "end", ->
    @destroy()  if @autoClose
    return

  return
# support the legacy name

# start the flow of data.

# discard the old pool.

# Grab another reference to the pool in the case that while we're
# in the thread pool another read() finishes up the pool, and
# allocates a new one.

# already read everything we were supposed to read!
# treat as EOF.

# the actual read.

# move the pool positions, and internal position for reading.
WriteStream = (path, options) ->
  return new WriteStream(path, options)  unless this instanceof WriteStream
  options = options or {}
  Writable.call this, options
  @path = path
  @fd = null
  @fd = (if options.hasOwnProperty("fd") then options.fd else null)
  @flags = (if options.hasOwnProperty("flags") then options.flags else "w")
  @mode = (if options.hasOwnProperty("mode") then options.mode else 438) #=0666
  @start = (if options.hasOwnProperty("start") then options.start else `undefined`)
  @pos = `undefined`
  @bytesWritten = 0
  unless util.isUndefined(@start)
    throw TypeError("start must be a Number")  unless util.isNumber(@start)
    throw new Error("start must be >= zero")  if @start < 0
    @pos = @start
  @open()  unless util.isNumber(@fd)
  
  # dispose on finish.
  @once "finish", @close
  return
# support the legacy name

# There is no shutdown() for files.

# SyncWriteStream is internal. DO NOT USE.
# Temporary hack for process.stdout and process.stderr when piped to files.
SyncWriteStream = (fd, options) ->
  Stream.call this
  options = options or {}
  @fd = fd
  @writable = true
  @readable = false
  @autoClose = (if options.hasOwnProperty("autoClose") then options.autoClose else true)
  return
"use strict"
util = require("util")
pathModule = require("path")
binding = process.binding("fs")
constants = process.binding("constants")
fs = exports
Stream = require("stream").Stream
EventEmitter = require("events").EventEmitter
FSReqWrap = binding.FSReqWrap
Readable = Stream.Readable
Writable = Stream.Writable
kMinPoolSpace = 128
kMaxLength = require("smalloc").kMaxLength
O_APPEND = constants.O_APPEND or 0
O_CREAT = constants.O_CREAT or 0
O_EXCL = constants.O_EXCL or 0
O_RDONLY = constants.O_RDONLY or 0
O_RDWR = constants.O_RDWR or 0
O_SYNC = constants.O_SYNC or 0
O_TRUNC = constants.O_TRUNC or 0
O_WRONLY = constants.O_WRONLY or 0
F_OK = constants.F_OK or 0
R_OK = constants.R_OK or 0
W_OK = constants.W_OK or 0
X_OK = constants.X_OK or 0
isWindows = process.platform is "win32"
DEBUG = process.env.NODE_DEBUG and /fs/.test(process.env.NODE_DEBUG)
errnoException = util._errnoException
fs.Stats = (dev, mode, nlink, uid, gid, rdev, blksize, ino, size, blocks, atim_msec, mtim_msec, ctim_msec, birthtim_msec) ->
  @dev = dev
  @mode = mode
  @nlink = nlink
  @uid = uid
  @gid = gid
  @rdev = rdev
  @blksize = blksize
  @ino = ino
  @size = size
  @blocks = blocks
  @atime = new Date(atim_msec)
  @mtime = new Date(mtim_msec)
  @ctime = new Date(ctim_msec)
  @birthtime = new Date(birthtim_msec)
  return

binding.FSInitialize fs.Stats
fs.Stats::_checkModeProperty = (property) ->
  (@mode & constants.S_IFMT) is property

fs.Stats::isDirectory = ->
  @_checkModeProperty constants.S_IFDIR

fs.Stats::isFile = ->
  @_checkModeProperty constants.S_IFREG

fs.Stats::isBlockDevice = ->
  @_checkModeProperty constants.S_IFBLK

fs.Stats::isCharacterDevice = ->
  @_checkModeProperty constants.S_IFCHR

fs.Stats::isSymbolicLink = ->
  @_checkModeProperty constants.S_IFLNK

fs.Stats::isFIFO = ->
  @_checkModeProperty constants.S_IFIFO

fs.Stats::isSocket = ->
  @_checkModeProperty constants.S_IFSOCK

fs.F_OK = F_OK
fs.R_OK = R_OK
fs.W_OK = W_OK
fs.X_OK = X_OK
fs.access = (path, mode, callback) ->
  return  unless nullCheck(path, callback)
  if typeof mode is "function"
    callback = mode
    mode = F_OK
  else throw new TypeError("callback must be a function")  if typeof callback isnt "function"
  mode = mode | 0
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.access pathModule._makeLong(path), mode, req
  return

fs.accessSync = (path, mode) ->
  nullCheck path
  if mode is `undefined`
    mode = F_OK
  else
    mode = mode | 0
  binding.access pathModule._makeLong(path), mode
  return

fs.exists = (path, callback) ->
  cb = (err, stats) ->
    callback (if err then false else true)  if callback
    return
  return  unless nullCheck(path, cb)
  req = new FSReqWrap()
  req.oncomplete = cb
  binding.stat pathModule._makeLong(path), req
  return

fs.existsSync = (path) ->
  try
    nullCheck path
    binding.stat pathModule._makeLong(path)
    return true
  catch e
    return false
  return

fs.readFile = (path, options, callback_) ->
  read = ->
    if size is 0
      buffer = new Buffer(8192)
      fs.read fd, buffer, 0, 8192, -1, afterRead
    else
      fs.read fd, buffer, pos, size - pos, -1, afterRead
    return
  afterRead = (er, bytesRead) ->
    if er
      return fs.close(fd, (er2) ->
        callback er
      )
    return close()  if bytesRead is 0
    pos += bytesRead
    if size isnt 0
      if pos is size
        close()
      else
        read()
    else
      buffers.push buffer.slice(0, bytesRead)
      read()
    return
  close = ->
    fs.close fd, (er) ->
      if size is 0
        buffer = Buffer.concat(buffers, pos)
      else buffer = buffer.slice(0, pos)  if pos < size
      buffer = buffer.toString(encoding)  if encoding
      callback er, buffer

    return
  callback = maybeCallback(arguments[arguments.length - 1])
  if util.isFunction(options) or not options
    options =
      encoding: null
      flag: "r"
  else if util.isString(options)
    options =
      encoding: options
      flag: "r"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  encoding = options.encoding
  assertEncoding encoding
  size = undefined
  buffer = undefined
  buffers = undefined
  pos = 0
  fd = undefined
  flag = options.flag or "r"
  fs.open path, flag, 438, (er, fd_) ->
    return callback(er)  if er
    fd = fd_
    fs.fstat fd, (er, st) ->
      if er
        return fs.close(fd, ->
          callback er
          return
        )
      size = st.size
      if size is 0
        buffers = []
        return read()
      if size > kMaxLength
        err = new RangeError("File size is greater than possible Buffer: " + "0x3FFFFFFF bytes")
        return fs.close(fd, ->
          callback err
          return
        )
      buffer = new Buffer(size)
      read()
      return

    return

  return

fs.readFileSync = (path, options) ->
  unless options
    options =
      encoding: null
      flag: "r"
  else if util.isString(options)
    options =
      encoding: options
      flag: "r"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  encoding = options.encoding
  assertEncoding encoding
  flag = options.flag or "r"
  fd = fs.openSync(path, flag, 438)
  size = undefined
  threw = true
  try
    size = fs.fstatSync(fd).size
    threw = false
  finally
    fs.closeSync fd  if threw
  pos = 0
  buffer = undefined
  buffers = undefined
  if size is 0
    buffers = []
  else
    threw = true
    try
      buffer = new Buffer(size)
      threw = false
    finally
      fs.closeSync fd  if threw
  done = false
  until done
    threw = true
    try
      if size isnt 0
        bytesRead = fs.readSync(fd, buffer, pos, size - pos)
      else
        buffer = new Buffer(8192)
        bytesRead = fs.readSync(fd, buffer, 0, 8192)
        buffers.push buffer.slice(0, bytesRead)  if bytesRead
      threw = false
    finally
      fs.closeSync fd  if threw
    pos += bytesRead
    done = (bytesRead is 0) or (size isnt 0 and pos >= size)
  fs.closeSync fd
  if size is 0
    buffer = Buffer.concat(buffers, pos)
  else buffer = buffer.slice(0, pos)  if pos < size
  buffer = buffer.toString(encoding)  if encoding
  buffer

Object.defineProperty exports, "_stringToFlags",
  enumerable: false
  value: stringToFlags

fs.close = (fd, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.close fd, req
  return

fs.closeSync = (fd) ->
  binding.close fd

fs.open = (path, flags, mode, callback) ->
  callback = makeCallback(arguments[arguments.length - 1])
  mode = modeNum(mode, 438)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.open pathModule._makeLong(path), stringToFlags(flags), mode, req
  return

fs.openSync = (path, flags, mode) ->
  mode = modeNum(mode, 438)
  nullCheck path
  binding.open pathModule._makeLong(path), stringToFlags(flags), mode

fs.read = (fd, buffer, offset, length, position, callback) ->
  wrapper = (err, bytesRead) ->
    callback and callback(err, bytesRead or 0, buffer)
    return
  unless util.isBuffer(buffer)
    cb = arguments[4]
    encoding = arguments[3]
    assertEncoding encoding
    position = arguments[2]
    length = arguments[1]
    buffer = new Buffer(length)
    offset = 0
    callback = (err, bytesRead) ->
      return  unless cb
      str = (if (bytesRead > 0) then buffer.toString(encoding, 0, bytesRead) else "")
      (cb) err, str, bytesRead
      return
  req = new FSReqWrap()
  req.oncomplete = wrapper
  binding.read fd, buffer, offset, length, position, req
  return

fs.readSync = (fd, buffer, offset, length, position) ->
  legacy = false
  unless util.isBuffer(buffer)
    legacy = true
    encoding = arguments[3]
    assertEncoding encoding
    position = arguments[2]
    length = arguments[1]
    buffer = new Buffer(length)
    offset = 0
  r = binding.read(fd, buffer, offset, length, position)
  return r  unless legacy
  str = (if (r > 0) then buffer.toString(encoding, 0, r) else "")
  [
    str
    r
  ]

fs.write = (fd, buffer, offset, length, position, callback) ->
  strWrapper = (err, written) ->
    callback err, written or 0, buffer
    return
  bufWrapper = (err, written) ->
    callback err, written or 0, buffer
    return
  if util.isBuffer(buffer)
    if util.isFunction(position)
      callback = position
      position = null
    callback = maybeCallback(callback)
    req = new FSReqWrap()
    req.oncomplete = strWrapper
    return binding.writeBuffer(fd, buffer, offset, length, position, req)
  buffer += ""  if util.isString(buffer)
  unless util.isFunction(position)
    if util.isFunction(offset)
      position = offset
      offset = null
    else
      position = length
    length = "utf8"
  callback = maybeCallback(position)
  req = new FSReqWrap()
  req.oncomplete = bufWrapper
  binding.writeString fd, buffer, offset, length, req

fs.writeSync = (fd, buffer, offset, length, position) ->
  if util.isBuffer(buffer)
    position = null  if util.isUndefined(position)
    return binding.writeBuffer(fd, buffer, offset, length, position)
  buffer += ""  unless util.isString(buffer)
  offset = null  if util.isUndefined(offset)
  binding.writeString fd, buffer, offset, length, position

fs.rename = (oldPath, newPath, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(oldPath, callback)
  return  unless nullCheck(newPath, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.rename pathModule._makeLong(oldPath), pathModule._makeLong(newPath), req
  return

fs.renameSync = (oldPath, newPath) ->
  nullCheck oldPath
  nullCheck newPath
  binding.rename pathModule._makeLong(oldPath), pathModule._makeLong(newPath)

fs.truncate = (path, len, callback) ->
  if util.isNumber(path)
    req = new FSReqWrap()
    req.oncomplete = callback
    return fs.ftruncate(path, len, req)
  if util.isFunction(len)
    callback = len
    len = 0
  else len = 0  if util.isUndefined(len)
  callback = maybeCallback(callback)
  fs.open path, "r+", (er, fd) ->
    return callback(er)  if er
    req = new FSReqWrap()
    req.oncomplete = ftruncateCb = (er) ->
      fs.close fd, (er2) ->
        callback er or er2
        return

      return

    binding.ftruncate fd, len, req
    return

  return

fs.truncateSync = (path, len) ->
  return fs.ftruncateSync(path, len)  if util.isNumber(path)
  len = 0  if util.isUndefined(len)
  fd = fs.openSync(path, "r+")
  try
    ret = fs.ftruncateSync(fd, len)
  finally
    fs.closeSync fd
  ret

fs.ftruncate = (fd, len, callback) ->
  if util.isFunction(len)
    callback = len
    len = 0
  else len = 0  if util.isUndefined(len)
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.ftruncate fd, len, req
  return

fs.ftruncateSync = (fd, len) ->
  len = 0  if util.isUndefined(len)
  binding.ftruncate fd, len

fs.rmdir = (path, callback) ->
  callback = maybeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.rmdir pathModule._makeLong(path), req
  return

fs.rmdirSync = (path) ->
  nullCheck path
  binding.rmdir pathModule._makeLong(path)

fs.fdatasync = (fd, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.fdatasync fd, req
  return

fs.fdatasyncSync = (fd) ->
  binding.fdatasync fd

fs.fsync = (fd, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.fsync fd, req
  return

fs.fsyncSync = (fd) ->
  binding.fsync fd

fs.mkdir = (path, mode, callback) ->
  callback = mode  if util.isFunction(mode)
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.mkdir pathModule._makeLong(path), modeNum(mode, 511), req
  return

fs.mkdirSync = (path, mode) ->
  nullCheck path
  binding.mkdir pathModule._makeLong(path), modeNum(mode, 511)

fs.readdir = (path, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.readdir pathModule._makeLong(path), req
  return

fs.readdirSync = (path) ->
  nullCheck path
  binding.readdir pathModule._makeLong(path)

fs.fstat = (fd, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.fstat fd, req
  return

fs.lstat = (path, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.lstat pathModule._makeLong(path), req
  return

fs.stat = (path, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.stat pathModule._makeLong(path), req
  return

fs.fstatSync = (fd) ->
  binding.fstat fd

fs.lstatSync = (path) ->
  nullCheck path
  binding.lstat pathModule._makeLong(path)

fs.statSync = (path) ->
  nullCheck path
  binding.stat pathModule._makeLong(path)

fs.readlink = (path, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.readlink pathModule._makeLong(path), req
  return

fs.readlinkSync = (path) ->
  nullCheck path
  binding.readlink pathModule._makeLong(path)

fs.symlink = (destination, path, type_, callback) ->
  type = ((if util.isString(type_) then type_ else null))
  callback = makeCallback(arguments[arguments.length - 1])
  return  unless nullCheck(destination, callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.symlink preprocessSymlinkDestination(destination, type, path), pathModule._makeLong(path), type, req
  return

fs.symlinkSync = (destination, path, type) ->
  type = ((if util.isString(type) then type else null))
  nullCheck destination
  nullCheck path
  binding.symlink preprocessSymlinkDestination(destination, type, path), pathModule._makeLong(path), type

fs.link = (srcpath, dstpath, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(srcpath, callback)
  return  unless nullCheck(dstpath, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.link pathModule._makeLong(srcpath), pathModule._makeLong(dstpath), req
  return

fs.linkSync = (srcpath, dstpath) ->
  nullCheck srcpath
  nullCheck dstpath
  binding.link pathModule._makeLong(srcpath), pathModule._makeLong(dstpath)

fs.unlink = (path, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.unlink pathModule._makeLong(path), req
  return

fs.unlinkSync = (path) ->
  nullCheck path
  binding.unlink pathModule._makeLong(path)

fs.fchmod = (fd, mode, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.fchmod fd, modeNum(mode), req
  return

fs.fchmodSync = (fd, mode) ->
  binding.fchmod fd, modeNum(mode)

if constants.hasOwnProperty("O_SYMLINK")
  fs.lchmod = (path, mode, callback) ->
    callback = maybeCallback(callback)
    fs.open path, constants.O_WRONLY | constants.O_SYMLINK, (err, fd) ->
      if err
        callback err
        return
      fs.fchmod fd, mode, (err) ->
        fs.close fd, (err2) ->
          callback err or err2
          return

        return

      return

    return

  fs.lchmodSync = (path, mode) ->
    fd = fs.openSync(path, constants.O_WRONLY | constants.O_SYMLINK)
    err = undefined
    err2 = undefined
    try
      ret = fs.fchmodSync(fd, mode)
    catch er
      err = er
    try
      fs.closeSync fd
    catch er
      err2 = er
    throw (err or err2)  if err or err2
    ret
fs.chmod = (path, mode, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.chmod pathModule._makeLong(path), modeNum(mode), req
  return

fs.chmodSync = (path, mode) ->
  nullCheck path
  binding.chmod pathModule._makeLong(path), modeNum(mode)

if constants.hasOwnProperty("O_SYMLINK")
  fs.lchown = (path, uid, gid, callback) ->
    callback = maybeCallback(callback)
    fs.open path, constants.O_WRONLY | constants.O_SYMLINK, (err, fd) ->
      if err
        callback err
        return
      fs.fchown fd, uid, gid, callback
      return

    return

  fs.lchownSync = (path, uid, gid) ->
    fd = fs.openSync(path, constants.O_WRONLY | constants.O_SYMLINK)
    fs.fchownSync fd, uid, gid
fs.fchown = (fd, uid, gid, callback) ->
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.fchown fd, uid, gid, req
  return

fs.fchownSync = (fd, uid, gid) ->
  binding.fchown fd, uid, gid

fs.chown = (path, uid, gid, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.chown pathModule._makeLong(path), uid, gid, req
  return

fs.chownSync = (path, uid, gid) ->
  nullCheck path
  binding.chown pathModule._makeLong(path), uid, gid

fs._toUnixTimestamp = toUnixTimestamp
fs.utimes = (path, atime, mtime, callback) ->
  callback = makeCallback(callback)
  return  unless nullCheck(path, callback)
  req = new FSReqWrap()
  req.oncomplete = callback
  binding.utimes pathModule._makeLong(path), toUnixTimestamp(atime), toUnixTimestamp(mtime), req
  return

fs.utimesSync = (path, atime, mtime) ->
  nullCheck path
  atime = toUnixTimestamp(atime)
  mtime = toUnixTimestamp(mtime)
  binding.utimes pathModule._makeLong(path), atime, mtime
  return

fs.futimes = (fd, atime, mtime, callback) ->
  atime = toUnixTimestamp(atime)
  mtime = toUnixTimestamp(mtime)
  req = new FSReqWrap()
  req.oncomplete = makeCallback(callback)
  binding.futimes fd, atime, mtime, req
  return

fs.futimesSync = (fd, atime, mtime) ->
  atime = toUnixTimestamp(atime)
  mtime = toUnixTimestamp(mtime)
  binding.futimes fd, atime, mtime
  return

fs.writeFile = (path, data, options, callback) ->
  callback = maybeCallback(arguments[arguments.length - 1])
  if util.isFunction(options) or not options
    options =
      encoding: "utf8"
      mode: 438
      flag: "w"
  else if util.isString(options)
    options =
      encoding: options
      mode: 438
      flag: "w"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  assertEncoding options.encoding
  flag = options.flag or "w"
  fs.open path, flag, options.mode, (openErr, fd) ->
    if openErr
      callback openErr  if callback
    else
      buffer = (if util.isBuffer(data) then data else new Buffer("" + data, options.encoding or "utf8"))
      position = (if /a/.test(flag) then null else 0)
      writeAll fd, buffer, 0, buffer.length, position, callback
    return

  return

fs.writeFileSync = (path, data, options) ->
  unless options
    options =
      encoding: "utf8"
      mode: 438
      flag: "w"
  else if util.isString(options)
    options =
      encoding: options
      mode: 438
      flag: "w"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  assertEncoding options.encoding
  flag = options.flag or "w"
  fd = fs.openSync(path, flag, options.mode)
  data = new Buffer("" + data, options.encoding or "utf8")  unless util.isBuffer(data)
  written = 0
  length = data.length
  position = (if /a/.test(flag) then null else 0)
  try
    while written < length
      written += fs.writeSync(fd, data, written, length - written, position)
      position += written
  finally
    fs.closeSync fd
  return

fs.appendFile = (path, data, options, callback_) ->
  callback = maybeCallback(arguments[arguments.length - 1])
  if util.isFunction(options) or not options
    options =
      encoding: "utf8"
      mode: 438
      flag: "a"
  else if util.isString(options)
    options =
      encoding: options
      mode: 438
      flag: "a"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  unless options.flag
    options = util._extend(
      flag: "a"
    , options)
  fs.writeFile path, data, options, callback
  return

fs.appendFileSync = (path, data, options) ->
  unless options
    options =
      encoding: "utf8"
      mode: 438
      flag: "a"
  else if util.isString(options)
    options =
      encoding: options
      mode: 438
      flag: "a"
  else throw new TypeError("Bad arguments")  unless util.isObject(options)
  unless options.flag
    options = util._extend(
      flag: "a"
    , options)
  fs.writeFileSync path, data, options
  return

util.inherits FSWatcher, EventEmitter
FSWatcher::start = (filename, persistent, recursive) ->
  nullCheck filename
  err = @_handle.start(pathModule._makeLong(filename), persistent, recursive)
  if err
    @_handle.close()
    throw errnoException(err, "watch")
  return

FSWatcher::close = ->
  @_handle.close()
  return

fs.watch = (filename) ->
  nullCheck filename
  watcher = undefined
  options = undefined
  listener = undefined
  if util.isObject(arguments[1])
    options = arguments[1]
    listener = arguments[2]
  else
    options = {}
    listener = arguments[1]
  options.persistent = true  if util.isUndefined(options.persistent)
  options.recursive = false  if util.isUndefined(options.recursive)
  watcher = new FSWatcher()
  watcher.start filename, options.persistent, options.recursive
  watcher.addListener "change", listener  if listener
  watcher

util.inherits StatWatcher, EventEmitter
StatWatcher::start = (filename, persistent, interval) ->
  nullCheck filename
  @_handle.start pathModule._makeLong(filename), persistent, interval
  return

StatWatcher::stop = ->
  @_handle.stop()
  return

statWatchers = {}
fs.watchFile = (filename) ->
  nullCheck filename
  filename = pathModule.resolve(filename)
  stat = undefined
  listener = undefined
  options =
    interval: 5007
    persistent: true

  if util.isObject(arguments[1])
    options = util._extend(options, arguments[1])
    listener = arguments[2]
  else
    listener = arguments[1]
  throw new Error("watchFile requires a listener function")  unless listener
  if inStatWatchers(filename)
    stat = statWatchers[filename]
  else
    stat = statWatchers[filename] = new StatWatcher()
    stat.start filename, options.persistent, options.interval
  stat.addListener "change", listener
  stat

fs.unwatchFile = (filename, listener) ->
  nullCheck filename
  filename = pathModule.resolve(filename)
  return  unless inStatWatchers(filename)
  stat = statWatchers[filename]
  if util.isFunction(listener)
    stat.removeListener "change", listener
  else
    stat.removeAllListeners "change"
  if EventEmitter.listenerCount(stat, "change") is 0
    stat.stop()
    statWatchers[filename] = `undefined`
  return

if isWindows
  nextPartRe = /(.*?)(?:[\/\\]+|$)/g
else
  nextPartRe = /(.*?)(?:[\/]+|$)/g
if isWindows
  splitRootRe = /^(?:[a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/][^\\\/]+)?[\\\/]*/
else
  splitRootRe = /^[\/]*/
fs.realpathSync = realpathSync = (p, cache) ->
  start = ->
    m = splitRootRe.exec(p)
    pos = m[0].length
    current = m[0]
    base = m[0]
    previous = ""
    if isWindows and not knownHard[base]
      fs.lstatSync base
      knownHard[base] = true
    return
  p = pathModule.resolve(p)
  return cache[p]  if cache and Object::hasOwnProperty.call(cache, p)
  original = p
  seenLinks = {}
  knownHard = {}
  pos = undefined
  current = undefined
  base = undefined
  previous = undefined
  start()
  while pos < p.length
    nextPartRe.lastIndex = pos
    result = nextPartRe.exec(p)
    previous = current
    current += result[0]
    base = previous + result[1]
    pos = nextPartRe.lastIndex
    continue  if knownHard[base] or (cache and cache[base] is base)
    resolvedLink = undefined
    if cache and Object::hasOwnProperty.call(cache, base)
      resolvedLink = cache[base]
    else
      stat = fs.lstatSync(base)
      unless stat.isSymbolicLink()
        knownHard[base] = true
        cache[base] = base  if cache
        continue
      linkTarget = null
      unless isWindows
        id = stat.dev.toString(32) + ":" + stat.ino.toString(32)
        linkTarget = seenLinks[id]  if seenLinks.hasOwnProperty(id)
      if util.isNull(linkTarget)
        fs.statSync base
        linkTarget = fs.readlinkSync(base)
      resolvedLink = pathModule.resolve(previous, linkTarget)
      cache[base] = resolvedLink  if cache
      seenLinks[id] = linkTarget  unless isWindows
    p = pathModule.resolve(resolvedLink, p.slice(pos))
    start()
  cache[original] = p  if cache
  p

fs.realpath = realpath = (p, cache, cb) ->
  start = ->
    m = splitRootRe.exec(p)
    pos = m[0].length
    current = m[0]
    base = m[0]
    previous = ""
    if isWindows and not knownHard[base]
      fs.lstat base, (err) ->
        return cb(err)  if err
        knownHard[base] = true
        LOOP()
        return

    else
      process.nextTick LOOP
    return
  LOOP = ->
    if pos >= p.length
      cache[original] = p  if cache
      return cb(null, p)
    nextPartRe.lastIndex = pos
    result = nextPartRe.exec(p)
    previous = current
    current += result[0]
    base = previous + result[1]
    pos = nextPartRe.lastIndex
    return process.nextTick(LOOP)  if knownHard[base] or (cache and cache[base] is base)
    return gotResolvedLink(cache[base])  if cache and Object::hasOwnProperty.call(cache, base)
    fs.lstat base, gotStat
  gotStat = (err, stat) ->
    return cb(err)  if err
    unless stat.isSymbolicLink()
      knownHard[base] = true
      cache[base] = base  if cache
      return process.nextTick(LOOP)
    unless isWindows
      id = stat.dev.toString(32) + ":" + stat.ino.toString(32)
      return gotTarget(null, seenLinks[id], base)  if seenLinks.hasOwnProperty(id)
    fs.stat base, (err) ->
      return cb(err)  if err
      fs.readlink base, (err, target) ->
        seenLinks[id] = target  unless isWindows
        gotTarget err, target
        return

      return

    return
  gotTarget = (err, target, base) ->
    return cb(err)  if err
    resolvedLink = pathModule.resolve(previous, target)
    cache[base] = resolvedLink  if cache
    gotResolvedLink resolvedLink
    return
  gotResolvedLink = (resolvedLink) ->
    p = pathModule.resolve(resolvedLink, p.slice(pos))
    start()
    return
  unless util.isFunction(cb)
    cb = maybeCallback(cache)
    cache = null
  p = pathModule.resolve(p)
  return process.nextTick(cb.bind(null, null, cache[p]))  if cache and Object::hasOwnProperty.call(cache, p)
  original = p
  seenLinks = {}
  knownHard = {}
  pos = undefined
  current = undefined
  base = undefined
  previous = undefined
  start()
  return

pool = undefined
fs.createReadStream = (path, options) ->
  new ReadStream(path, options)

util.inherits ReadStream, Readable
fs.ReadStream = ReadStream
fs.FileReadStream = fs.ReadStream
ReadStream::open = ->
  self = this
  fs.open @path, @flags, @mode, (er, fd) ->
    if er
      self.destroy()  if self.autoClose
      self.emit "error", er
      return
    self.fd = fd
    self.emit "open", fd
    self.read()
    return

  return

ReadStream::_read = (n) ->
  onread = (er, bytesRead) ->
    if er
      self.destroy()  if self.autoClose
      self.emit "error", er
    else
      b = null
      b = thisPool.slice(start, start + bytesRead)  if bytesRead > 0
      self.push b
    return
  unless util.isNumber(@fd)
    return @once("open", ->
      @_read n
      return
    )
  return  if @destroyed
  if not pool or pool.length - pool.used < kMinPoolSpace
    pool = null
    allocNewPool @_readableState.highWaterMark
  thisPool = pool
  toRead = Math.min(pool.length - pool.used, n)
  start = pool.used
  toRead = Math.min(@end - @pos + 1, toRead)  unless util.isUndefined(@pos)
  return @push(null)  if toRead <= 0
  self = this
  fs.read @fd, pool, pool.used, toRead, @pos, onread
  @pos += toRead  unless util.isUndefined(@pos)
  pool.used += toRead
  return

ReadStream::destroy = ->
  return  if @destroyed
  @destroyed = true
  @close()  if util.isNumber(@fd)
  return

ReadStream::close = (cb) ->
  close = (fd) ->
    fs.close fd or self.fd, (er) ->
      if er
        self.emit "error", er
      else
        self.emit "close"
      return

    self.fd = null
    return
  self = this
  @once "close", cb  if cb
  if @closed or not util.isNumber(@fd)
    unless util.isNumber(@fd)
      @once "open", close
      return
    return process.nextTick(@emit.bind(this, "close"))
  @closed = true
  close()
  return

fs.createWriteStream = (path, options) ->
  new WriteStream(path, options)

util.inherits WriteStream, Writable
fs.WriteStream = WriteStream
fs.FileWriteStream = fs.WriteStream
WriteStream::open = ->
  fs.open @path, @flags, @mode, ((er, fd) ->
    if er
      @destroy()
      @emit "error", er
      return
    @fd = fd
    @emit "open", fd
    return
  ).bind(this)
  return

WriteStream::_write = (data, encoding, cb) ->
  return @emit("error", new Error("Invalid data"))  unless util.isBuffer(data)
  unless util.isNumber(@fd)
    return @once("open", ->
      @_write data, encoding, cb
      return
    )
  self = this
  fs.write @fd, data, 0, data.length, @pos, (er, bytes) ->
    if er
      self.destroy()
      return cb(er)
    self.bytesWritten += bytes
    cb()
    return

  @pos += data.length  unless util.isUndefined(@pos)
  return

WriteStream::destroy = ReadStream::destroy
WriteStream::close = ReadStream::close
WriteStream::destroySoon = WriteStream::end
util.inherits SyncWriteStream, Stream

# Export
fs.SyncWriteStream = SyncWriteStream
SyncWriteStream::write = (data, arg1, arg2) ->
  encoding = undefined
  cb = undefined
  
  # parse arguments
  if arg1
    if util.isString(arg1)
      encoding = arg1
      cb = arg2
    else if util.isFunction(arg1)
      cb = arg1
    else
      throw new Error("bad arg")
  assertEncoding encoding
  
  # Change strings to buffers. SLOW
  data = new Buffer(data, encoding)  if util.isString(data)
  fs.writeSync @fd, data, 0, data.length
  process.nextTick cb  if cb
  true

SyncWriteStream::end = (data, arg1, arg2) ->
  @write data, arg1, arg2  if data
  @destroy()
  return

SyncWriteStream::destroy = ->
  fs.closeSync @fd  if @autoClose
  @fd = null
  @emit "close"
  true

SyncWriteStream::destroySoon = SyncWriteStream::destroy
