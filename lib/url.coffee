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
Url = ->
  @protocol = null
  @slashes = null
  @auth = null
  @host = null
  @port = null
  @hostname = null
  @hash = null
  @search = null
  @query = null
  @pathname = null
  @path = null
  @href = null
  return

# Reference: RFC 3986, RFC 1808, RFC 2396

# define these here so at least they only have to be
# compiled once on the first module load.

# Special case for a simple path URL

# RFC 2396: characters reserved for delimiting URLs.
# We actually just auto-escape these.

# RFC 2396: characters not allowed for various reasons.

# Allowed by RFCs, but cause of XSS attacks.  Always escape these.

# Characters that are never ever allowed in a hostname.
# Note that any invalid chars are also handled, but these
# are the ones that are *expected* to be seen, so we fast-path
# them.

# protocols that can allow "unsafe" and "unwise" chars.

# protocols that never have a hostname.

# protocols that always contain a // bit.
urlParse = (url, parseQueryString, slashesDenoteHost) ->
  return url  if url and util.isObject(url) and url instanceof Url
  u = new Url
  u.parse url, parseQueryString, slashesDenoteHost
  u

# Copy chrome, IE, opera backslash-handling behavior.
# Back slashes before the query string get converted to forward slashes
# See: https://code.google.com/p/chromium/issues/detail?id=25916

# trim before proceeding.
# This is to support parse stuff like "  http://foo.com  \n"

# Try fast path regexp

# figure out if it's got a host
# user@server is *always* interpreted as a hostname, and url
# resolution will treat //foo/bar as host=foo,path=bar because that's
# how the browser resolves relative URLs.

# there's a hostname.
# the first instance of /, ?, ;, or # ends the host.
#
# If there is an @ in the hostname, then non-host chars *are* allowed
# to the left of the last @ sign, unless some host-ending character
# comes *before* the @-sign.
# URLs are obnoxious.
#
# ex:
# http://a@b@c/ => user:a@b host:c
# http://a@b?@c => user:a host:c path:/?@c

# v0.12 TODO(isaacs): This is not quite how Chrome does things.
# Review our test case against browsers more comprehensively.

# find the first instance of any hostEndingChars

# at this point, either we have an explicit point where the
# auth portion cannot go past, or the last @ char is the decider.

# atSign can be anywhere.

# atSign must be in auth portion.
# http://a@b/c@d => host:b auth:a path:/c@d

# Now we have a portion which is definitely the auth.
# Pull that off.

# the host is the remaining to the left of the first non-host char

# if we still have not hit it, then the entire thing is a host.

# pull out port.

# we've indicated that there is a hostname,
# so even if it's empty, it has to be present.

# if hostname begins with [ and ends with ]
# assume that it's an IPv6 address.

# validate a little.

# we replace non-ASCII char with a temporary placeholder
# we need this to make sure size of hostname is not
# broken by replacing non-ASCII by nothing

# we test again with ASCII char only

# hostnames are always lower case.

# IDNA Support: Returns a punycoded representation of "domain".
# It only converts parts of the domain name that
# have non-ASCII characters, i.e. it doesn't matter if
# you call it with a domain that already is ASCII-only.

# strip [ and ] from the hostname
# the host field still retains them, though

# now rest is set to the post-host stuff.
# chop off any delim chars.

# First, make 100% sure that any "autoEscape" chars get
# escaped, even if encodeURIComponent doesn't think they
# need to be.

# chop off from the tail first.

# got a fragment string.

# no query string, but parseQueryString still requested

#to support http.request

# finally, reconstruct the href based on what has been validated.

# format a parsed object into a url string
urlFormat = (obj) ->
  
  # ensure it's an object, and not a string url.
  # If it's an obj, this is a no-op.
  # this way, you can call url_format() on strings
  # to clean up potentially wonky urls.
  obj = urlParse(obj)  if util.isString(obj)
  return Url::format.call(obj)  unless obj instanceof Url
  obj.format()

# only the slashedProtocols get the //.  Not mailto:, xmpp:, etc.
# unless they had them to begin with.
urlResolve = (source, relative) ->
  urlParse(source, false, true).resolve relative
urlResolveObject = (source, relative) ->
  return relative  unless source
  urlParse(source, false, true).resolveObject relative
"use strict"
punycode = require("punycode")
util = require("util")
exports.parse = urlParse
exports.resolve = urlResolve
exports.resolveObject = urlResolveObject
exports.format = urlFormat
exports.Url = Url
protocolPattern = /^([a-z0-9.+-]+:)/i
portPattern = /:[0-9]*$/
simplePathPattern = /^(\/\/?(?!\/)[^\?\s]*)(\?[^\s]*)?$/
delims = [
  "<"
  ">"
  "\""
  "`"
  " "
  "\r"
  "\n"
  "\t"
]
unwise = [
  "{"
  "}"
  "|"
  "\\"
  "^"
  "`"
].concat(delims)
autoEscape = ["'"].concat(unwise)
nonHostChars = [
  "%"
  "/"
  "?"
  ";"
  "#"
].concat(autoEscape)
hostEndingChars = [
  "/"
  "?"
  "#"
]
hostnameMaxLen = 255
hostnamePatternString = "[^" + nonHostChars.join("") + "]{0,63}"
hostnamePartPattern = new RegExp("^" + hostnamePatternString + "$")
hostnamePartStart = new RegExp("^(" + hostnamePatternString + ")(.*)$")
unsafeProtocol =
  javascript: true
  "javascript:": true

hostlessProtocol =
  javascript: true
  "javascript:": true

slashedProtocol =
  http: true
  https: true
  ftp: true
  gopher: true
  file: true
  "http:": true
  "https:": true
  "ftp:": true
  "gopher:": true
  "file:": true

querystring = require("querystring")
Url::parse = (url, parseQueryString, slashesDenoteHost) ->
  throw new TypeError("Parameter 'url' must be a string, not " + typeof url)  unless util.isString(url)
  queryIndex = url.indexOf("?")
  splitter = (if (queryIndex isnt -1 and queryIndex < url.indexOf("#")) then "?" else "#")
  uSplit = url.split(splitter)
  slashRegex = /\\/g
  uSplit[0] = uSplit[0].replace(slashRegex, "/")
  url = uSplit.join(splitter)
  rest = url
  rest = rest.trim()
  if not slashesDenoteHost and url.split("#").length is 1
    simplePath = simplePathPattern.exec(rest)
    if simplePath
      @path = rest
      @href = rest
      @pathname = simplePath[1]
      if simplePath[2]
        @search = simplePath[2]
        if parseQueryString
          @query = querystring.parse(@search.substr(1))
        else
          @query = @search.substr(1)
      else if parseQueryString
        @search = ""
        @query = {}
      return this
  proto = protocolPattern.exec(rest)
  if proto
    proto = proto[0]
    lowerProto = proto.toLowerCase()
    @protocol = lowerProto
    rest = rest.substr(proto.length)
  if slashesDenoteHost or proto or rest.match(/^\/\/[^@\/]+@[^@\/]+/)
    slashes = rest.substr(0, 2) is "//"
    if slashes and not (proto and hostlessProtocol[proto])
      rest = rest.substr(2)
      @slashes = true
  if not hostlessProtocol[proto] and (slashes or (proto and not slashedProtocol[proto]))
    hostEnd = -1
    i = 0

    while i < hostEndingChars.length
      hec = rest.indexOf(hostEndingChars[i])
      hostEnd = hec  if hec isnt -1 and (hostEnd is -1 or hec < hostEnd)
      i++
    auth = undefined
    atSign = undefined
    if hostEnd is -1
      atSign = rest.lastIndexOf("@")
    else
      atSign = rest.lastIndexOf("@", hostEnd)
    if atSign isnt -1
      auth = rest.slice(0, atSign)
      rest = rest.slice(atSign + 1)
      @auth = decodeURIComponent(auth)
    hostEnd = -1
    i = 0

    while i < nonHostChars.length
      hec = rest.indexOf(nonHostChars[i])
      hostEnd = hec  if hec isnt -1 and (hostEnd is -1 or hec < hostEnd)
      i++
    hostEnd = rest.length  if hostEnd is -1
    @host = rest.slice(0, hostEnd)
    rest = rest.slice(hostEnd)
    @parseHost()
    @hostname = @hostname or ""
    ipv6Hostname = @hostname[0] is "[" and @hostname[@hostname.length - 1] is "]"
    unless ipv6Hostname
      hostparts = @hostname.split(/\./)
      i = 0
      l = hostparts.length

      while i < l
        part = hostparts[i]
        continue  unless part
        unless part.match(hostnamePartPattern)
          newpart = ""
          j = 0
          k = part.length

          while j < k
            if part.charCodeAt(j) > 127
              newpart += "x"
            else
              newpart += part[j]
            j++
          unless newpart.match(hostnamePartPattern)
            validParts = hostparts.slice(0, i)
            notHost = hostparts.slice(i + 1)
            bit = part.match(hostnamePartStart)
            if bit
              validParts.push bit[1]
              notHost.unshift bit[2]
            rest = "/" + notHost.join(".") + rest  if notHost.length
            @hostname = validParts.join(".")
            break
        i++
    if @hostname.length > hostnameMaxLen
      @hostname = ""
    else
      @hostname = @hostname.toLowerCase()
    @hostname = punycode.toASCII(@hostname)  unless ipv6Hostname
    p = (if @port then ":" + @port else "")
    h = @hostname or ""
    @host = h + p
    @href += @host
    if ipv6Hostname
      @hostname = @hostname.substr(1, @hostname.length - 2)
      rest = "/" + rest  if rest[0] isnt "/"
  unless unsafeProtocol[lowerProto]
    i = 0
    l = autoEscape.length

    while i < l
      ae = autoEscape[i]
      esc = encodeURIComponent(ae)
      esc = escape(ae)  if esc is ae
      rest = rest.split(ae).join(esc)
      i++
  hash = rest.indexOf("#")
  if hash isnt -1
    @hash = rest.substr(hash)
    rest = rest.slice(0, hash)
  qm = rest.indexOf("?")
  if qm isnt -1
    @search = rest.substr(qm)
    @query = rest.substr(qm + 1)
    @query = querystring.parse(@query)  if parseQueryString
    rest = rest.slice(0, qm)
  else if parseQueryString
    @search = ""
    @query = {}
  @pathname = rest  if rest
  @pathname = "/"  if slashedProtocol[lowerProto] and @hostname and not @pathname
  if @pathname or @search
    p = @pathname or ""
    s = @search or ""
    @path = p + s
  @href = @format(parseQueryString)
  this

Url::format = (parseQueryString) ->
  auth = @auth or ""
  if auth
    auth = encodeURIComponent(auth)
    auth = auth.replace(/%3A/i, ":")
    auth += "@"
  protocol = @protocol or ""
  pathname = @pathname or ""
  hash = @hash or ""
  host = false
  query = ""
  search = ""
  if @path
    qm = @path.indexOf("?")
    if qm isnt -1
      query = @path.slice(qm + 1)
      search = "?" + query
      pathname = @path.slice(0, qm)
    else
      if parseQueryString
        @query = {}
        @search = ""
      else
        @query = null
        @search = null
      pathname = @path
  if @host
    host = auth + @host
  else if @hostname
    host = auth + ((if @hostname.indexOf(":") is -1 then @hostname else "[" + @hostname + "]"))
    host += ":" + @port  if @port
  query = querystring.stringify(@query)  if not query and @query and util.isObject(@query) and Object.keys(@query).length
  search = @search or (query and ("?" + query)) or ""  unless search
  protocol += ":"  if protocol and protocol.substr(-1) isnt ":"
  if @slashes or (not protocol or slashedProtocol[protocol]) and host isnt false
    host = "//" + (host or "")
    pathname = "/" + pathname  if pathname and pathname.charAt(0) isnt "/"
  else host = ""  unless host
  hash = "#" + hash  if hash and hash.charAt(0) isnt "#"
  search = "?" + search  if search and search.charAt(0) isnt "?"
  pathname = pathname.replace(/[?#]/g, (match) ->
    encodeURIComponent match
  )
  search = search.replace("#", "%23")
  protocol + host + pathname + search + hash

Url::resolve = (relative) ->
  @resolveObject(urlParse(relative, false, true)).format()

Url::resolveObject = (relative) ->
  if util.isString(relative)
    rel = new Url()
    rel.parse relative, false, true
    relative = rel
  result = new Url()
  tkeys = Object.keys(this)
  tk = 0

  while tk < tkeys.length
    tkey = tkeys[tk]
    result[tkey] = this[tkey]
    tk++
  
  # hash is always overridden, no matter what.
  # even href="" will remove it.
  result.hash = relative.hash
  
  # if the relative url is empty, then there's nothing left to do here.
  if relative.href is ""
    result.href = result.format()
    return result
  
  # hrefs like //foo/bar always cut to the protocol.
  if relative.slashes and not relative.protocol
    
    # take everything except the protocol from relative
    rkeys = Object.keys(relative)
    rk = 0

    while rk < rkeys.length
      rkey = rkeys[rk]
      result[rkey] = relative[rkey]  if rkey isnt "protocol"
      rk++
    
    #urlParse appends trailing / to urls like http://www.example.com
    result.path = result.pathname = "/"  if slashedProtocol[result.protocol] and result.hostname and not result.pathname
    result.href = result.format()
    return result
  if relative.protocol and relative.protocol isnt result.protocol
    
    # if it's a known url protocol, then changing
    # the protocol does weird things
    # first, if it's not file:, then we MUST have a host,
    # and if there was a path
    # to begin with, then we MUST have a path.
    # if it is file:, then the host is dropped,
    # because that's known to be hostless.
    # anything else is assumed to be absolute.
    unless slashedProtocol[relative.protocol]
      keys = Object.keys(relative)
      v = 0

      while v < keys.length
        k = keys[v]
        result[k] = relative[k]
        v++
      result.href = result.format()
      return result
    result.protocol = relative.protocol
    if not relative.host and not hostlessProtocol[relative.protocol]
      relPath = (relative.pathname or "").split("/")
        while relPath.length and not (relative.host = relPath.shift())
      relative.host = ""  unless relative.host
      relative.hostname = ""  unless relative.hostname
      relPath.unshift ""  if relPath[0] isnt ""
      relPath.unshift ""  if relPath.length < 2
      result.pathname = relPath.join("/")
    else
      result.pathname = relative.pathname
    result.search = relative.search
    result.query = relative.query
    result.host = relative.host or ""
    result.auth = relative.auth
    result.hostname = relative.hostname or relative.host
    result.port = relative.port
    
    # to support http.request
    if result.pathname or result.search
      p = result.pathname or ""
      s = result.search or ""
      result.path = p + s
    result.slashes = result.slashes or relative.slashes
    result.href = result.format()
    return result
  isSourceAbs = (result.pathname and result.pathname.charAt(0) is "/")
  isRelAbs = (relative.host or relative.pathname and relative.pathname.charAt(0) is "/")
  mustEndAbs = (isRelAbs or isSourceAbs or (result.host and relative.pathname))
  removeAllDots = mustEndAbs
  srcPath = result.pathname and result.pathname.split("/") or []
  relPath = relative.pathname and relative.pathname.split("/") or []
  psychotic = result.protocol and not slashedProtocol[result.protocol]
  
  # if the url is a non-slashed url, then relative
  # links like ../.. should be able
  # to crawl up to the hostname, as well.  This is strange.
  # result.protocol has already been set by now.
  # Later on, put the first path part into the host field.
  if psychotic
    result.hostname = ""
    result.port = null
    if result.host
      if srcPath[0] is ""
        srcPath[0] = result.host
      else
        srcPath.unshift result.host
    result.host = ""
    if relative.protocol
      relative.hostname = null
      relative.port = null
      if relative.host
        if relPath[0] is ""
          relPath[0] = relative.host
        else
          relPath.unshift relative.host
      relative.host = null
    mustEndAbs = mustEndAbs and (relPath[0] is "" or srcPath[0] is "")
  if isRelAbs
    
    # it's absolute.
    result.host = (if (relative.host or relative.host is "") then relative.host else result.host)
    result.hostname = (if (relative.hostname or relative.hostname is "") then relative.hostname else result.hostname)
    result.search = relative.search
    result.query = relative.query
    srcPath = relPath
  
  # fall through to the dot-handling below.
  else if relPath.length
    
    # it's relative
    # throw away the existing file, and take the new path instead.
    srcPath = []  unless srcPath
    srcPath.pop()
    srcPath = srcPath.concat(relPath)
    result.search = relative.search
    result.query = relative.query
  else unless util.isNullOrUndefined(relative.search)
    
    # just pull out the search.
    # like href='?foo'.
    # Put this after the other two cases because it simplifies the booleans
    if psychotic
      result.hostname = result.host = srcPath.shift()
      
      #occationaly the auth can get stuck only in host
      #this especialy happens in cases like
      #url.resolveObject('mailto:local1@domain1', 'local2@domain2')
      authInHost = (if result.host and result.host.indexOf("@") > 0 then result.host.split("@") else false)
      if authInHost
        result.auth = authInHost.shift()
        result.host = result.hostname = authInHost.shift()
    result.search = relative.search
    result.query = relative.query
    
    #to support http.request
    result.path = ((if result.pathname then result.pathname else "")) + ((if result.search then result.search else ""))  if not util.isNull(result.pathname) or not util.isNull(result.search)
    result.href = result.format()
    return result
  unless srcPath.length
    
    # no path at all.  easy.
    # we've already handled the other stuff above.
    result.pathname = null
    
    #to support http.request
    if result.search
      result.path = "/" + result.search
    else
      result.path = null
    result.href = result.format()
    return result
  
  # if a url ENDs in . or .., then it must get a trailing slash.
  # however, if it ends in anything else non-slashy,
  # then it must NOT get a trailing slash.
  last = srcPath.slice(-1)[0]
  hasTrailingSlash = ((result.host or relative.host) and (last is "." or last is "..") or last is "")
  
  # strip single dots, resolve double dots to parent dir
  # if the path tries to go above the root, `up` ends up > 0
  up = 0
  i = srcPath.length

  while i >= 0
    last = srcPath[i]
    if last is "."
      srcPath.splice i, 1
    else if last is ".."
      srcPath.splice i, 1
      up++
    else if up
      srcPath.splice i, 1
      up--
    i--
  
  # if the path is allowed to go above the root, restore leading ..s
  if not mustEndAbs and not removeAllDots
    while up--
      srcPath.unshift ".."
      up
  srcPath.unshift ""  if mustEndAbs and srcPath[0] isnt "" and (not srcPath[0] or srcPath[0].charAt(0) isnt "/")
  srcPath.push ""  if hasTrailingSlash and (srcPath.join("/").substr(-1) isnt "/")
  isAbsolute = srcPath[0] is "" or (srcPath[0] and srcPath[0].charAt(0) is "/")
  
  # put the host back
  if psychotic
    result.hostname = result.host = (if isAbsolute then "" else (if srcPath.length then srcPath.shift() else ""))
    
    #occationaly the auth can get stuck only in host
    #this especialy happens in cases like
    #url.resolveObject('mailto:local1@domain1', 'local2@domain2')
    authInHost = (if result.host and result.host.indexOf("@") > 0 then result.host.split("@") else false)
    if authInHost
      result.auth = authInHost.shift()
      result.host = result.hostname = authInHost.shift()
  mustEndAbs = mustEndAbs or (result.host and srcPath.length)
  srcPath.unshift ""  if mustEndAbs and not isAbsolute
  unless srcPath.length
    result.pathname = null
    result.path = null
  else
    result.pathname = srcPath.join("/")
  
  #to support request.http
  result.path = ((if result.pathname then result.pathname else "")) + ((if result.search then result.search else ""))  if not util.isNull(result.pathname) or not util.isNull(result.search)
  result.auth = relative.auth or result.auth
  result.slashes = result.slashes or relative.slashes
  result.href = result.format()
  result

Url::parseHost = ->
  host = @host
  port = portPattern.exec(host)
  if port
    port = port[0]
    @port = port.substr(1)  if port isnt ":"
    host = host.substr(0, host.length - port.length)
  @hostname = host  if host
  return
