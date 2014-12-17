# Copyright 2011 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Flags: --harmony --harmony-proxies

# A simple no-op handler. Adapted from:
# http://wiki.ecmascript.org/doku.php?id=harmony:proxies#examplea_no-op_forwarding_proxy
createHandler = (obj) ->
  getOwnPropertyDescriptor: (name) ->
    desc = Object.getOwnPropertyDescriptor(obj, name)
    desc.configurable = true  if desc isnt `undefined`
    desc

  getPropertyDescriptor: (name) ->
    desc = Object.getOwnPropertyDescriptor(obj, name)
    
    #var desc = Object.getPropertyDescriptor(obj, name);  // not in ES5
    desc.configurable = true  if desc isnt `undefined`
    desc

  getOwnPropertyNames: ->
    Object.getOwnPropertyNames obj

  getPropertyNames: ->
    Object.getOwnPropertyNames obj

  
  #return Object.getPropertyNames(obj);  // not in ES5
  defineProperty: (name, desc) ->
    Object.defineProperty obj, name, desc
    return

  delete: (name) ->
    delete obj[name]

  fix: ->
    if Object.isFrozen(obj)
      result = {}
      Object.getOwnPropertyNames(obj).forEach (name) ->
        result[name] = Object.getOwnPropertyDescriptor(obj, name)
        return

      return result
    
    # As long as obj is not frozen, the proxy won't allow itself to be fixed
    `undefined` # will cause a TypeError to be thrown

  has: (name) ->
    name of obj

  hasOwn: (name) ->
    ({}).hasOwnProperty.call obj, name

  get: (receiver, name) ->
    obj[name]

  set: (receiver, name, val) ->
    obj[name] = val # bad behavior when set fails in sloppy mode
    true

  enumerate: ->
    result = []
    for name of obj
      result.push name
    result

  keys: ->
    Object.keys obj

# Auxiliary definitions enabling tracking of object identity in output.
registerObject = (x, s) ->
  objectMap.set x, ++objectCounter + ((if not s? then "" else ":" + s))  if x is Object(x) and not objectMap.has(x)
  return
str = (x) ->
  return "[" + typeof x + " " + objectMap.get(x) + "]"  if x is Object(x)
  return "\"" + x + "\""  if typeof x is "string"
  "" + x

# A simple membrane. Adapted from:
# http://wiki.ecmascript.org/doku.php?id=harmony:proxies#a_simple_membrane
createSimpleMembrane = (target) ->
  wrap = (obj) ->
    registerObject obj
    print "wrap enter", str(obj)
    try
      x = wrap2(obj)
      registerObject x, "wrapped"
      print "wrap exit", str(obj), "as", str(x)
      return x
    catch e
      print "wrap exception", str(e)
      throw e
    return
  wrap2 = (obj) ->
    wrapCall = (fun, that, args) ->
      registerObject that
      print "wrapCall enter", fun, str(that)
      try
        x = wrapCall2(fun, that, args)
        print "wrapCall exit", fun, str(that), "returning", str(x)
        return x
      catch e
        print "wrapCall exception", fun, str(that), str(e)
        throw e
      return
    wrapCall2 = (fun, that, args) ->
      throw new Error("disabled")  unless enabled
      try
        return wrap(fun.apply(that, Array::map.call(args, wrap)))
      catch e
        throw wrap(e)
      return
    return obj  if obj isnt Object(obj)
    baseHandler = createHandler(obj)
    handler = Proxy.create(Object.freeze(get: (receiver, name) ->
      ->
        arg = (if (name is "get" or name is "set") then arguments[1] else "")
        print "handler enter", name, arg
        x = wrapCall(baseHandler[name], baseHandler, arguments)
        print "handler exit", name, arg, "returning", str(x)
        x
    ))
    registerObject baseHandler, "basehandler"
    registerObject handler, "handler"
    if typeof obj is "function"
      callTrap = ->
        print "call trap enter", str(obj), str(this)
        x = wrapCall(obj, wrap(this), arguments)
        print "call trap exit", str(obj), str(this), "returning", str(x)
        x
      constructTrap = ->
        throw new Error("disabled")  unless enabled
        try
          forward = (args) ->
            obj.apply this, args
          return wrap(new forward(Array::map.call(arguments, wrap)))
        catch e
          throw wrap(e)
        return
      Proxy.createFunction handler, callTrap, constructTrap
    else
      prototype = wrap(Object.getPrototypeOf(obj))
      Proxy.create handler, prototype
  enabled = true
  gate = Object.freeze(
    enable: ->
      enabled = true
      return

    disable: ->
      enabled = false
      return
  )
  Object.freeze
    wrapper: wrap(target)
    gate: gate


# An identity-preserving membrane. Adapted from:
# http://wiki.ecmascript.org/doku.php?id=harmony:proxies#an_identity-preserving_membrane
createMembrane = (wetTarget) ->
  asDry = (obj) ->
    registerObject obj
    print "asDry enter", str(obj)
    try
      x = asDry2(obj)
      registerObject x, "dry"
      print "asDry exit", str(obj), "as", str(x)
      return x
    catch e
      print "asDry exception", str(e)
      throw e
    return
  asDry2 = (wet) ->
    
    # primitives provide only irrevocable knowledge, so don't
    # bother wrapping it.
    return wet  if wet isnt Object(wet)
    dryResult = wet2dry.get(wet)
    return dryResult  if dryResult
    wetHandler = createHandler(wet)
    dryRevokeHandler = Proxy.create(Object.freeze(get: (receiver, name) ->
      ->
        arg = (if (name is "get" or name is "set") then arguments[1] else "")
        print "dry handler enter", name, arg
        optWetHandler = dry2wet.get(dryRevokeHandler)
        try
          x = asDry(optWetHandler[name].apply(optWetHandler, Array::map.call(arguments, asWet)))
          print "dry handler exit", name, arg, "returning", str(x)
          return x
        catch eWet
          x = asDry(eWet)
          print "dry handler exception", name, arg, "throwing", str(x)
          throw x
        return
    ))
    dry2wet.set dryRevokeHandler, wetHandler
    if typeof wet is "function"
      callTrap = ->
        print "dry call trap enter", str(this)
        x = asDry(wet.apply(asWet(this), Array::map.call(arguments, asWet)))
        print "dry call trap exit", str(this), "returning", str(x)
        x
      constructTrap = ->
        forward = (args) ->
          wet.apply this, args
        asDry new forward(Array::map.call(arguments, asWet))
      dryResult = Proxy.createFunction(dryRevokeHandler, callTrap, constructTrap)
    else
      dryResult = Proxy.create(dryRevokeHandler, asDry(Object.getPrototypeOf(wet)))
    wet2dry.set wet, dryResult
    dry2wet.set dryResult, wet
    dryResult
  asWet = (obj) ->
    registerObject obj
    print "asWet enter", str(obj)
    try
      x = asWet2(obj)
      registerObject x, "wet"
      print "asWet exit", str(obj), "as", str(x)
      return x
    catch e
      print "asWet exception", str(e)
      throw e
    return
  asWet2 = (dry) ->
    
    # primitives provide only irrevocable knowledge, so don't
    # bother wrapping it.
    return dry  if dry isnt Object(dry)
    wetResult = dry2wet.get(dry)
    return wetResult  if wetResult
    dryHandler = createHandler(dry)
    wetRevokeHandler = Proxy.create(Object.freeze(get: (receiver, name) ->
      ->
        arg = (if (name is "get" or name is "set") then arguments[1] else "")
        print "wet handler enter", name, arg
        optDryHandler = wet2dry.get(wetRevokeHandler)
        try
          x = asWet(optDryHandler[name].apply(optDryHandler, Array::map.call(arguments, asDry)))
          print "wet handler exit", name, arg, "returning", str(x)
          return x
        catch eDry
          x = asWet(eDry)
          print "wet handler exception", name, arg, "throwing", str(x)
          throw x
        return
    ))
    wet2dry.set wetRevokeHandler, dryHandler
    if typeof dry is "function"
      callTrap = ->
        print "wet call trap enter", str(this)
        x = asWet(dry.apply(asDry(this), Array::map.call(arguments, asDry)))
        print "wet call trap exit", str(this), "returning", str(x)
        x
      constructTrap = ->
        forward = (args) ->
          dry.apply this, args
        asWet new forward(Array::map.call(arguments, asDry))
      wetResult = Proxy.createFunction(wetRevokeHandler, callTrap, constructTrap)
    else
      wetResult = Proxy.create(wetRevokeHandler, asWet(Object.getPrototypeOf(dry)))
    dry2wet.set dry, wetResult
    wet2dry.set wetResult, dry
    wetResult
  wet2dry = new WeakMap()
  dry2wet = new WeakMap()
  gate = Object.freeze(revoke: ->
    dry2wet = wet2dry = Object.freeze(
      get: (key) ->
        throw new Error("revoked")return

      set: (key, val) ->
        throw new Error("revoked")return
    )
    return
  )
  Object.freeze
    wrapper: asDry(wetTarget)
    gate: gate

objectMap = new WeakMap
objectCounter = 0
registerObject this, "global"
registerObject Object::, "Object.prototype"
o =
  a: 6
  b:
    bb: 8

  f: (x) ->
    x

  g: (x) ->
    x.a

  h: (x) ->
    @q = x
    return

o[2] = c: 7
m = createSimpleMembrane(o)
w = m.wrapper
print "o =", str(o)
print "w =", str(w)
f = w.f
x = f(66)
x = f(a: 1)
x = w.f(a: 1)
a = x.a
assertEquals 6, w.a
assertEquals 8, w.b.bb
assertEquals 7, w[2]["c"]
assertEquals `undefined`, w.c
assertEquals 1, w.f(1)
assertEquals 1, w.f(a: 1).a
assertEquals 2, w.g(a: 2)
assertEquals 3, (w.r = a: 3).a
assertEquals 3, w.r.a
assertEquals 3, o.r.a
w.h 3
assertEquals 3, w.q
assertEquals 3, o.q
assertEquals 4, (new w.h(4)).q
wb = w.b
wr = w.r
wf = w.f
wf3 = w.f(3)
wfx = w.f(a: 6)
wgx = w.g(a:
  aa: 7
)
wh4 = new w.h(4)
m.gate.disable()
assertEquals 3, wf3
assertThrows (->
  w.a
  return
), Error
assertThrows (->
  w.r
  return
), Error
assertThrows (->
  w.r = a: 4
  return
), Error
assertThrows (->
  o.r.a
  return
), Error
assertEquals "object", typeof o.r
assertEquals 5, (o.r = a: 5).a
assertEquals 5, o.r.a
assertThrows (->
  w[1]
  return
), Error
assertThrows (->
  w.c
  return
), Error
assertThrows (->
  wb.bb
  return
), Error
assertThrows (->
  wr.a
  return
), Error
assertThrows (->
  wf 4
  return
), Error
assertThrows (->
  wfx.a
  return
), Error
assertThrows (->
  wgx.aa
  return
), Error
assertThrows (->
  wh4.q
  return
), Error
m.gate.enable()
assertEquals 6, w.a
assertEquals 5, w.r.a
assertEquals 5, o.r.a
assertEquals 7, w.r = 7
assertEquals 7, w.r
assertEquals 7, o.r
assertEquals 8, w.b.bb
assertEquals 7, w[2]["c"]
assertEquals `undefined`, w.c
assertEquals 8, wb.bb
assertEquals 3, wr.a
assertEquals 4, wf(4)
assertEquals 3, wf3
assertEquals 6, wfx.a
assertEquals 7, wgx.aa
assertEquals 4, wh4.q
receiver = undefined
argument = undefined
o =
  a: 6
  b:
    bb: 8

  f: (x) ->
    receiver = this
    argument = x
    x

  g: (x) ->
    receiver = this
    argument = x
    x.a

  h: (x) ->
    receiver = this
    argument = x
    @q = x
    return

  s: (x) ->
    receiver = this
    argument = x
    @x = y: x
    this

o[2] = c: 7
m = createMembrane(o)
w = m.wrapper
print "o =", str(o)
print "w =", str(w)
f = w.f
x = f(66)
x = f(a: 1)
x = w.f(a: 1)
a = x.a
assertEquals 6, w.a
assertEquals 8, w.b.bb
assertEquals 7, w[2]["c"]
assertEquals `undefined`, w.c
assertEquals 1, w.f(1)
assertSame o, receiver
assertEquals 1, w.f(a: 1).a
assertSame o, receiver
assertEquals 2, w.g(a: 2)
assertSame o, receiver
assertSame w, w.f(w)
assertSame o, receiver
assertSame o, argument
assertSame o, w.f(o)
assertSame o, receiver

# Note that argument !== o, since o isn't dry, so gets wrapped wet again.
assertEquals 3, (w.r = a: 3).a
assertEquals 3, w.r.a
assertEquals 3, o.r.a
w.h 3
assertEquals 3, w.q
assertEquals 3, o.q
assertEquals 4, (new w.h(4)).q
assertEquals 5, w.s(5).x.y
assertSame o, receiver
wb = w.b
wr = w.r
wf = w.f
wf3 = w.f(3)
wfx = w.f(a: 6)
wgx = w.g(a:
  aa: 7
)
wh4 = new w.h(4)
ws5 = w.s(5)
ws5x = ws5.x
m.gate.revoke()
assertEquals 3, wf3
assertThrows (->
  w.a
  return
), Error
assertThrows (->
  w.r
  return
), Error
assertThrows (->
  w.r = a: 4
  return
), Error
assertThrows (->
  o.r.a
  return
), Error
assertEquals "object", typeof o.r
assertEquals 5, (o.r = a: 5).a
assertEquals 5, o.r.a
assertThrows (->
  w[1]
  return
), Error
assertThrows (->
  w.c
  return
), Error
assertThrows (->
  wb.bb
  return
), Error
assertEquals 3, wr.a
assertThrows (->
  wf 4
  return
), Error
assertEquals 6, wfx.a
assertEquals 7, wgx.aa
assertThrows (->
  wh4.q
  return
), Error
assertThrows (->
  ws5.x
  return
), Error
assertThrows (->
  ws5x.y
  return
), Error
