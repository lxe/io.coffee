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
testIndex = 0
responses = 0
server = http.createServer((req, res) ->
  switch testIndex++
    when 0
      res.writeHead 200,
        test: "foo \r\ninvalid: bar"

    when 1
      res.writeHead 200,
        test: "foo \ninvalid: bar"

    when 2
      res.writeHead 200,
        test: "foo \rinvalid: bar"

    when 3
      res.writeHead 200,
        test: "foo \n\n\ninvalid: bar"

    when 4
      res.writeHead 200,
        test: "foo \r\n \r\n \r\ninvalid: bar"

      server.close()
    else
      assert false
  res.end "Hi mars!"
  return
)
server.listen common.PORT, ->
  i = 0

  while i < 5
    req = http.get(
      port: common.PORT
      path: "/"
    , (res) ->
      assert.strictEqual res.headers.test, "foo invalid: bar"
      assert.strictEqual res.headers.invalid, `undefined`
      responses++
      res.resume()
      return
    )
    i++
  return

process.on "exit", ->
  assert.strictEqual responses, 5
  return

