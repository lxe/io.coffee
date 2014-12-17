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
server = http.Server((req, res) ->
  res.writeHead 200
  res.end "hello world\n"
  return
)
responses = 0
N = 10
M = 10
server.listen common.PORT, ->
  i = 0

  while i < N
    setTimeout (->
      j = 0

      while j < M
        http.get(
          port: common.PORT
          path: "/"
        , (res) ->
          console.log "%d %d", responses, res.statusCode
          if ++responses is N * M
            console.error "Received all responses, closing server"
            server.close()
          res.resume()
          return
        ).on "error", (e) ->
          console.log "Error!", e
          process.exit 1
          return

        j++
      return
    ), i
    i++
  return

process.on "exit", ->
  assert.equal N * M, responses
  return

