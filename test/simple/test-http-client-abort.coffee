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
clientAborts = 0
server = http.Server((req, res) ->
  console.log "Got connection"
  res.writeHead 200
  res.write "Working on it..."
  
  # I would expect an error event from req or res that the client aborted
  # before completing the HTTP request / response cycle, or maybe a new
  # event like "aborted" or something.
  req.on "aborted", ->
    clientAborts++
    console.log "Got abort " + clientAborts
    if clientAborts is N
      console.log "All aborts detected, you win."
      server.close()
    return

  
  # since there is already clientError, maybe that would be appropriate,
  # since "error" is magical
  req.on "clientError", ->
    console.log "Got clientError"
    return

  return
)
responses = 0
N = 16
requests = []
server.listen common.PORT, ->
  console.log "Server listening."
  i = 0

  while i < N
    console.log "Making client " + i
    options =
      port: common.PORT
      path: "/?id=" + i

    req = http.get(options, (res) ->
      console.log "Client response code " + res.statusCode
      res.resume()
      if ++responses is N
        console.log "All clients connected, destroying."
        requests.forEach (outReq) ->
          console.log "abort"
          outReq.abort()
          return

      return
    )
    requests.push req
    i++
  return

process.on "exit", ->
  assert.equal N, clientAborts
  return

