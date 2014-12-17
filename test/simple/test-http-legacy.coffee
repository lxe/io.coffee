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
p = (x) ->
  common.error common.inspect(x)
  return
common = require("../common")
assert = require("assert")
http = require("http")
url = require("url")
responses_sent = 0
responses_recvd = 0
body0 = ""
body1 = ""
server = http.createServer((req, res) ->
  if responses_sent is 0
    assert.equal "GET", req.method
    assert.equal "/hello", url.parse(req.url).pathname
    console.dir req.headers
    assert.equal true, "accept" of req.headers
    assert.equal "*/*", req.headers["accept"]
    assert.equal true, "foo" of req.headers
    assert.equal "bar", req.headers["foo"]
  if responses_sent is 1
    assert.equal "POST", req.method
    assert.equal "/world", url.parse(req.url).pathname
    @close()
  req.on "end", ->
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write "The path was " + url.parse(req.url).pathname
    res.end()
    responses_sent += 1
    return

  req.resume()
  return
)

#assert.equal('127.0.0.1', res.connection.remoteAddress);
server.listen common.PORT, ->
  client = http.createClient(common.PORT)
  req = client.request("/hello",
    Accept: "*/*"
    Foo: "bar"
  )
  setTimeout (->
    req.end()
    return
  ), 100
  req.on "response", (res) ->
    assert.equal 200, res.statusCode
    responses_recvd += 1
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      body0 += chunk
      return

    common.debug "Got /hello response"
    return

  setTimeout (->
    req = client.request("POST", "/world")
    req.end()
    req.on "response", (res) ->
      assert.equal 200, res.statusCode
      responses_recvd += 1
      res.setEncoding "utf8"
      res.on "data", (chunk) ->
        body1 += chunk
        return

      common.debug "Got /world response"
      return

    return
  ), 1
  return

process.on "exit", ->
  common.debug "responses_recvd: " + responses_recvd
  assert.equal 2, responses_recvd
  common.debug "responses_sent: " + responses_sent
  assert.equal 2, responses_sent
  assert.equal "The path was /hello", body0
  assert.equal "The path was /world", body1
  return

