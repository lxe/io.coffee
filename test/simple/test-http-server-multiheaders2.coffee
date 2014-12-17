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

# Verify that the HTTP server implementation handles multiple instances
# of the same header as per RFC2616: joining the handful of fields by ', '
# that support it, and dropping duplicates for other fields.
# GH-2750
# GH-715
# GH-1187
# GH-1083
# GH-4052
# GH-2764
# GH-2764
# GH-6660

# not a special case, just making sure it's parsed correctly

# make sure that unspecified headers is treated as multiple

# special case, tested differently
#'Content-Length',
makeHeader = (value) ->
  (header) ->
    [
      header
      value
    ]
common = require("../common")
assert = require("assert")
http = require("http")
multipleAllowed = [
  "Accept"
  "Accept-Charset"
  "Accept-Encoding"
  "Accept-Language"
  "Connection"
  "Cookie"
  "DAV"
  "Pragma"
  "Link"
  "WWW-Authenticate"
  "Proxy-Authenticate"
  "Sec-Websocket-Extensions"
  "Sec-Websocket-Protocol"
  "Via"
  "X-Forwarded-For"
  "Some-Random-Header"
  "X-Some-Random-Header"
]
multipleForbidden = [
  "Content-Type"
  "User-Agent"
  "Referer"
  "Host"
  "Authorization"
  "Proxy-Authorization"
  "If-Modified-Since"
  "If-Unmodified-Since"
  "From"
  "Location"
  "Max-Forwards"
]
srv = http.createServer((req, res) ->
  multipleForbidden.forEach (header) ->
    assert.equal req.headers[header.toLowerCase()], "foo", "header parsed incorrectly: " + header
    return

  multipleAllowed.forEach (header) ->
    assert.equal req.headers[header.toLowerCase()], "foo, bar", "header parsed incorrectly: " + header
    return

  assert.equal req.headers["content-length"], 0
  res.writeHead 200,
    "Content-Type": "text/plain"

  res.end "EOF"
  srv.close()
  return
)

# content-length is a special case since node.js
# is dropping connetions with non-numeric headers
headers = [].concat(multipleAllowed.map(makeHeader("foo"))).concat(multipleForbidden.map(makeHeader("foo"))).concat(multipleAllowed.map(makeHeader("bar"))).concat(multipleForbidden.map(makeHeader("bar"))).concat([
  [
    "content-length"
    0
  ]
  [
    "content-length"
    123
  ]
])
srv.listen common.PORT, ->
  http.get
    host: "localhost"
    port: common.PORT
    path: "/"
    headers: headers

  return

