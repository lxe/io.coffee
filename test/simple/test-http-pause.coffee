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
expectedServer = "Request Body from Client"
resultServer = ""
expectedClient = "Response Body from Server"
resultClient = ""
server = http.createServer((req, res) ->
  common.debug "pause server request"
  req.pause()
  setTimeout (->
    common.debug "resume server request"
    req.resume()
    req.setEncoding "utf8"
    req.on "data", (chunk) ->
      resultServer += chunk
      return

    req.on "end", ->
      common.debug resultServer
      res.writeHead 200
      res.end expectedClient
      return

    return
  ), 100
  return
)
server.listen common.PORT, ->
  req = http.request(
    port: common.PORT
    path: "/"
    method: "POST"
  , (res) ->
    common.debug "pause client response"
    res.pause()
    setTimeout (->
      common.debug "resume client response"
      res.resume()
      res.on "data", (chunk) ->
        resultClient += chunk
        return

      res.on "end", ->
        common.debug resultClient
        server.close()
        return

      return
    ), 100
    return
  )
  req.end expectedServer
  return

process.on "exit", ->
  assert.equal expectedServer, resultServer
  assert.equal expectedClient, resultClient
  return

