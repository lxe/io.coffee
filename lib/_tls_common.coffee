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

# Lazily loaded
SecureContext = (secureProtocol, flags, context) ->
  return new SecureContext(secureProtocol, flags, context)  unless this instanceof SecureContext
  if context
    @context = context
  else
    @context = new NativeSecureContext()
    if secureProtocol
      @context.init secureProtocol
    else
      @context.init()
  @context.setOptions flags  if flags
  return
"use strict"
util = require("util")
constants = require("constants")
tls = require("tls")
crypto = null
binding = process.binding("crypto")
NativeSecureContext = binding.SecureContext
exports.SecureContext = SecureContext
exports.createSecureContext = createSecureContext = (options, context) ->
  options = {}  unless options
  secureOptions = options.secureOptions
  secureOptions |= constants.SSL_OP_CIPHER_SERVER_PREFERENCE  if options.honorCipherOrder
  c = new SecureContext(options.secureProtocol, secureOptions, context)
  return c  if context
  
  # NOTE: It's important to add CA before the cert to be able to load
  # cert's issuer in C++ code.
  if options.ca
    if util.isArray(options.ca)
      i = 0
      len = options.ca.length

      while i < len
        c.context.addCACert options.ca[i]
        i++
    else
      c.context.addCACert options.ca
  else
    c.context.addRootCerts()
  if options.cert
    if Array.isArray(options.cert)
      i = 0

      while i < options.cert.length
        c.context.setCert options.cert[i]
        i++
    else
      c.context.setCert options.cert
  
  # NOTE: It is important to set the key after the cert.
  # `ssl_set_pkey` returns `0` when the key does not much the cert, but
  # `ssl_set_cert` returns `1` and nullifies the key in the SSL structure
  # which leads to the crash later on.
  if options.key
    if Array.isArray(options.key)
      i = 0

      while i < options.key.length
        key = options.key[i]
        if key.passphrase
          c.context.setKey key.pem, key.passphrase
        else
          c.context.setKey key
        i++
    else
      if options.passphrase
        c.context.setKey options.key, options.passphrase
      else
        c.context.setKey options.key
  if options.ciphers
    c.context.setCiphers options.ciphers
  else
    c.context.setCiphers tls.DEFAULT_CIPHERS
  if util.isUndefined(options.ecdhCurve)
    c.context.setECDHCurve tls.DEFAULT_ECDH_CURVE
  else c.context.setECDHCurve options.ecdhCurve  if options.ecdhCurve
  c.context.setDHParam options.dhparam  if options.dhparam
  if options.crl
    if util.isArray(options.crl)
      i = 0
      len = options.crl.length

      while i < len
        c.context.addCRL options.crl[i]
        i++
    else
      c.context.addCRL options.crl
  c.context.setSessionIdContext options.sessionIdContext  if options.sessionIdContext
  if options.pfx
    pfx = options.pfx
    passphrase = options.passphrase
    crypto = require("crypto")  unless crypto
    pfx = crypto._toBuf(pfx)
    passphrase = crypto._toBuf(passphrase)  if passphrase
    if passphrase
      c.context.loadPKCS12 pfx, passphrase
    else
      c.context.loadPKCS12 pfx
  c

exports.translatePeerCertificate = translatePeerCertificate = (c) ->
  return null  unless c
  c.issuer = tls.parseCertString(c.issuer)  if c.issuer
  c.issuerCertificate = translatePeerCertificate(c.issuerCertificate)  if c.issuerCertificate and c.issuerCertificate isnt c
  c.subject = tls.parseCertString(c.subject)  if c.subject
  if c.infoAccess
    info = c.infoAccess
    c.infoAccess = {}
    
    # XXX: More key validation?
    info.replace /([^\n:]*):([^\n]*)(?:\n|$)/g, (all, key, val) ->
      return  if key is "__proto__"
      if c.infoAccess.hasOwnProperty(key)
        c.infoAccess[key].push val
      else
        c.infoAccess[key] = [val]
      return

  c
