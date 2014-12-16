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

# WARNING: THIS MODULE IS PENDING DEPRECATION.
#
# No new pull requests targeting this module will be accepted
# unless they address existing, critical bugs.

# communicate with events module, but don't require that
# module to have to load this one, since this module has
# a few side effects.

# overwrite process.domain with a getter/setter that will allow for more
# effective optimizations

# objects with external array data are excellent ways to communicate state
# between js and c++ w/o much overhead

# let the process know we're using domains

# it's possible to enter one domain while already inside
# another one.  the stack is each entered domain.

# the active domain is always the one that we're currently in.
Domain = ->
  EventEmitter.call this
  @members = []
  return

# Called by process._fatalException in case an error was thrown.

# ignore errors on disposed domains.
#
# XXX This is a bit stupid.  We should probably get rid of
# domain.dispose() altogether.  It's almost always a terrible
# idea.  --isaacs

# wrap this in a try/catch so we don't get infinite throwing

# One of three things will happen here.
#
# 1. There is a handler, caught = true
# 2. There is no handler, caught = false
# 3. It throws, caught = false
#
# If caught is false after this, then there's no need to exit()
# the domain, because we're going to crash the process anyway.

# Exit all domains on the stack.  Uncaught exceptions end the
# current tick and no domains should be left on the stack
# between ticks.

# The domain error handler threw!  oh no!
# See if another domain can catch THIS error,
# or else crash on the original one.
# If the user already exited it, then don't double-exit.

# note that this might be a no-op, but we still need
# to push it onto the stack so that we can pop it later.

# skip disposed domains, as usual, but also don't do anything if this
# domain is not on the stack.

# exit all domains until this one.

# note: this works for timers as well.

# If the domain is disposed or already added, then nothing left to do.

# has a domain already - remove it first.

# check for circular Domain->Domain links.
# This causes bad insanity!
#
# For example:
# var d = domain.create();
# var e = domain.create();
# d.add(e);
# e.add(d);
# e.emit('error', er); // RangeError, stack overflow!
intercepted = (_this, self, cb, fnargs) ->
  return  if self._disposed
  if fnargs[0] and fnargs[0] instanceof Error
    er = fnargs[0]
    util._extend er,
      domainBound: cb
      domainThrown: false
      domain: self

    self.emit "error", er
    return
  args = []
  i = undefined
  ret = undefined
  self.enter()
  if fnargs.length > 1
    i = 1
    while i < fnargs.length
      args.push fnargs[i]
      i++
    ret = cb.apply(_this, args)
  else
    ret = cb.call(_this)
  self.exit()
  ret
bound = (_this, self, cb, fnargs) ->
  return  if self._disposed
  ret = undefined
  self.enter()
  if fnargs.length > 0
    ret = cb.apply(_this, fnargs)
  else
    ret = cb.call(_this)
  self.exit()
  ret
"use strict"
util = require("util")
EventEmitter = require("events")
inherits = util.inherits
EventEmitter.usingDomains = true
_domain = [null]
Object.defineProperty process, "domain",
  enumerable: true
  get: ->
    _domain[0]

  set: (arg) ->
    _domain[0] = arg

_domain_flag = {}
process._setupDomainUse _domain, _domain_flag
exports.Domain = Domain
exports.create = exports.createDomain = ->
  new Domain()

stack = []
exports._stack = stack
exports.active = null
inherits Domain, EventEmitter
Domain::members = `undefined`
Domain::_disposed = `undefined`
Domain::_errorHandler = errorHandler = (er) ->
  caught = false
  return true  if @_disposed
  unless util.isPrimitive(er)
    er.domain = this
    er.domainThrown = true
  try
    caught = @emit("error", er)
    stack.length = 0
    exports.active = process.domain = null
  catch er2
    stack.pop()  if this is exports.active
    if stack.length
      exports.active = process.domain = stack[stack.length - 1]
      caught = process._fatalException(er2)
    else
      caught = false
    return caught
  caught

Domain::enter = ->
  return  if @_disposed
  exports.active = process.domain = this
  stack.push this
  _domain_flag[0] = stack.length
  return

Domain::exit = ->
  index = stack.lastIndexOf(this)
  return  if @_disposed or index is -1
  stack.splice index
  _domain_flag[0] = stack.length
  exports.active = stack[stack.length - 1]
  process.domain = exports.active
  return

Domain::add = (ee) ->
  return  if @_disposed or ee.domain is this
  ee.domain.remove ee  if ee.domain
  if @domain and (ee instanceof Domain)
    d = @domain

    while d
      return  if ee is d
      d = d.domain
  ee.domain = this
  @members.push ee
  return

Domain::remove = (ee) ->
  ee.domain = null
  index = @members.indexOf(ee)
  @members.splice index, 1  if index isnt -1
  return

Domain::run = (fn) ->
  return  if @_disposed
  ret = undefined
  @enter()
  if arguments.length >= 2
    len = arguments.length
    args = new Array(len - 1)
    i = 1

    while i < len
      args[i - 1] = arguments[i]
      i++
    ret = fn.apply(this, args)
  else
    ret = fn.call(this)
  @exit()
  ret

Domain::intercept = (cb) ->
  runIntercepted = ->
    intercepted this, self, cb, arguments
  self = this
  runIntercepted

Domain::bind = (cb) ->
  runBound = ->
    bound this, self, cb, arguments
  self = this
  runBound.domain = this
  runBound

Domain::dispose = util.deprecate(->
  return  if @_disposed
  
  # if we're the active domain, then get out now.
  @exit()
  
  # remove from parent domain, if there is one.
  @domain.remove this  if @domain
  
  # kill the references so that they can be properly gc'ed.
  @members.length = 0
  
  # mark this domain as 'no longer relevant'
  # so that it can't be entered or activated.
  @_disposed = true
  return
)
