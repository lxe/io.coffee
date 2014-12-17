# Copyright 2013 the V8 project authors. All rights reserved.
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
extend = (d, b) ->
  __ = ->
    @constructor = d
    return
  __:: = b::
  d:: = new __()
  return

Car = ((Super) ->
  Car = ->
    self = this
    Super.call self
    Object.defineProperties self,
      make:
        enumerable: true
        configurable: true
        get: ->
          "Ford"

    self.copy = ->
      throw new Error("Meant to be overriden")return

    self

  extend Car, Super
  Car
(Object))
SuperCar = (((Super) ->
  SuperCar = (make) ->
    self = this
    Super.call self
    Object.defineProperties self,
      make:
        enumerable: true
        configurable: true
        get: ->
          make

    
    # Convert self.copy from CONSTANT to FIELD.
    self.copy = ->

    self

  extend SuperCar, Super
  SuperCar
)(Car))
assertEquals "Ford", new Car().make
assertEquals "Bugatti", new SuperCar("Bugatti").make
assertEquals "Lambo", new SuperCar("Lambo").make
assertEquals "Shelby", new SuperCar("Shelby").make
