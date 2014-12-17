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

# delayed for some time until debug agent is ready
debug_client_connect = ->
  parse = ->
    unless msg
      msg =
        headers: null
        contentLength: 0
    unless msg.headers
      offset = tmpBuf.indexOf("\r\n\r\n")
      return  if offset < 0
      msg.headers = tmpBuf.substring(0, offset)
      tmpBuf = tmpBuf.slice(offset + 4)
      matches = /Content-Length: (\d+)/.exec(msg.headers)
      msg.contentLength = +(matches[1])  if matches[1]
    if msg.headers and Buffer.byteLength(tmpBuf) >= msg.contentLength
      try
        b = Buffer(tmpBuf)
        body = b.toString("utf8", 0, msg.contentLength)
        tmpBuf = b.toString("utf8", msg.contentLength, b.length)
        
        # get breakpoint list and check if it exists on line 0
        unless body.length
          req = JSON.stringify(
            seq: 1
            type: "request"
            command: "listbreakpoints"
          )
          conn.write "Content-Length: " + req.length + "\r\n\r\n" + req
          return
        obj = JSON.parse(body)
        if obj.type is "response" and obj.command is "listbreakpoints" and not obj.running
          obj.body.breakpoints.forEach (bpoint) ->
            isDone = true  if bpoint.line is 0
            return

        req = JSON.stringify(
          seq: 100
          type: "request"
          command: "disconnect"
        )
        conn.write "Content-Length: " + req.length + "\r\n\r\n" + req
      finally
        msg = null
        parse()
    return
  msg = null
  tmpBuf = ""
  conn = net.connect(port: common.PORT)
  conn.setEncoding "utf8"
  conn.on "data", (data) ->
    tmpBuf += data
    parse()
    return

  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
path = require("path")
net = require("net")
isDone = false
targetPath = path.resolve(common.fixturesDir, "debug-target.js")
child = spawn(process.execPath, [
  "--debug-brk=" + common.PORT
  targetPath
])
child.stderr.on "data", ->
  child.emit "debug_start"
  return

child.on "exit", ->
  assert isDone
  console.log "ok"
  return

child.once "debug_start", ->
  setTimeout (->
    debug_client_connect()
    return
  ), 200
  return

