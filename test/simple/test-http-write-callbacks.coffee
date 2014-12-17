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
serverEndCb = false
serverIncoming = ""
serverIncomingExpect = "bazquuxblerg"
clientEndCb = false
clientIncoming = ""
clientIncomingExpect = "asdffoobar"
process.on "exit", ->
  assert serverEndCb
  assert.equal serverIncoming, serverIncomingExpect
  assert clientEndCb
  assert.equal clientIncoming, clientIncomingExpect
  console.log "ok"
  return


# Verify that we get a callback when we do res.write(..., cb)
server = http.createServer((req, res) ->
  res.statusCode = 400
  res.end "Bad Request.\nMust send Expect:100-continue\n"
  return
)
server.on "checkContinue", (req, res) ->
  server.close()
  assert.equal req.method, "PUT"
  res.writeContinue ->
    
    # continue has been written
    req.on "end", ->
      res.write "asdf", (er) ->
        assert.ifError er
        res.write "foo", "ascii", (er) ->
          assert.ifError er
          res.end new Buffer("bar"), "buffer", (er) ->
            serverEndCb = true
            return

          return

        return

      return

    return

  req.setEncoding "ascii"
  req.on "data", (c) ->
    serverIncoming += c
    return

  return

server.listen common.PORT, ->
  req = http.request(
    port: common.PORT
    method: "PUT"
    headers:
      expect: "100-continue"
  )
  req.on "continue", ->
    
    # ok, good to go.
    req.write "YmF6", "base64", (er) ->
      assert.ifError er
      req.write new Buffer("quux"), (er) ->
        assert.ifError er
        req.end "626c657267", "hex", (er) ->
          assert.ifError er
          clientEndCb = true
          return

        return

      return

    return

  req.on "response", (res) ->
    
    # this should not come until after the end is flushed out
    assert clientEndCb
    res.setEncoding "ascii"
    res.on "data", (c) ->
      clientIncoming += c
      return

    return

  return

