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
EventEmitter = ->
  EventEmitter.init.call this
  return
"use strict"
domain = undefined
util = require("util")
module.exports = EventEmitter

# Backwards-compat with node 0.10.x
EventEmitter.EventEmitter = EventEmitter
EventEmitter.usingDomains = false
EventEmitter::domain = `undefined`
EventEmitter::_events = `undefined`
EventEmitter::_maxListeners = `undefined`

# By default EventEmitters will print a warning if more than 10 listeners are
# added to it. This is a useful default which helps finding memory leaks.
EventEmitter.defaultMaxListeners = 10
EventEmitter.init = ->
  @domain = null
  if EventEmitter.usingDomains
    
    # if there is an active domain, then attach to it.
    domain = domain or require("domain")
    @domain = domain.active  if domain.active and (this instanceof domain.Domain)
  @_events = {}  if not @_events or @_events is Object.getPrototypeOf(this)._events
  @_maxListeners = @_maxListeners or `undefined`
  return


# Obviously not all Emitters should be limited to 10. This function allows
# that to be increased. Set to zero for unlimited.
EventEmitter::setMaxListeners = setMaxListeners = (n) ->
  throw TypeError("n must be a positive number")  if not util.isNumber(n) or n < 0 or isNaN(n)
  @_maxListeners = n
  this

EventEmitter::getMaxListeners = getMaxListeners = ->
  unless util.isUndefined(@_maxListeners)
    @_maxListeners
  else
    EventEmitter.defaultMaxListeners

EventEmitter::emit = emit = (type) ->
  er = undefined
  handler = undefined
  len = undefined
  args = undefined
  i = undefined
  listeners = undefined
  @_events = {}  unless @_events
  
  # If there is no 'error' event listener then throw.
  if type is "error" and not @_events.error
    er = arguments[1]
    if @domain
      er = new Error("Uncaught, unspecified \"error\" event.")  unless er
      er.domainEmitter = this
      er.domain = @domain
      er.domainThrown = false
      @domain.emit "error", er
    else if er instanceof Error
      throw er # Unhandled 'error' event
    else
      throw Error("Uncaught, unspecified \"error\" event.")
    return false
  handler = @_events[type]
  return false  if util.isUndefined(handler)
  @domain.enter()  if @domain and this isnt process
  if util.isFunction(handler)
    switch arguments.length
      
      # fast cases
      when 1
        handler.call this
      when 2
        handler.call this, arguments[1]
      when 3
        handler.call this, arguments[1], arguments[2]
      
      # slower
      else
        len = arguments.length
        args = new Array(len - 1)
        i = 1
        while i < len
          args[i - 1] = arguments[i]
          i++
        handler.apply this, args
  else if util.isObject(handler)
    len = arguments.length
    args = new Array(len - 1)
    i = 1
    while i < len
      args[i - 1] = arguments[i]
      i++
    listeners = handler.slice()
    len = listeners.length
    i = 0
    while i < len
      listeners[i].apply this, args
      i++
  @domain.exit()  if @domain and this isnt process
  true

EventEmitter::addListener = addListener = (type, listener) ->
  m = undefined
  throw TypeError("listener must be a function")  unless util.isFunction(listener)
  @_events = {}  unless @_events
  
  # To avoid recursion in the case that type === "newListener"! Before
  # adding it to the listeners, first emit "newListener".
  @emit "newListener", type, (if util.isFunction(listener.listener) then listener.listener else listener)  if @_events.newListener
  unless @_events[type]
    
    # Optimize the case of one listener. Don't need the extra array object.
    @_events[type] = listener
  else if util.isObject(@_events[type])
    
    # If we've already got an array, just append.
    @_events[type].push listener
  
  # Adding the second element, need to change to array.
  else
    @_events[type] = [
      @_events[type]
      listener
    ]
  
  # Check for listener leak
  if util.isObject(@_events[type]) and not @_events[type].warned
    m = @getMaxListeners()
    if m and m > 0 and @_events[type].length > m
      @_events[type].warned = true
      console.error "(node) warning: possible EventEmitter memory " + "leak detected. %d %s listeners added. " + "Use emitter.setMaxListeners() to increase limit.", @_events[type].length, type
      console.trace()
  this

EventEmitter::on = EventEmitter::addListener
EventEmitter::once = once = (type, listener) ->
  g = ->
    @removeListener type, g
    unless fired
      fired = true
      listener.apply this, arguments
    return
  throw TypeError("listener must be a function")  unless util.isFunction(listener)
  fired = false
  g.listener = listener
  @on type, g
  this


# emits a 'removeListener' event iff the listener was removed
EventEmitter::removeListener = removeListener = (type, listener) ->
  list = undefined
  position = undefined
  length = undefined
  i = undefined
  throw TypeError("listener must be a function")  unless util.isFunction(listener)
  return this  if not @_events or not @_events[type]
  list = @_events[type]
  length = list.length
  position = -1
  if list is listener or (util.isFunction(list.listener) and list.listener is listener)
    delete @_events[type]

    @emit "removeListener", type, listener  if @_events.removeListener
  else if util.isObject(list)
    i = length
    while i-- > 0
      if list[i] is listener or (list[i].listener and list[i].listener is listener)
        position = i
        break
    return this  if position < 0
    if list.length is 1
      list.length = 0
      delete @_events[type]
    else
      list.splice position, 1
    @emit "removeListener", type, listener  if @_events.removeListener
  this

EventEmitter::removeAllListeners = removeAllListeners = (type) ->
  key = undefined
  listeners = undefined
  return this  unless @_events
  
  # not listening for removeListener, no need to emit
  unless @_events.removeListener
    if arguments.length is 0
      @_events = {}
    else delete @_events[type]  if @_events[type]
    return this
  
  # emit removeListener for all listeners on all events
  if arguments.length is 0
    for key of @_events
      continue  if key is "removeListener"
      @removeAllListeners key
    @removeAllListeners "removeListener"
    @_events = {}
    return this
  listeners = @_events[type]
  if util.isFunction(listeners)
    @removeListener type, listeners
  
  # LIFO order
  else @removeListener type, listeners[listeners.length - 1]  while listeners.length  if Array.isArray(listeners)
  delete @_events[type]

  this

EventEmitter::listeners = listeners = (type) ->
  ret = undefined
  if not @_events or not @_events[type]
    ret = []
  else if util.isFunction(@_events[type])
    ret = [@_events[type]]
  else
    ret = @_events[type].slice()
  ret

EventEmitter.listenerCount = (emitter, type) ->
  ret = undefined
  if not emitter._events or not emitter._events[type]
    ret = 0
  else if util.isFunction(emitter._events[type])
    ret = 1
  else
    ret = emitter._events[type].length
  ret
