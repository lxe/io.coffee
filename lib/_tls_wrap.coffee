# Copyright Joyent, Inc. and other Node contributors.
#
# // Emit `beforeExit` if the loop became alive either after emitting
# event, or after running some callbacks.
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

# Lazy load
onhandshakestart = ->
  debug "onhandshakestart"
  self = this
  ssl = self.ssl
  now = Timer.now()
  assert now >= ssl.lastHandshakeTime
  ssl.handshakes = 0  if (now - ssl.lastHandshakeTime) >= tls.CLIENT_RENEG_WINDOW * 1000
  first = (ssl.lastHandshakeTime is 0)
  ssl.lastHandshakeTime = now
  return  if first
  if ++ssl.handshakes > tls.CLIENT_RENEG_LIMIT
    
    # Defer the error event to the next tick. We're being called from OpenSSL's
    # state machine and OpenSSL is not re-entrant. We cannot allow the user's
    # callback to destroy the connection right now, it would crash and burn.
    setImmediate ->
      err = new Error("TLS session renegotiation attack detected.")
      self._tlsError err
      return

  return
onhandshakedone = ->
  
  # for future use
  debug "onhandshakedone"
  @_finishInit()
  return
loadSession = (self, hello, cb) ->
  onSession = (err, session) ->
    return cb(new Error("TLS session callback was called 2 times"))  if once
    once = true
    return cb(err)  if err
    
    # NOTE: That we have disabled OpenSSL's internal session storage in
    # `node_crypto.cc` and hence its safe to rely on getting servername only
    # from clienthello or this place.
    ret = self.ssl.loadSession(session)
    cb null, ret
    return
  once = false
  cb null  if hello.sessionId.length <= 0 or hello.tlsTicket or self.server and not self.server.emit("resumeSession", hello.sessionId, onSession)
  return
loadSNI = (self, servername, cb) ->
  return cb(null)  if not servername or not self._SNICallback
  once = false
  self._SNICallback servername, (err, context) ->
    return cb(new Error("TLS SNI callback was called 2 times"))  if once
    once = true
    return cb(err)  if err
    
    # TODO(indutny): eventually disallow raw `SecureContext`
    self.ssl.sni_context = context.context or context  if context
    cb null, self.ssl.sni_context
    return

  return
requestOCSP = (self, hello, ctx, cb) ->
  onOCSP = (err, response) ->
    return cb(new Error("TLS OCSP callback was called 2 times"))  if once
    once = true
    return cb(err)  if err
    self.ssl.setOCSPResponse response  if response
    cb null
    return
  return cb(null)  if not hello.OCSPRequest or not self.server
  ctx = self.server._sharedCreds  unless ctx
  ctx = ctx.context  if ctx.context
  if listenerCount(self.server, "OCSPRequest") is 0
    return cb(null)
  else
    self.server.emit "OCSPRequest", ctx.getCertificate(), ctx.getIssuer(), onOCSP
  once = false
  return
onclienthello = (hello) ->
  self = this
  loadSession self, hello, (err, session) ->
    return self.destroy(err)  if err
    
    # Servername came from SSL session
    # NOTE: TLS Session ticket doesn't include servername information
    #
    # Another note, From RFC3546:
    #
    #   If, on the other hand, the older
    #   session is resumed, then the server MUST ignore extensions appearing
    #   in the client hello, and send a server hello containing no
    #   extensions; in this case the extension functionality negotiated
    #   during the original session initiation is applied to the resumed
    #   session.
    #
    # Therefore we should account session loading when dealing with servername
    servername = session and session.servername or hello.servername
    loadSNI self, servername, (err, ctx) ->
      return self.destroy(err)  if err
      requestOCSP self, hello, ctx, (err) ->
        return self.destroy(err)  if err
        self.ssl.endParser()
        return

      return

    return

  return
onnewsession = (key, session) ->
  done = ->
    return  if once
    once = true
    self.ssl.newSessionDone()
    self._newSessionPending = false
    self._finishInit()  if self._securePending
    self._securePending = false
    return
  return  unless @server
  self = this
  once = false
  @_newSessionPending = true
  done()  unless @server.emit("newSession", key, session, done)
  return
onocspresponse = (resp) ->
  @emit "OCSPResponse", resp
  return

###*
Provides a wrap of socket stream to do encrypted communication.
###
TLSSocket = (socket, options) ->
  
  # Disallow wrapping TLSSocket in TLSSocket
  assert (socket not instanceof TLSSocket)
  net.Socket.call this,
    handle: socket and socket._handle
    allowHalfOpen: socket and socket.allowHalfOpen
    readable: false
    writable: false

  
  # To prevent assertion in afterConnect()
  @_connecting = socket._connecting  if socket
  @_tlsOptions = options
  @_secureEstablished = false
  @_securePending = false
  @_newSessionPending = false
  @_controlReleased = false
  @_SNICallback = null
  @ssl = null
  @servername = null
  @npnProtocol = null
  @authorized = false
  @authorizationError = null
  
  # Just a documented property to make secure sockets
  # distinguishable from regular ones.
  @encrypted = true
  @on "error", @_tlsError
  unless @_handle
    @once "connect", ->
      @_init null
      return

  else
    @_init socket
  
  # Make sure to setup all required properties like: `_connecting` before
  # starting the flow of the data
  @readable = true
  @writable = true
  @read 0
  return

# lib/net.js expect this value to be non-zero if write hasn't been flushed
# immediately
# TODO(indutny): rewise this solution, it might be 1 before handshake and
# represent real writeQueueSize during regular writes.

# Wrap socket's handle

# For clients, we will always have either a given ca list or be using
# default one

# Destroy socket if error happened before handshake's finish

# Ignore server's authorization errors

# Throw error

# If custom SNICallback was given, or if
# there're SNI contexts to perform match against -
# set `.onsniselect` callback.

# Socket already has some buffered data - emulate receiving it

# Ensure that we'll cycle through internal openssl's state

# `newSession` callback wasn't called yet

# TODO: support anonymous (nocert) and PSK

# AUTHENTICATION MODES
#
# There are several levels of authentication that TLS/SSL supports.
# Read more about this in "man SSL_set_verify".
#
# 1. The server sends a certificate to the client but does not request a
# cert from the client. This is common for most HTTPS servers. The browser
# can verify the identity of the server, but the server does not know who
# the client is. Authenticating the client is usually done over HTTP using
# login boxes and cookies and stuff.
#
# 2. The server sends a cert to the client and requests that the client
# also send it a cert. The client knows who the server is and the server is
# requesting the client also identify themselves. There are several
# outcomes:
#
#   A) verifyError returns null meaning the client's certificate is signed
#   by one of the server's CAs. The server know's the client idenity now
#   and the client is authorized.
#
#   B) For some reason the client's certificate is not acceptable -
#   verifyError returns a string indicating the problem. The server can
#   either (i) reject the client or (ii) allow the client to connect as an
#   unauthorized connection.
#
# The mode is controlled by two boolean variables.
#
# requestCert
#   If true the server requests a certificate from client connections. For
#   the common HTTPS case, users will want this to be false, which is what
#   it defaults to.
#
# rejectUnauthorized
#   If true clients whose certificates are invalid for any reason will not
#   be allowed to make connections. If false, they will simply be marked as
#   unauthorized but secure communication will continue. By default this is
#   true.
#
#
#
# Options:
# - requestCert. Send verify request. Default to false.
# - rejectUnauthorized. Boolean, default to true.
# - key. string.
# - cert: string.
# - ca: string or array of strings.
# - sessionTimeout: integer.
#
# emit 'secureConnection'
#   function (tlsSocket) { }
#
#   "UNABLE_TO_GET_ISSUER_CERT", "UNABLE_TO_GET_CRL",
#   "UNABLE_TO_DECRYPT_CERT_SIGNATURE", "UNABLE_TO_DECRYPT_CRL_SIGNATURE",
#   "UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY", "CERT_SIGNATURE_FAILURE",
#   "CRL_SIGNATURE_FAILURE", "CERT_NOT_YET_VALID" "CERT_HAS_EXPIRED",
#   "CRL_NOT_YET_VALID", "CRL_HAS_EXPIRED" "ERROR_IN_CERT_NOT_BEFORE_FIELD",
#   "ERROR_IN_CERT_NOT_AFTER_FIELD", "ERROR_IN_CRL_LAST_UPDATE_FIELD",
#   "ERROR_IN_CRL_NEXT_UPDATE_FIELD", "OUT_OF_MEM",
#   "DEPTH_ZERO_SELF_SIGNED_CERT", "SELF_SIGNED_CERT_IN_CHAIN",
#   "UNABLE_TO_GET_ISSUER_CERT_LOCALLY", "UNABLE_TO_VERIFY_LEAF_SIGNATURE",
#   "CERT_CHAIN_TOO_LONG", "CERT_REVOKED" "INVALID_CA",
#   "PATH_LENGTH_EXCEEDED", "INVALID_PURPOSE" "CERT_UNTRUSTED",
#   "CERT_REJECTED"
#
Server = -> # [options], listener
  options = undefined
  listener = undefined
  if util.isObject(arguments[0])
    options = arguments[0]
    listener = arguments[1]
  else if util.isFunction(arguments[0])
    options = {}
    listener = arguments[0]
  return new Server(options, listener)  unless this instanceof Server
  @_contexts = []
  self = this
  
  # Handle option defaults:
  @setOptions options
  sharedCreds = tls.createSecureContext(
    pfx: self.pfx
    key: self.key
    passphrase: self.passphrase
    cert: self.cert
    ca: self.ca
    ciphers: self.ciphers
    ecdhCurve: self.ecdhCurve
    dhparam: self.dhparam
    secureProtocol: self.secureProtocol
    secureOptions: self.secureOptions
    honorCipherOrder: self.honorCipherOrder
    crl: self.crl
    sessionIdContext: self.sessionIdContext
  )
  @_sharedCreds = sharedCreds
  timeout = options.handshakeTimeout or (120 * 1000)
  throw new TypeError("handshakeTimeout must be a number")  unless util.isNumber(timeout)
  sharedCreds.context.setSessionTimeout self.sessionTimeout  if self.sessionTimeout
  sharedCreds.context.setTicketKeys self.ticketKeys  if self.ticketKeys
  
  # constructor call
  net.Server.call this, (raw_socket) ->
    socket = new TLSSocket(raw_socket,
      secureContext: sharedCreds
      isServer: true
      server: self
      requestCert: self.requestCert
      rejectUnauthorized: self.rejectUnauthorized
      handshakeTimeout: timeout
      NPNProtocols: self.NPNProtocols
      SNICallback: options.SNICallback or SNICallback
    )
    socket.on "secure", ->
      if socket._requestCert
        verifyError = socket.ssl.verifyError()
        if verifyError
          socket.authorizationError = verifyError.code
          socket.destroy()  if socket._rejectUnauthorized
        else
          socket.authorized = true
      self.emit "secureConnection", socket  if not socket.destroyed and socket._releaseControl()
      return

    errorEmitted = false
    socket.on "close", ->
      
      # Emit ECONNRESET
      if not socket._controlReleased and not errorEmitted
        errorEmitted = true
        connReset = new Error("socket hang up")
        connReset.code = "ECONNRESET"
        self.emit "clientError", connReset, socket
      return

    socket.on "_tlsError", (err) ->
      if not socket._controlReleased and not errorEmitted
        errorEmitted = true
        self.emit "clientError", err, socket
      return

    return

  @on "secureConnection", listener  if listener
  return

# SNI Contexts High-Level API
SNICallback = (servername, callback) ->
  ctx = undefined
  @server._contexts.some (elem) ->
    unless util.isNull(servername.match(elem[0]))
      ctx = elem[1]
      true

  callback null, ctx
  return

# Target API:
#
#  var s = tls.connect({port: 8000, host: "google.com"}, function() {
#    if (!s.authorized) {
#      s.destroy();
#      return;
#    }
#
#    // s.socket;
#
#    s.end("hello world\n");
#  });
#
#
normalizeConnectArgs = (listArgs) ->
  args = net._normalizeConnectArgs(listArgs)
  options = args[0]
  cb = args[1]
  if util.isObject(listArgs[1])
    options = util._extend(options, listArgs[1])
  else options = util._extend(options, listArgs[2])  if util.isObject(listArgs[2])
  (if (cb) then [
    options
    cb
  ] else [options])
legacyConnect = (hostname, options, NPN, context) ->
  assert options.socket
  tls_legacy = require("_tls_legacy")  unless tls_legacy
  pair = tls_legacy.createSecurePair(context, false, true, !!options.rejectUnauthorized,
    NPNProtocols: NPN.NPNProtocols
    servername: hostname
  )
  tls_legacy.pipe pair, options.socket
  pair.cleartext._controlReleased = true
  pair.on "error", (err) ->
    pair.cleartext.emit "error", err
    return

  pair
"use strict"
assert = require("assert")
crypto = require("crypto")
net = require("net")
tls = require("tls")
util = require("util")
listenerCount = require("events").listenerCount
common = require("_tls_common")
Timer = process.binding("timer_wrap").Timer
tls_wrap = process.binding("tls_wrap")
tls_legacy = undefined
debug = util.debuglog("tls")
util.inherits TLSSocket, net.Socket
exports.TLSSocket = TLSSocket
TLSSocket::_init = (socket) ->
  assert @_handle
  @_handle.writeQueueSize = 1
  self = this
  options = @_tlsOptions
  context = options.secureContext or options.credentials or tls.createSecureContext()
  @ssl = tls_wrap.wrap(@_handle, context.context, options.isServer)
  @server = options.server or null
  requestCert = !!options.requestCert or not options.isServer
  rejectUnauthorized = !!options.rejectUnauthorized
  @_requestCert = requestCert
  @_rejectUnauthorized = rejectUnauthorized
  @ssl.setVerifyMode requestCert, rejectUnauthorized  if requestCert or rejectUnauthorized
  if options.isServer
    @ssl.onhandshakestart = onhandshakestart.bind(this)
    @ssl.onhandshakedone = onhandshakedone.bind(this)
    @ssl.onclienthello = onclienthello.bind(this)
    @ssl.onnewsession = onnewsession.bind(this)
    @ssl.lastHandshakeTime = 0
    @ssl.handshakes = 0
    @ssl.enableSessionCallbacks()  if @server and (listenerCount(@server, "resumeSession") > 0 or listenerCount(@server, "newSession") > 0 or listenerCount(@server, "OCSPRequest") > 0)
  else
    @ssl.onhandshakestart = ->

    @ssl.onhandshakedone = @_finishInit.bind(this)
    @ssl.onocspresponse = onocspresponse.bind(this)
    @ssl.setSession options.session  if options.session
  @ssl.onerror = (err) ->
    return  if self._writableState.errorEmitted
    self._writableState.errorEmitted = true
    unless @_secureEstablished
      self._tlsError err
      self.destroy()
    else if options.isServer and rejectUnauthorized and /peer did not return a certificate/.test(err.message)
      self.destroy()
    else
      self._tlsError err
    return

  if process.features.tls_sni and options.isServer and options.server and (options.SNICallback isnt SNICallback or options.server._contexts.length)
    assert typeof options.SNICallback is "function"
    @_SNICallback = options.SNICallback
    @ssl.enableHelloParser()
  @ssl.setNPNProtocols options.NPNProtocols  if process.features.tls_npn and options.NPNProtocols
  @setTimeout options.handshakeTimeout, @_handleTimeout  if options.handshakeTimeout > 0
  if socket and socket._readableState.length
    buf = undefined
    @ssl.receive buf  while (buf = socket.read()) isnt null
  return

TLSSocket::renegotiate = (options, callback) ->
  requestCert = @_requestCert
  rejectUnauthorized = @_rejectUnauthorized
  requestCert = !!options.requestCert  if typeof options.requestCert isnt "undefined"
  rejectUnauthorized = !!options.rejectUnauthorized  if typeof options.rejectUnauthorized isnt "undefined"
  if requestCert isnt @_requestCert or rejectUnauthorized isnt @_rejectUnauthorized
    @ssl.setVerifyMode requestCert, rejectUnauthorized
    @_requestCert = requestCert
    @_rejectUnauthorized = rejectUnauthorized
  unless @ssl.renegotiate()
    if callback
      process.nextTick ->
        callback new Error("Failed to renegotiate")
        return

    return false
  @write ""
  if callback
    @once "secure", ->
      callback null
      return

  true

TLSSocket::setMaxSendFragment = setMaxSendFragment = (size) ->
  @ssl.setMaxSendFragment(size) is 1

TLSSocket::getTLSTicket = getTLSTicket = ->
  @ssl.getTLSTicket()

TLSSocket::_handleTimeout = ->
  @_tlsError new Error("TLS handshake timeout")
  return

TLSSocket::_tlsError = (err) ->
  @emit "_tlsError", err
  @emit "error", err  if @_controlReleased
  return

TLSSocket::_releaseControl = ->
  return false  if @_controlReleased
  @_controlReleased = true
  @removeListener "error", @_tlsError
  true

TLSSocket::_finishInit = ->
  if @_newSessionPending
    @_securePending = true
    return
  @npnProtocol = @ssl.getNegotiatedProtocol()  if process.features.tls_npn
  @servername = @ssl.getServername()  if process.features.tls_sni and @_tlsOptions.isServer
  debug "secure established"
  @_secureEstablished = true
  @setTimeout 0, @_handleTimeout  if @_tlsOptions.handshakeTimeout > 0
  @emit "secure"
  return

TLSSocket::_start = ->
  @ssl.requestOCSP()  if @_tlsOptions.requestOCSP
  @ssl.start()
  return

TLSSocket::setServername = (name) ->
  @ssl.setServername name
  return

TLSSocket::setSession = (session) ->
  session = new Buffer(session, "binary")  if util.isString(session)
  @ssl.setSession session
  return

TLSSocket::getPeerCertificate = (detailed) ->
  return common.translatePeerCertificate(@ssl.getPeerCertificate(detailed))  if @ssl
  null

TLSSocket::getSession = ->
  return @ssl.getSession()  if @ssl
  null

TLSSocket::isSessionReused = ->
  return @ssl.isSessionReused()  if @ssl
  null

TLSSocket::getCipher = (err) ->
  if @ssl
    @ssl.getCurrentCipher()
  else
    null

util.inherits Server, net.Server
exports.Server = Server
exports.createServer = (options, listener) ->
  new Server(options, listener)

Server::_getServerData = ->
  ticketKeys: @_sharedCreds.context.getTicketKeys().toString("hex")

Server::_setServerData = (data) ->
  @_sharedCreds.context.setTicketKeys new Buffer(data.ticketKeys, "hex")
  return

Server::setOptions = (options) ->
  if util.isBoolean(options.requestCert)
    @requestCert = options.requestCert
  else
    @requestCert = false
  if util.isBoolean(options.rejectUnauthorized)
    @rejectUnauthorized = options.rejectUnauthorized
  else
    @rejectUnauthorized = false
  @pfx = options.pfx  if options.pfx
  @key = options.key  if options.key
  @passphrase = options.passphrase  if options.passphrase
  @cert = options.cert  if options.cert
  @ca = options.ca  if options.ca
  @secureProtocol = options.secureProtocol  if options.secureProtocol
  @crl = options.crl  if options.crl
  @ciphers = options.ciphers  if options.ciphers
  @ecdhCurve = options.ecdhCurve  unless util.isUndefined(options.ecdhCurve)
  @dhparam = options.dhparam  if options.dhparam
  @sessionTimeout = options.sessionTimeout  if options.sessionTimeout
  @ticketKeys = options.ticketKeys  if options.ticketKeys
  secureOptions = options.secureOptions or 0
  if options.honorCipherOrder
    @honorCipherOrder = true
  else
    @honorCipherOrder = false
  @secureOptions = secureOptions  if secureOptions
  tls.convertNPNProtocols options.NPNProtocols, this  if options.NPNProtocols
  if options.sessionIdContext
    @sessionIdContext = options.sessionIdContext
  else
    @sessionIdContext = crypto.createHash("md5").update(process.argv.join(" ")).digest("hex")
  return

Server::addContext = (servername, context) ->
  throw new Error("Servername is required parameter for Server.addContext")  unless servername
  re = new RegExp("^" + servername.replace(/([\.^$+?\-\\[\]{}])/g, "\\$1").replace(/\*/g, "[^.]*") + "$")
  @_contexts.push [
    re
    tls.createSecureContext(context).context
  ]
  return

exports.connect = -> # [port, host], options, cb
  
  # Wrapping TLS socket inside another TLS socket was requested -
  # create legacy secure pair
  
  # Not even started connecting yet (or probably resolving dns address),
  # catch socket errors and assign handle.
  onHandle = ->
    
    # Verify that server's identity matches it's certificate's names
    
    # Uncork incoming data
    onHangUp = ->
      
      # NOTE: This logic is shared with _http_client.js
      unless socket._hadError
        socket._hadError = true
        error = new Error("socket hang up")
        error.code = "ECONNRESET"
        socket.destroy()
        socket.emit "error", error
      return
    socket._releaseControl()  unless legacy
    socket.setSession options.session  if options.session
    unless legacy
      socket.setServername options.servername  if options.servername
      socket._start()
    socket.on "secure", ->
      verifyError = socket.ssl.verifyError()
      unless verifyError
        cert = result.getPeerCertificate()
        verifyError = options.checkServerIdentity(hostname, cert)
      if verifyError
        result.authorized = false
        result.authorizationError = verifyError.code or verifyError.message
        if options.rejectUnauthorized
          result.emit "error", verifyError
          result.destroy()
          return
        else
          result.emit "secureConnect"
      else
        result.authorized = true
        result.emit "secureConnect"
      result.removeListener "end", onHangUp
      return

    result.once "end", onHangUp
    return
  args = normalizeConnectArgs(arguments)
  options = args[0]
  cb = args[1]
  defaults =
    rejectUnauthorized: "0" isnt process.env.NODE_TLS_REJECT_UNAUTHORIZED
    ciphers: tls.DEFAULT_CIPHERS
    checkServerIdentity: tls.checkServerIdentity

  options = util._extend(defaults, options or {})
  assert typeof options.checkServerIdentity is "function"
  hostname = options.servername or options.host or options.socket and options.socket._host
  NPN = {}
  context = tls.createSecureContext(options)
  tls.convertNPNProtocols options.NPNProtocols, NPN
  socket = undefined
  legacy = undefined
  result = undefined
  if options.socket instanceof TLSSocket
    debug "legacy connect"
    legacy = true
    socket = legacyConnect(hostname, options, NPN, context)
    result = socket.cleartext
  else
    legacy = false
    socket = new TLSSocket(options.socket,
      secureContext: context
      isServer: false
      requestCert: true
      rejectUnauthorized: options.rejectUnauthorized
      session: options.session
      NPNProtocols: NPN.NPNProtocols
      requestOCSP: options.requestOCSP
    )
    result = socket
  if socket._handle and not socket._connecting
    onHandle()
  else
    if not legacy and options.socket
      options.socket.once "connect", ->
        assert options.socket._handle
        socket._handle = options.socket._handle
        socket._handle.owner = socket
        socket.emit "connect"
        return

    socket.once "connect", onHandle
  result.once "secureConnect", cb  if cb
  unless options.socket
    assert not legacy
    connect_opt = undefined
    if options.path and not options.port
      connect_opt = path: options.path
    else
      connect_opt =
        port: options.port
        host: options.host
        localAddress: options.localAddress
    socket.connect connect_opt
  return result
  return
