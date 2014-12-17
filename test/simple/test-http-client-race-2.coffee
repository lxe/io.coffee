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
url = require("url")

#
# Slight variation on test-http-client-race to test for another race
# condition involving the parsers FreeList used internally by http.Client.
#
body1_s = "1111111111111111"
body2_s = "22222"
body3_s = "3333333333333333333"
server = http.createServer((req, res) ->
  pathname = url.parse(req.url).pathname
  body = undefined
  switch pathname
    when "/1"
      body = body1_s
    when "/2"
      body = body2_s
    else
      body = body3_s
  res.writeHead 200,
    "Content-Type": "text/plain"
    "Content-Length": body.length

  res.end body
  return
)
server.listen common.PORT
body1 = ""
body2 = ""
body3 = ""
server.on "listening", ->
  client = http.createClient(common.PORT)
  
  #
  # Client #1 is assigned Parser #1
  #
  req1 = client.request("/1")
  req1.end()
  req1.on "response", (res1) ->
    res1.setEncoding "utf8"
    res1.on "data", (chunk) ->
      body1 += chunk
      return

    res1.on "end", ->
      
      #
      # Delay execution a little to allow the 'close' event to be processed
      # (required to trigger this bug!)
      #
      setTimeout (->
        
        #
        # The bug would introduce itself here: Client #2 would be allocated the
        # parser that previously belonged to Client #1. But we're not finished
        # with Client #1 yet!
        #
        client2 = http.createClient(common.PORT)
        
        #
        # At this point, the bug would manifest itself and crash because the
        # internal state of the parser was no longer valid for use by Client #1
        #
        req2 = client.request("/2")
        req2.end()
        req2.on "response", (res2) ->
          res2.setEncoding "utf8"
          res2.on "data", (chunk) ->
            body2 += chunk
            return

          res2.on "end", ->
            
            #
            # Just to be really sure we've covered all our bases, execute a
            # request using client2.
            #
            req3 = client2.request("/3")
            req3.end()
            req3.on "response", (res3) ->
              res3.setEncoding "utf8"
              res3.on "data", (chunk) ->
                body3 += chunk
                return

              res3.on "end", ->
                server.close()
                return

              return

            return

          return

        return
      ), 500
      return

    return

  return

process.on "exit", ->
  assert.equal body1_s, body1
  assert.equal body2_s, body2
  assert.equal body3_s, body3
  return

