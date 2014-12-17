# Copyright 2010 the V8 project authors. All rights reserved.
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
Object.extend = (dest, source) ->
  for property of source
    dest[property] = source[property]
  dest

Object.extend Function::,
  wrap: (wrapper) ->
    method = this
    bmethod = ((_method) ->
      ->
        @$$$parentMethodStore$$$ = @$proceed
        @$proceed = ->
          _method.apply this, arguments

        return
    )(method)
    amethod = ->
      @$proceed = @$$$parentMethodStore$$$
      delete @$proceed  unless @$proceed?
      delete @$$$parentMethodStore$$$

      return

    value = ->
      bmethod.call this
      retval = wrapper.apply(this, arguments)
      amethod.call this
      retval

    value

String::cap = ->
  @charAt(0).toUpperCase() + @substring(1).toLowerCase()

String::cap = String::cap.wrap((each) ->
  if each and @indexOf(" ") isnt -1
    @split(" ").map((value) ->
      value.cap()
    ).join " "
  else
    @$proceed()
)
Object.extend Array::,
  map: (fun) ->
    throw new TypeError()  unless typeof fun is "function"
    len = @length
    res = new Array(len)
    thisp = arguments[1]
    i = 0

    while i < len
      res[i] = fun.call(thisp, this[i], i, this)  if i of this
      i++
    res

assertEquals "Test1 test1", "test1 test1".cap()
assertEquals "Test2 Test2", "test2 test2".cap(true)
