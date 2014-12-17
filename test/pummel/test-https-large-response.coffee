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
fs = require("fs")
https = require("https")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

reqCount = 0
body = ""
process.stdout.write "build body..."
i = 0

while i < 1024 * 1024
  body += "hello world\n"
  i++
process.stdout.write "done\n"
server = https.createServer(options, (req, res) ->
  reqCount++
  console.log "got request"
  res.writeHead 200,
    "content-type": "text/plain"

  res.end body
  return
)
count = 0
gotResEnd = false
server.listen common.PORT, ->
  https.get
    port: common.PORT
    rejectUnauthorized: false
  , (res) ->
    console.log "response!"
    res.on "data", (d) ->
      process.stdout.write "."
      count += d.length
      res.pause()
      process.nextTick ->
        res.resume()
        return

      return

    res.on "end", (d) ->
      process.stdout.write "\n"
      console.log "expected: ", body.length
      console.log "     got: ", count
      server.close()
      gotResEnd = true
      return

    return

  return

process.on "exit", ->
  assert.equal 1, reqCount
  assert.equal body.length, count
  assert.ok gotResEnd
  return

