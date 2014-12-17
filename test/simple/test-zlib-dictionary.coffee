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

# test compression/decompression with dictionary

#
# We'll use clean-new inflate stream each time
# and .reset() old dirty deflate one
#
run = (num) ->
  inflate = zlib.createInflate(dictionary: spdyDict)
  if num is 2
    deflate.reset()
    deflate.removeAllListeners "data"
  
  # Put data into deflate stream
  deflate.on "data", (chunk) ->
    inflate.write chunk
    return

  
  # Get data from inflate stream
  output = []
  inflate.on "data", (chunk) ->
    output.push chunk
    return

  inflate.on "end", ->
    called++
    assert.equal output.join(""), input
    run num + 1  if num < 2
    return

  deflate.write input
  deflate.flush ->
    inflate.end()
    return

  return
common = require("../common.js")
assert = require("assert")
zlib = require("zlib")
path = require("path")
spdyDict = new Buffer([
  "optionsgetheadpostputdeletetraceacceptaccept-charsetaccept-encodingaccept-"
  "languageauthorizationexpectfromhostif-modified-sinceif-matchif-none-matchi"
  "f-rangeif-unmodifiedsincemax-forwardsproxy-authorizationrangerefererteuser"
  "-agent10010120020120220320420520630030130230330430530630740040140240340440"
  "5406407408409410411412413414415416417500501502503504505accept-rangesageeta"
  "glocationproxy-authenticatepublicretry-afterservervarywarningwww-authentic"
  "ateallowcontent-basecontent-encodingcache-controlconnectiondatetrailertran"
  "sfer-encodingupgradeviawarningcontent-languagecontent-lengthcontent-locati"
  "oncontent-md5content-rangecontent-typeetagexpireslast-modifiedset-cookieMo"
  "ndayTuesdayWednesdayThursdayFridaySaturdaySundayJanFebMarAprMayJunJulAugSe"
  "pOctNovDecchunkedtext/htmlimage/pngimage/jpgimage/gifapplication/xmlapplic"
  "ation/xhtmltext/plainpublicmax-agecharset=iso-8859-1utf-8gzipdeflateHTTP/1"
  ".1statusversionurl\u0000"
].join(""))
deflate = zlib.createDeflate(dictionary: spdyDict)
input = [
  "HTTP/1.1 200 Ok"
  "Server: node.js"
  "Content-Length: 0"
  ""
].join("\r\n")
called = 0
run 1
process.on "exit", ->
  assert.equal called, 2
  return

