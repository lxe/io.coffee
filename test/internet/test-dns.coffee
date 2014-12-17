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
TEST = (f) ->
  next = ->
    f = queue.shift()
    if f
      running = true
      console.log f.name
      f done
    return
  done = ->
    running = false
    completed++
    process.nextTick next
    return
  expected++
  queue.push f
  next()  unless running
  return
checkWrap = (req) ->
  assert.ok typeof req is "object"
  return
common = require("../common")
assert = require("assert")
dns = require("dns")
net = require("net")
isIP = net.isIP
isIPv4 = net.isIPv4
isIPv6 = net.isIPv6
util = require("util")
expected = 0
completed = 0
running = false
queue = []
TEST test_resolve4 = (done) ->
  req = dns.resolve4("www.google.com", (err, ips) ->
    throw err  if err
    assert.ok ips.length > 0
    i = 0

    while i < ips.length
      assert.ok isIPv4(ips[i])
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolve6 = (done) ->
  req = dns.resolve6("ipv6.google.com", (err, ips) ->
    throw err  if err
    assert.ok ips.length > 0
    i = 0

    while i < ips.length
      assert.ok isIPv6(ips[i])
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_reverse_ipv4 = (done) ->
  req = dns.reverse("8.8.8.8", (err, domains) ->
    throw err  if err
    assert.ok domains.length > 0
    i = 0

    while i < domains.length
      assert.ok domains[i]
      assert.ok typeof domains[i] is "string"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_reverse_ipv6 = (done) ->
  req = dns.reverse("2001:4860:4860::8888", (err, domains) ->
    throw err  if err
    assert.ok domains.length > 0
    i = 0

    while i < domains.length
      assert.ok domains[i]
      assert.ok typeof domains[i] is "string"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_reverse_bogus = (done) ->
  error = undefined
  try
    req = dns.reverse("bogus ip", ->
      assert.ok false
      return
    )
  catch e
    error = e
  assert.ok error instanceof Error
  assert.strictEqual error.errno, "EINVAL"
  done()
  return

TEST test_resolveMx = (done) ->
  req = dns.resolveMx("gmail.com", (err, result) ->
    throw err  if err
    assert.ok result.length > 0
    i = 0

    while i < result.length
      item = result[i]
      assert.ok item
      assert.ok typeof item is "object"
      assert.ok item.exchange
      assert.ok typeof item.exchange is "string"
      assert.ok typeof item.priority is "number"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveNs = (done) ->
  req = dns.resolveNs("rackspace.com", (err, names) ->
    throw err  if err
    assert.ok names.length > 0
    i = 0

    while i < names.length
      name = names[i]
      assert.ok name
      assert.ok typeof name is "string"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveSrv = (done) ->
  req = dns.resolveSrv("_jabber._tcp.google.com", (err, result) ->
    throw err  if err
    assert.ok result.length > 0
    i = 0

    while i < result.length
      item = result[i]
      assert.ok item
      assert.ok typeof item is "object"
      assert.ok item.name
      assert.ok typeof item.name is "string"
      assert.ok typeof item.port is "number"
      assert.ok typeof item.priority is "number"
      assert.ok typeof item.weight is "number"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveNaptr = (done) ->
  req = dns.resolveNaptr("sip2sip.info", (err, result) ->
    throw err  if err
    assert.ok result.length > 0
    i = 0

    while i < result.length
      item = result[i]
      assert.ok item
      assert.ok typeof item is "object"
      assert.ok typeof item.flags is "string"
      assert.ok typeof item.service is "string"
      assert.ok typeof item.regexp is "string"
      assert.ok typeof item.replacement is "string"
      assert.ok typeof item.order is "number"
      assert.ok typeof item.preference is "number"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveSoa = (done) ->
  req = dns.resolveSoa("nodejs.org", (err, result) ->
    throw err  if err
    assert.ok result
    assert.ok typeof result is "object"
    assert.ok typeof result.nsname is "string"
    assert.ok result.nsname.length > 0
    assert.ok typeof result.hostmaster is "string"
    assert.ok result.hostmaster.length > 0
    assert.ok typeof result.serial is "number"
    assert.ok (result.serial > 0) and (result.serial < 4294967295)
    assert.ok typeof result.refresh is "number"
    assert.ok (result.refresh > 0) and (result.refresh < 2147483647)
    assert.ok typeof result.retry is "number"
    assert.ok (result.retry > 0) and (result.retry < 2147483647)
    assert.ok typeof result.expire is "number"
    assert.ok (result.expire > 0) and (result.expire < 2147483647)
    assert.ok typeof result.minttl is "number"
    assert.ok (result.minttl >= 0) and (result.minttl < 2147483647)
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveCname = (done) ->
  req = dns.resolveCname("www.microsoft.com", (err, names) ->
    throw err  if err
    assert.ok names.length > 0
    i = 0

    while i < names.length
      name = names[i]
      assert.ok name
      assert.ok typeof name is "string"
      i++
    done()
    return
  )
  checkWrap req
  return

TEST test_resolveTxt = (done) ->
  req = dns.resolveTxt("google.com", (err, records) ->
    throw err  if err
    assert.equal records.length, 1
    assert.ok util.isArray(records[0])
    assert.equal records[0][0].indexOf("v=spf1"), 0
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv4_explicit = (done) ->
  req = dns.lookup("www.google.com", 4, (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv4(ip)
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv4_implicit = (done) ->
  req = dns.lookup("www.google.com", (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv4(ip)
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv4_explicit_object = (done) ->
  req = dns.lookup("www.google.com",
    family: 4
  , (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv4(ip)
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv4_hint_addrconfig = (done) ->
  req = dns.lookup("www.google.com",
    hints: dns.ADDRCONFIG
  , (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv4(ip)
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv6_explicit = (done) ->
  req = dns.lookup("ipv6.google.com", 6, (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv6(ip)
    assert.strictEqual family, 6
    done()
    return
  )
  checkWrap req
  return


# This ends up just being too problematic to test
#TEST(function test_lookup_ipv6_implicit(done) {
#  var req = dns.lookup('ipv6.google.com', function(err, ip, family) {
#    if (err) throw err;
#    assert.ok(net.isIPv6(ip));
#    assert.strictEqual(family, 6);
#
#    done();
#  });
#
#  checkWrap(req);
#});
#
TEST test_lookup_ipv6_explicit_object = (done) ->
  req = dns.lookup("ipv6.google.com",
    family: 6
  , (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv6(ip)
    assert.strictEqual family, 6
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ipv6_hint = (done) ->
  req = dns.lookup("www.google.com",
    family: 6
    hints: dns.V4MAPPED
  , (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv6(ip)
    assert.strictEqual family, 6
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_failure = (done) ->
  req = dns.lookup("does.not.exist", 4, (err, ip, family) ->
    assert.ok err instanceof Error
    assert.strictEqual err.errno, dns.NOTFOUND
    assert.strictEqual err.errno, "ENOTFOUND"
    assert.ok not /ENOENT/.test(err.message)
    assert.ok /does\.not\.exist/.test(err.message)
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_null = (done) ->
  req = dns.lookup(null, (err, ip, family) ->
    throw err  if err
    assert.strictEqual ip, null
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ip_ipv4 = (done) ->
  req = dns.lookup("127.0.0.1", (err, ip, family) ->
    throw err  if err
    assert.strictEqual ip, "127.0.0.1"
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_ip_ipv6 = (done) ->
  req = dns.lookup("::1", (err, ip, family) ->
    throw err  if err
    assert.ok net.isIPv6(ip)
    assert.strictEqual family, 6
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_localhost_ipv4 = (done) ->
  req = dns.lookup("localhost", 4, (err, ip, family) ->
    throw err  if err
    assert.strictEqual ip, "127.0.0.1"
    assert.strictEqual family, 4
    done()
    return
  )
  checkWrap req
  return

TEST test_lookupservice_ip_ipv4 = (done) ->
  req = dns.lookupService("127.0.0.1", 80, (err, host, service) ->
    throw err  if err
    assert.ok common.isValidHostname(host)
    
    #
    #     * Retrieve the actual HTTP service name as setup on the host currently
    #     * running the test by reading it from /etc/services. This is not ideal,
    #     * as the service name lookup could use another mechanism (e.g nscd), but
    #     * it's already better than hardcoding it.
    #     
    httpServiceName = common.getServiceName(80, "tcp")
    
    #
    #       * Couldn't find service name, reverting to the most sensible default
    #       * for port 80.
    #       
    httpServiceName = "http"  unless httpServiceName
    assert.strictEqual service, httpServiceName
    done()
    return
  )
  checkWrap req
  return

TEST test_lookupservice_ip_ipv6 = (done) ->
  req = dns.lookupService("::1", 80, (err, host, service) ->
    throw err  if err
    assert.ok common.isValidHostname(host)
    
    #
    #     * Retrieve the actual HTTP service name as setup on the host currently
    #     * running the test by reading it from /etc/services. This is not ideal,
    #     * as the service name lookup could use another mechanism (e.g nscd), but
    #     * it's already better than hardcoding it.
    #     
    httpServiceName = common.getServiceName(80, "tcp")
    
    #
    #       * Couldn't find service name, reverting to the most sensible default
    #       * for port 80.
    #       
    httpServiceName = "http"  unless httpServiceName
    assert.strictEqual service, httpServiceName
    done()
    return
  )
  checkWrap req
  return

TEST test_lookupservice_invalid = (done) ->
  req = dns.lookupService("1.2.3.4", 80, (err, host, service) ->
    assert err instanceof Error
    assert.strictEqual err.code, "ENOTFOUND"
    assert.ok /1\.2\.3\.4/.test(err.message)
    done()
    return
  )
  checkWrap req
  return

TEST test_reverse_failure = (done) ->
  req = dns.reverse("0.0.0.0", (err) ->
    assert err instanceof Error
    assert.strictEqual err.code, "ENOTFOUND" # Silly error code...
    assert.strictEqual err.hostname, "0.0.0.0"
    assert.ok /0\.0\.0\.0/.test(err.message)
    done()
    return
  )
  checkWrap req
  return

TEST test_lookup_failure = (done) ->
  req = dns.lookup("nosuchhostimsure", (err) ->
    assert err instanceof Error
    assert.strictEqual err.code, "ENOTFOUND" # Silly error code...
    assert.strictEqual err.hostname, "nosuchhostimsure"
    assert.ok /nosuchhostimsure/.test(err.message)
    done()
    return
  )
  checkWrap req
  return

TEST test_resolve_failure = (done) ->
  req = dns.resolve4("nosuchhostimsure", (err) ->
    assert err instanceof Error
    switch err.code
      when "ENOTFOUND", "ESERVFAIL"
      else
        assert.strictEqual err.code, "ENOTFOUND" # Silly error code...
    assert.strictEqual err.hostname, "nosuchhostimsure"
    assert.ok /nosuchhostimsure/.test(err.message)
    done()
    return
  )
  checkWrap req
  return


# Disabled because it appears to be not working on linux. 

# TEST(function test_lookup_localhost_ipv6(done) {
#  var req = dns.lookup('localhost', 6, function(err, ip, family) {
#    if (err) throw err;
#    assert.ok(net.isIPv6(ip));
#    assert.strictEqual(family, 6);
#
#    done();
#  });
#
#  checkWrap(req);
#}); 
getaddrinfoCallbackCalled = false
console.log "looking up nodejs.org..."
cares = process.binding("cares_wrap")
req = new cares.GetAddrInfoReqWrap()
err = cares.getaddrinfo(req, "nodejs.org", 4)
req.oncomplete = (err, domains) ->
  assert.strictEqual err, 0
  console.log "nodejs.org = ", domains
  assert.ok Array.isArray(domains)
  assert.ok domains.length >= 1
  assert.ok typeof domains[0] is "string"
  getaddrinfoCallbackCalled = true
  return

process.on "exit", ->
  console.log completed + " tests completed"
  assert.equal running, false
  assert.strictEqual expected, completed
  assert.ok getaddrinfoCallbackCalled
  return

