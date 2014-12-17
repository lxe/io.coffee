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
test1 = ->
  
  # should not end when we get a Buffer(0) or '' as the _read result
  # that just means that there is *temporarily* no data, but to go
  # ahead and try again later.
  #
  # note that this is very unusual.  it only works for crypto streams
  # because the other side of the stream will call read(0) to cycle
  # data through openssl.  that's why we set the timeouts to call
  # r.read(0) again later, otherwise there is no more work being done
  # and the process just exits.
  # EOF
  # Not-EOF!
  flow = ->
    chunk = undefined
    results.push chunk + ""  while null isnt (chunk = r.read())
    return
  r = new Readable()
  buf = new Buffer(5)
  buf.fill "x"
  reads = 5
  r._read = (n) ->
    switch reads--
      when 0
        r.push null
      when 1
        r.push buf
      when 2
        setTimeout r.read.bind(r, 0), 50
        r.push new Buffer(0)
      when 3
        setTimeout r.read.bind(r, 0), 50
        process.nextTick ->
          r.push new Buffer(0)

      when 4
        setTimeout r.read.bind(r, 0), 50
        setTimeout ->
          r.push new Buffer(0)

      when 5
        setTimeout ->
          r.push buf

      else
        throw new Error("unreachable")
    return

  results = []
  r.on "readable", flow
  r.on "end", ->
    results.push "EOF"
    return

  flow()
  process.on "exit", ->
    assert.deepEqual results, [
      "xxxxx"
      "xxxxx"
      "EOF"
    ]
    console.log "ok"
    return

  return
test2 = ->
  # EOF
  flow = ->
    chunk = undefined
    results.push chunk + ""  while null isnt (chunk = r.read())
    return
  r = new Readable(encoding: "base64")
  reads = 5
  r._read = (n) ->
    unless reads--
      r.push null
    else
      r.push new Buffer("x")

  results = []
  r.on "readable", flow
  r.on "end", ->
    results.push "EOF"
    return

  flow()
  process.on "exit", ->
    assert.deepEqual results, [
      "eHh4"
      "eHg="
      "EOF"
    ]
    console.log "ok"
    return

  return
common = require("../common")
assert = require("assert")
Readable = require("stream").Readable
test1()
test2()
