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

# disable strict server certificate validation by the client
file = (fname) ->
  path.resolve common.fixturesDir, "keys", fname
read = (fname) ->
  fs.readFileSync file(fname)

# key1 is signed by ca1.

# key2 has a self signed cert

# key3 is signed by ca2.

# different agents to use different CA lists.
# this api is beyond bad.
server = (options, port) ->
  s = https.createServer(options, handler)
  s.requests = []
  s.expectCount = 0
  s
handler = (req, res) ->
  @requests.push req.url
  res.statusCode = 200
  res.setHeader "foo", "bar"
  res.end "hello, world\n"
  return
listening = ->
  listenWait++
  ->
    listenWait--
    allListening()  if listenWait is 0
    return
makeReq = (path, port, error, host, ca) ->
  pending++
  options =
    port: port
    path: path
    ca: ca

  whichCa = 0
  unless ca
    options.agent = agent0
  else
    ca = [ca]  unless Array.isArray(ca)
    if -1 isnt ca.indexOf(ca1) and -1 isnt ca.indexOf(ca2)
      options.agent = agent3
    else if -1 isnt ca.indexOf(ca1)
      options.agent = agent1
    else if -1 isnt ca.indexOf(ca2)
      options.agent = agent2
    else
      options.agent = agent0
  options.headers = host: host  if host
  req = https.get(options)
  expectResponseCount++
  server = (if port is port1 then server1 else (if port is port2 then server2 else (if port is port3 then server3 else null)))
  throw new Error("invalid port: " + port)  unless server
  server.expectCount++
  req.on "response", (res) ->
    responseCount++
    assert.equal res.connection.authorizationError, error
    responseErrors[path] = res.connection.authorizationError
    pending--
    if pending is 0
      server1.close()
      server2.close()
      server3.close()
    res.resume()
    return

  return
allListening = ->
  
  # ok, ready to start the tests!
  
  # server1: host 'agent1', signed by ca1
  makeReq "/inv1", port1, "UNABLE_TO_VERIFY_LEAF_SIGNATURE"
  makeReq "/inv1-ca1", port1, "Hostname/IP doesn't match certificate's altnames: " + "\"Host: localhost. is not cert's CN: agent1\"", null, ca1
  makeReq "/inv1-ca1ca2", port1, "Hostname/IP doesn't match certificate's altnames: " + "\"Host: localhost. is not cert's CN: agent1\"", null, [
    ca1
    ca2
  ]
  makeReq "/val1-ca1", port1, null, "agent1", ca1
  makeReq "/val1-ca1ca2", port1, null, "agent1", [
    ca1
    ca2
  ]
  makeReq "/inv1-ca2", port1, "UNABLE_TO_VERIFY_LEAF_SIGNATURE", "agent1", ca2
  
  # server2: self-signed, host = 'agent2'
  # doesn't matter that thename matches, all of these will error.
  makeReq "/inv2", port2, "DEPTH_ZERO_SELF_SIGNED_CERT"
  makeReq "/inv2-ca1", port2, "DEPTH_ZERO_SELF_SIGNED_CERT", "agent2", ca1
  makeReq "/inv2-ca1ca2", port2, "DEPTH_ZERO_SELF_SIGNED_CERT", "agent2", [
    ca1
    ca2
  ]
  
  # server3: host 'agent3', signed by ca2
  makeReq "/inv3", port3, "UNABLE_TO_VERIFY_LEAF_SIGNATURE"
  makeReq "/inv3-ca2", port3, "Hostname/IP doesn't match certificate's altnames: " + "\"Host: localhost. is not cert's CN: agent3\"", null, ca2
  makeReq "/inv3-ca1ca2", port3, "Hostname/IP doesn't match certificate's altnames: " + "\"Host: localhost. is not cert's CN: agent3\"", null, [
    ca1
    ca2
  ]
  makeReq "/val3-ca2", port3, null, "agent3", ca2
  makeReq "/val3-ca1ca2", port3, null, "agent3", [
    ca1
    ca2
  ]
  makeReq "/inv3-ca1", port3, "UNABLE_TO_VERIFY_LEAF_SIGNATURE", "agent1", ca1
  return
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
common = require("../common")
assert = require("assert")
fs = require("fs")
path = require("path")
https = require("https")
key1 = read("agent1-key.pem")
cert1 = read("agent1-cert.pem")
key2 = read("agent2-key.pem")
cert2 = read("agent2-cert.pem")
key3 = read("agent3-key.pem")
cert3 = read("agent3-cert.pem")
ca1 = read("ca1-cert.pem")
ca2 = read("ca2-cert.pem")
agent0 = new https.Agent()
agent1 = new https.Agent(ca: [ca1])
agent2 = new https.Agent(ca: [ca2])
agent3 = new https.Agent(ca: [
  ca1
  ca2
])
options1 =
  key: key1
  cert: cert1

options2 =
  key: key2
  cert: cert2

options3 =
  key: key3
  cert: cert3

server1 = server(options1)
server2 = server(options2)
server3 = server(options3)
listenWait = 0
port = common.PORT
port1 = port++
port2 = port++
port3 = port++
server1.listen port1, listening()
server2.listen port2, listening()
server3.listen port3, listening()
responseErrors = {}
expectResponseCount = 0
responseCount = 0
pending = 0
process.on "exit", ->
  console.error responseErrors
  assert.equal server1.requests.length, server1.expectCount
  assert.equal server2.requests.length, server2.expectCount
  assert.equal server3.requests.length, server3.expectCount
  assert.equal responseCount, expectResponseCount
  return

