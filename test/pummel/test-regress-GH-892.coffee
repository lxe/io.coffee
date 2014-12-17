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

# Uploading a big file via HTTPS causes node to drop out of the event loop.
# https://github.com/joyent/node/issues/892
# In this test we set up an HTTPS in this process and launch a subprocess
# to POST a 32mb file to us. A bug in the pause/resume functionality of the
# TLS server causes the child process to exit cleanly before having sent
# the entire buffer.
makeRequest = ->
  return  if started
  started = true
  stderrBuffer = ""
  
  # Pass along --trace-deprecation/--throw-deprecation in
  # process.execArgv to track down nextTick recursion errors
  # more easily.  Also, this is handy when using this test to
  # view V8 opt/deopt behavior.
  args = process.execArgv.concat([
    childScript
    common.PORT
    bytesExpected
  ])
  child = spawn(process.execPath, args)
  child.on "exit", (code) ->
    assert.ok /DONE/.test(stderrBuffer)
    assert.equal 0, code
    return

  
  # The following two lines forward the stdio from the child
  # to parent process for debugging.
  child.stderr.pipe process.stderr
  child.stdout.pipe process.stdout
  
  # Buffer the stderr so that we can check that it got 'DONE'
  child.stderr.setEncoding "ascii"
  child.stderr.on "data", (d) ->
    stderrBuffer += d
    return

  return
common = require("../common")
assert = require("assert")
spawn = require("child_process").spawn
https = require("https")
fs = require("fs")
PORT = 8000
bytesExpected = 1024 * 1024 * 32
gotResponse = false
started = false
childScript = require("path").join(common.fixturesDir, "GH-892-request.js")
serverOptions =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

uploadCount = 0
server = https.Server(serverOptions, (req, res) ->
  
  # Close the server immediately. This test is only doing a single upload.
  # We need to make sure the server isn't keeping the event loop alive
  # while the upload is in progress.
  server.close()
  req.on "data", (d) ->
    process.stderr.write "."
    uploadCount += d.length
    return

  req.on "end", ->
    assert.equal bytesExpected, uploadCount
    res.writeHead 200,
      "content-type": "text/plain"

    res.end "successful upload\n"
    return

  return
)
server.listen common.PORT, ->
  console.log "expecting %d bytes", bytesExpected
  makeRequest()
  return

process.on "exit", ->
  console.error "got %d bytes", uploadCount
  assert.equal uploadCount, bytesExpected
  return

