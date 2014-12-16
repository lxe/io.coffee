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

# Timeout values > TIMEOUT_MAX are set to 1.
# 2^31-1

# IDLE TIMEOUTS
#
# Because often many sockets will have the same idle timeout we will not
# use one timeout watcher per item. It is too much overhead.  Instead
# we'll use a single watcher for all sockets with the same timeout value
# and a linked list. This technique is described in the libev manual:
# http://pod.tst.eu/http://cvs.schmorp.de/libev/ev.pod#Be_smart_about_timeouts

# Object containing all lists, timers
# key = time in milliseconds
# value = list

# the main function - creates lists on demand and the watchers associated
# with them.
insert = (item, msecs) ->
  item._idleStart = Timer.now()
  item._idleTimeout = msecs
  return  if msecs < 0
  list = undefined
  if lists[msecs]
    list = lists[msecs]
  else
    list = new Timer()
    list.start msecs, 0
    L.init list
    lists[msecs] = list
    list.msecs = msecs
    list[kOnTimeout] = listOnTimeout
  L.append list, item
  assert not L.isEmpty(list) # list is not empty
  return
listOnTimeout = ->
  msecs = @msecs
  list = this
  debug "timeout callback %d", msecs
  now = Timer.now()
  debug "now: %s", now
  diff = undefined
  first = undefined
  threw = undefined
  while first = L.peek(list)
    diff = now - first._idleStart
    if diff < msecs
      list.start msecs - diff, 0
      debug "%d list wait because diff is %d", msecs, diff
      return
    else
      L.remove first
      assert first isnt L.peek(list)
      continue  unless first._onTimeout
      
      # v0.4 compatibility: if the timer callback throws and the
      # domain or uncaughtException handler ignore the exception,
      # other timers that expire on this tick should still run.
      #
      # https://github.com/joyent/node/issues/2631
      domain = first.domain
      continue  if domain and domain._disposed
      try
        domain.enter()  if domain
        threw = true
        first._onTimeout()
        domain.exit()  if domain
        threw = false
      finally
        if threw
          
          # We need to continue processing after domain error handling
          # is complete, but not by using whatever domain was left over
          # when the timeout threw its exception.
          oldDomain = process.domain
          process.domain = null
          process.nextTick ->
            list[kOnTimeout]()
            return

          process.domain = oldDomain
  debug "%d list empty", msecs
  assert L.isEmpty(list)
  list.close()
  delete lists[msecs]

  return

# if empty then stop the watcher

# if active is called later, then we want to make sure not to insert again

# Does not start the time, just sets up the members needed.

# if this item was already in a list somewhere
# then we should unenroll it from that

# Ensure that msecs fits into signed int32

# call this whenever the item is active (not idle)
# it will reset its timeout.

#
# * DOM-style timers
# 
# coalesce to number or NaN
# schedule on next tick, follows browser behaviour

#
#     * Sometimes setTimeout is called with arguments, EG
#     *
#     *   setTimeout(callback, 2000, "hello", "world")
#     *
#     * If that's the case we need to call the callback with
#     * those args. The overhead of an extra closure is not
#     * desired in the normal case.
#     
# for after === 0
# coalesce to number or NaN
# schedule on next tick, follows browser behaviour

# If callback called clearInterval().

# If timer is unref'd (or was - it's permanently removed from the list.)
processImmediate = ->
  queue = immediateQueue
  domain = undefined
  immediate = undefined
  immediateQueue = {}
  L.init immediateQueue
  while L.isEmpty(queue) is false
    immediate = L.shift(queue)
    domain = immediate.domain
    domain.enter()  if domain
    threw = true
    try
      immediate._onImmediate()
      threw = false
    finally
      if threw
        unless L.isEmpty(queue)
          
          # Handle any remaining on next tick, assuming we're still
          # alive to do so.
          L.append queue, L.shift(immediateQueue)  until L.isEmpty(immediateQueue)
          immediateQueue = queue
          process.nextTick processImmediate
    domain.exit()  if domain
  
  # Only round-trip to C++ land if we have to. Calling clearImmediate() on an
  # immediate that's in |queue| is okay. Worst case is we make a superfluous
  # call to NeedImmediateCallbackSetter().
  process._needImmediateCallback = false  if L.isEmpty(immediateQueue)
  return
Immediate = ->

# Internal APIs that need timeouts should use timers._unrefActive instead of
# timers.active as internal timeouts shouldn't hold the loop open
unrefTimeout = ->
  now = Timer.now()
  debug "unrefTimer fired"
  diff = undefined
  domain = undefined
  first = undefined
  threw = undefined
  while first = L.peek(unrefList)
    diff = now - first._idleStart
    if diff < first._idleTimeout
      diff = first._idleTimeout - diff
      unrefTimer.start diff, 0
      unrefTimer.when = now + diff
      debug "unrefTimer rescheudling for later"
      return
    L.remove first
    domain = first.domain
    continue  unless first._onTimeout
    continue  if domain and domain._disposed
    try
      domain.enter()  if domain
      threw = true
      debug "unreftimer firing timeout"
      first._onTimeout()
      threw = false
      domain.exit()  if domain
    finally
      process.nextTick unrefTimeout  if threw
  debug "unrefList is empty"
  unrefTimer.when = -1
  return
"use strict"
Timer = process.binding("timer_wrap").Timer
L = require("_linklist")
assert = require("assert").ok
kOnTimeout = Timer.kOnTimeout | 0
TIMEOUT_MAX = 2147483647
debug = require("util").debuglog("timer")
lists = {}
unenroll = exports.unenroll = (item) ->
  L.remove item
  list = lists[item._idleTimeout]
  debug "unenroll"
  if list and L.isEmpty(list)
    debug "unenroll: list empty"
    list.close()
    delete lists[item._idleTimeout]
  item._idleTimeout = -1
  return

exports.enroll = (item, msecs) ->
  unenroll item  if item._idleNext
  msecs = 0x7fffffff  if msecs > 0x7fffffff
  item._idleTimeout = msecs
  L.init item
  return

exports.active = (item) ->
  msecs = item._idleTimeout
  if msecs >= 0
    list = lists[msecs]
    if not list or L.isEmpty(list)
      insert item, msecs
    else
      item._idleStart = Timer.now()
      L.append list, item
  return

exports.setTimeout = (callback, after) ->
  timer = undefined
  after *= 1
  after = 1  unless after >= 1 and after <= TIMEOUT_MAX
  timer = new Timeout(after)
  if arguments.length <= 2
    timer._onTimeout = callback
  else
    args = Array::slice.call(arguments, 2)
    timer._onTimeout = ->
      callback.apply timer, args
      return
  timer.domain = process.domain  if process.domain
  exports.active timer
  timer

exports.clearTimeout = (timer) ->
  if timer and (timer[kOnTimeout] or timer._onTimeout)
    timer[kOnTimeout] = timer._onTimeout = null
    if timer instanceof Timeout
      timer.close()
    else
      exports.unenroll timer
  return

exports.setInterval = (callback, repeat) ->
  wrapper = ->
    callback.apply this, args
    return  if timer._repeat is false
    if @_handle
      @_handle.start repeat, 0
    else
      timer._idleTimeout = repeat
      exports.active timer
    return
  repeat *= 1
  repeat = 1  unless repeat >= 1 and repeat <= TIMEOUT_MAX
  timer = new Timeout(repeat)
  args = Array::slice.call(arguments, 2)
  timer._onTimeout = wrapper
  timer._repeat = true
  timer.domain = process.domain  if process.domain
  exports.active timer
  return timer
  return

exports.clearInterval = (timer) ->
  if timer and timer._repeat
    timer._repeat = false
    clearTimeout timer
  return

Timeout = (after) ->
  @_idleTimeout = after
  @_idlePrev = this
  @_idleNext = this
  @_idleStart = null
  @_onTimeout = null
  @_repeat = false
  return

Timeout::unref = ->
  unless @_handle
    now = Timer.now()
    @_idleStart = now  unless @_idleStart
    delay = @_idleStart + @_idleTimeout - now
    delay = 0  if delay < 0
    exports.unenroll this
    @_handle = new Timer()
    @_handle[kOnTimeout] = @_onTimeout
    @_handle.start delay, 0
    @_handle.domain = @domain
    @_handle.unref()
  else
    @_handle.unref()
  return

Timeout::ref = ->
  @_handle.ref()  if @_handle
  return

Timeout::close = ->
  @_onTimeout = null
  if @_handle
    @_handle[kOnTimeout] = null
    @_handle.close()
  else
    exports.unenroll this
  return

immediateQueue = {}
L.init immediateQueue
Immediate::domain = `undefined`
Immediate::_onImmediate = `undefined`
Immediate::_idleNext = `undefined`
Immediate::_idlePrev = `undefined`
exports.setImmediate = (callback) ->
  immediate = new Immediate()
  args = undefined
  index = undefined
  L.init immediate
  immediate._onImmediate = callback
  if arguments.length > 1
    args = []
    index = 1
    while index < arguments.length
      args.push arguments[index]
      index++
    immediate._onImmediate = ->
      callback.apply immediate, args
      return
  unless process._needImmediateCallback
    process._needImmediateCallback = true
    process._immediateCallback = processImmediate
  immediate.domain = process.domain  if process.domain
  L.append immediateQueue, immediate
  immediate

exports.clearImmediate = (immediate) ->
  return  unless immediate
  immediate._onImmediate = `undefined`
  L.remove immediate
  process._needImmediateCallback = false  if L.isEmpty(immediateQueue)
  return

unrefList = undefined
unrefTimer = undefined
exports._unrefActive = (item) ->
  msecs = item._idleTimeout
  return  if not msecs or msecs < 0
  assert msecs >= 0
  L.remove item
  unless unrefList
    debug "unrefList initialized"
    unrefList = {}
    L.init unrefList
    debug "unrefTimer initialized"
    unrefTimer = new Timer()
    unrefTimer.unref()
    unrefTimer.when = -1
    unrefTimer[kOnTimeout] = unrefTimeout
  now = Timer.now()
  item._idleStart = now
  if L.isEmpty(unrefList)
    debug "unrefList empty"
    L.append unrefList, item
    unrefTimer.start msecs, 0
    unrefTimer.when = now + msecs
    debug "unrefTimer scheduled"
    return
  when_ = now + msecs
  debug "unrefList find where we can insert"
  cur = undefined
  them = undefined
  cur = unrefList._idlePrev
  while cur isnt unrefList
    them = cur._idleStart + cur._idleTimeout
    if when_ < them
      debug "unrefList inserting into middle of list"
      L.append cur, item
      if unrefTimer.when > when_
        debug "unrefTimer is scheduled to fire too late, reschedule"
        unrefTimer.start msecs, 0
        unrefTimer.when = when_
      return
    cur = cur._idlePrev
  debug "unrefList append to end"
  L.append unrefList, item
  return
