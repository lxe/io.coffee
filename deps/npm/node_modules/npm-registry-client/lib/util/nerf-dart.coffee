
###*
Maps a URL to an identifier.

Name courtesy schiffertronix media LLC, a New Jersey corporation

@param {String} uri The URL to be nerfed.

@returns {String} A nerfed URL.
###
toNerfDart = (uri) ->
  parsed = url.parse(uri)
  parsed.pathname = "/"
  delete parsed.protocol

  delete parsed.auth

  url.format parsed
url = require("url")
module.exports = toNerfDart
