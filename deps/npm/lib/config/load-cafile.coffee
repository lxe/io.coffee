loadCAFile = (cafilePath, cb) ->
  afterCARead = (er, cadata) ->
    return cb(er)  if er
    delim = "-----END CERTIFICATE-----"
    output = undefined
    output = cadata.split(delim).filter((xs) ->
      !!xs.trim()
    ).map((xs) ->
      xs.trimLeft() + delim
    )
    @set "ca", output
    cb null
    return
  return process.nextTick(cb)  unless cafilePath
  fs.readFile cafilePath, "utf8", afterCARead.bind(this)
  return
module.exports = loadCAFile
fs = require("fs")
