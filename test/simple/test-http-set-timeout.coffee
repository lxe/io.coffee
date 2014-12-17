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
common = require("../common")
assert = require("assert")
http = require("http")
server = http.createServer((req, res) ->
  console.log "got request. setting 1 second timeout"
  req.connection.setTimeout 500
  req.connection.on "timeout", ->
    req.connection.destroy()
    common.debug "TIMEOUT"
    server.close()
    return

  return
)
server.listen common.PORT, ->
  console.log "Server running at http://127.0.0.1:" + common.PORT + "/"
  errorTimer = setTimeout(->
    throw new Error("Timeout was not successful")return
  , 2000)
  x = http.get(
    port: common.PORT
    path: "/"
  )
  x.on "error", ->
    clearTimeout errorTimer
    console.log "HTTP REQUEST COMPLETE (this is good)"
    return

  x.end()
  return

