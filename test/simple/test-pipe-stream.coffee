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
test = (clazz, cb) ->
  check = ->
    assert.ok have_ping
    assert.ok have_pong
    return
  ping = ->
    conn = new clazz()
    conn.on "error", (err) ->
      throw errreturn

    conn.connect common.PIPE, ->
      conn.write "PING", "utf-8"
      return

    conn.on "data", (data) ->
      assert.equal data.toString(), "PONG"
      have_pong = true
      conn.destroy()
      return

    return
  pong = (conn) ->
    conn.on "error", (err) ->
      throw errreturn

    conn.on "data", (data) ->
      assert.equal data.toString(), "PING"
      have_ping = true
      conn.write "PONG", "utf-8"
      return

    conn.on "close", ->
      server.close()
      return

    return
  have_ping = false
  have_pong = false
  timeout = setTimeout(->
    server.close()
    return
  , 2000)
  server = net.Server()
  server.listen common.PIPE, ping
  server.on "connection", pong
  server.on "close", ->
    clearTimeout timeout
    check()
    cb and cb()
    return

  return
common = require("../common")
assert = require("assert")
net = require("net")
test net.Stream, ->
  test net.Socket
  return

