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
"use strict"
net = require("net")
url = require("url")
util = require("util")

# Allow {CLIENT_RENEG_LIMIT} client-initiated session renegotiations
# every {CLIENT_RENEG_WINDOW} seconds. An error event is emitted if more
# renegotations are seen. The settings are applied to all remote client
# connections.
exports.CLIENT_RENEG_LIMIT = 3
exports.CLIENT_RENEG_WINDOW = 600
exports.SLAB_BUFFER_SIZE = 10 * 1024 * 1024

# TLS 1.2

# TLS 1.0
exports.DEFAULT_CIPHERS = "ECDHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA256:AES128-GCM-SHA256:" + "RC4:HIGH:!MD5:!aNULL"
exports.DEFAULT_ECDH_CURVE = "prime256v1"
exports.getCiphers = ->
  names = process.binding("crypto").getSSLCiphers()
  
  # Drop all-caps names in favor of their lowercase aliases,
  ctx = {}
  names.forEach (name) ->
    name = name.toLowerCase()  if /^[0-9A-Z\-]+$/.test(name)
    ctx[name] = true
    return

  Object.getOwnPropertyNames(ctx).sort()


# Convert protocols array into valid OpenSSL protocols list
# ("\x06spdy/2\x08http/1.1\x08http/1.0")
exports.convertNPNProtocols = convertNPNProtocols = (NPNProtocols, out) ->
  
  # If NPNProtocols is Array - translate it into buffer
  if util.isArray(NPNProtocols)
    buff = new Buffer(NPNProtocols.reduce((p, c) ->
      p + 1 + Buffer.byteLength(c)
    , 0))
    NPNProtocols.reduce ((offset, c) ->
      clen = Buffer.byteLength(c)
      buff[offset] = clen
      buff.write c, offset + 1
      offset + 1 + clen
    ), 0
    NPNProtocols = buff
  
  # If it's already a Buffer - store it
  out.NPNProtocols = NPNProtocols  if util.isBuffer(NPNProtocols)
  return

exports.checkServerIdentity = checkServerIdentity = (host, cert) ->
  
  # Create regexp to much hostnames
  regexpify = (host, wildcards) ->
    
    # Add trailing dot (make hostnames uniform)
    host += "."  unless /\.$/.test(host)
    
    # The same applies to hostname with more than one wildcard,
    # if hostname has wildcard when wildcards are not allowed,
    # or if there are less than two dots after wildcard (i.e. *.com or *d.com)
    #
    # also
    #
    # "The client SHOULD NOT attempt to match a presented identifier in
    # which the wildcard character comprises a label other than the
    # left-most label (e.g., do not match bar.*.example.net)."
    # RFC6125
    return /$./  if not wildcards and /\*/.test(host) or /[\.\*].*\*/.test(host) or /\*/.test(host) and not /\*.*\..+\..+/.test(host)
    
    # Replace wildcard chars with regexp's wildcard and
    # escape all characters that have special meaning in regexps
    # (i.e. '.', '[', '{', '*', and others)
    re = host.replace(/\*([a-z0-9\\-_\.])|[\.,\-\\\^\$+?*\[\]\(\):!\|{}]/g, (all, sub) ->
      return "[a-z0-9\\-_]*" + ((if sub is "-" then "\\-" else sub))  if sub
      "\\" + all
    )
    new RegExp("^" + re + "$", "i")
  dnsNames = []
  uriNames = []
  ips = []
  matchCN = true
  valid = false
  reason = "Unknown reason"
  
  # There're several names to perform check against:
  # CN and altnames in certificate extension
  # (DNS names, IP addresses, and URIs)
  #
  # Walk through altnames and generate lists of those names
  if cert.subjectaltname
    cert.subjectaltname.split(/, /g).forEach (altname) ->
      option = altname.match(/^(DNS|IP Address|URI):(.*)$/)
      return  unless option
      if option[1] is "DNS"
        dnsNames.push option[2]
      else if option[1] is "IP Address"
        ips.push option[2]
      else if option[1] is "URI"
        uri = url.parse(option[2])
        uriNames.push uri.hostname  if uri
      return

  
  # If hostname is an IP address, it should be present in the list of IP
  # addresses.
  if net.isIP(host)
    valid = ips.some((ip) ->
      ip is host
    )
    reason = util.format("IP: %s is not in the cert's list: %s", host, ips.join(", "))  unless valid
  else
    
    # Transform hostname to canonical form
    host += "."  unless /\.$/.test(host)
    
    # Otherwise check all DNS/URI records from certificate
    # (with allowed wildcards)
    dnsNames = dnsNames.map((name) ->
      regexpify name, true
    )
    
    # Wildcards ain't allowed in URI names
    uriNames = uriNames.map((name) ->
      regexpify name, false
    )
    dnsNames = dnsNames.concat(uriNames)
    matchCN = false  if dnsNames.length > 0
    
    # Match against Common Name (CN) only if no supported identifiers are
    # present.
    #
    # "As noted, a client MUST NOT seek a match for a reference identifier
    #  of CN-ID if the presented identifiers include a DNS-ID, SRV-ID,
    #  URI-ID, or any application-specific identifier types supported by the
    #  client."
    # RFC6125
    if matchCN
      commonNames = cert.subject.CN
      if util.isArray(commonNames)
        i = 0
        k = commonNames.length

        while i < k
          dnsNames.push regexpify(commonNames[i], true)
          ++i
      else
        dnsNames.push regexpify(commonNames, true)
    valid = dnsNames.some((re) ->
      re.test host
    )
    unless valid
      if cert.subjectaltname
        reason = util.format("Host: %s is not in the cert's altnames: %s", host, cert.subjectaltname)
      else
        reason = util.format("Host: %s is not cert's CN: %s", host, cert.subject.CN)
  unless valid
    err = new Error(util.format("Hostname/IP doesn't match certificate's altnames: %j", reason))
    err.reason = reason
    err.host = host
    err.cert = cert
    err


# Example:
# C=US\nST=CA\nL=SF\nO=Joyent\nOU=Node.js\nCN=ca1\nemailAddress=ry@clouds.org
exports.parseCertString = parseCertString = (s) ->
  out = {}
  parts = s.split("\n")
  i = 0
  len = parts.length

  while i < len
    sepIndex = parts[i].indexOf("=")
    if sepIndex > 0
      key = parts[i].slice(0, sepIndex)
      value = parts[i].slice(sepIndex + 1)
      if key of out
        out[key] = [out[key]]  unless util.isArray(out[key])
        out[key].push value
      else
        out[key] = value
    i++
  out


# Public API
exports.createSecureContext = require("_tls_common").createSecureContext
exports.SecureContext = require("_tls_common").SecureContext
exports.TLSSocket = require("_tls_wrap").TLSSocket
exports.Server = require("_tls_wrap").Server
exports.createServer = require("_tls_wrap").createServer
exports.connect = require("_tls_wrap").connect
exports.createSecurePair = require("_tls_legacy").createSecurePair
