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

# monkey-patch the log functions so they include name + pid
patch = (fun) ->
  prefix = process.title + "[" + process.pid + "] "
  ->
    args = Array::slice.call(arguments)
    args[0] = prefix + args[0]
    fun.apply console, args
startMaster = ->
  return startServer()  unless cluster.isMaster
  i = ~~options.servers

  while i > 0
    cluster.fork()
    --i
  i = ~~options.clients

  while i > 0
    cp = spawn(process.execPath, [
      __filename
      "mode=client"
    ])
    cp.stdout.pipe process.stdout
    cp.stderr.pipe process.stderr
    --i
  return
startServer = ->
  onRequest = (req, res) ->
    req.on "error", onError
    res.on "error", onError
    res.writeHead 200, headers
    res.end body
    return
  onError = (err) ->
    console.error err.stack
    return
  http.createServer(onRequest).listen options.port, options.host
  body = Array(1024).join("x")
  headers = "Content-Length": "" + body.length
  return
startClient = ->
  
  # send off a bunch of concurrent requests
  # TODO make configurable
  sendRequest = ->
    req = http.request(options, onConnection)
    req.on "error", onError
    req.end()
    return
  
  # add a little back-off to prevent EADDRNOTAVAIL errors, it's pretty easy
  # to exhaust the available port range
  relaxedSendRequest = ->
    setTimeout sendRequest, 1
    return
  onConnection = (res) ->
    res.on "error", onError
    res.on "data", onData
    res.on "end", relaxedSendRequest
    return
  onError = (err) ->
    console.error err.stack
    relaxedSendRequest()
    return
  onData = (data) ->
  sendRequest()
  sendRequest()
  return
spawn = require("child_process").spawn
cluster = require("cluster")
http = require("http")
options =
  mode: "master"
  host: "127.0.0.1"
  port: 22344
  path: "/"
  servers: 1
  clients: 1

i = 2

while i < process.argv.length
  args = process.argv[i].split("=", 2)
  key = args[0]
  val = args[1]
  options[key] = val
  ++i
switch options.mode
  when "master"
    startMaster()
  when "server"
    startServer()
  when "client"
    startClient()
  else
    throw new Error("Bad mode: " + options.mode)
process.title = "http_bench[" + options.mode + "]"
console.log = patch(console.log)
console.trace = patch(console.trace)
console.error = patch(console.error)

# this space intentionally left blank
