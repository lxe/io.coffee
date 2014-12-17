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

# http://groups.google.com/group/nodejs/browse_thread/thread/f66cd3c960406919
maybeMakeRequest = ->
  return  if ++count < 2
  console.log "making curl request"
  cmd = "curl http://127.0.0.1:" + common.PORT + "/ | openssl sha1"
  cp.exec cmd, (err, stdout, stderr) ->
    throw err  if err
    hex = stdout.match(/([A-Fa-f0-9]{40})/)[0]
    assert.equal "8c206a1a87599f532ce68675536f0b1546900d7a", hex
    console.log "got the correct response"
    fs.unlink filename
    server.close()
    return

  return
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
http = require("http")
cp = require("child_process")
fs = require("fs")
filename = require("path").join(common.tmpDir, "big")
count = 0
ddcmd = common.ddCommand(filename, 10240)
console.log "dd command: ", ddcmd
cp.exec ddcmd, (err, stdout, stderr) ->
  throw err  if err
  maybeMakeRequest()
  return

server = http.createServer((req, res) ->
  res.writeHead 200
  
  # Create the subprocess
  cat = cp.spawn("cat", [filename])
  
  # Stream the data through to the response as binary chunks
  cat.stdout.on "data", (data) ->
    res.write data
    return

  
  # End the response on exit (and log errors)
  cat.on "exit", (code) ->
    if code isnt 0
      console.error "subprocess exited with code " + code
      process.exit 1
    res.end()
    return

  return
)
server.listen common.PORT, maybeMakeRequest
console.log "Server running at http://localhost:8080"
