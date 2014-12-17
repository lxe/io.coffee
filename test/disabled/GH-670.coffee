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

# Does not work
loadDom = ->
  
  # Do a lot of computation to stall the process.
  # In the meantime the socket will be disconnected.
  i = 0

  while i < 1e8
    i++
  console.log "Dom loaded."
  return
common = require("../common")
assert = require("assert")
https = require("https")
tls = require("tls")
options =
  host: "github.com"
  path: "/kriskowal/tigerblood/"
  port: 443

req = https.get(options, (response) ->
  recved = 0
  response.on "data", (chunk) ->
    recved += chunk.length
    console.log "Response data."
    return

  response.on "end", ->
    console.log "Response end."
    loadDom()
    return

  return
)
req.on "error", (e) ->
  console.log "Error on get."
  return

