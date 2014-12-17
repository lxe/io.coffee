
# initialize a package.json file
init = (args, cb) ->
  dir = process.cwd()
  log.pause()
  npm.spinner.stop()
  initFile = npm.config.get("init-module")
  unless initJson.yes(npm.config)
    console.log [
      "This utility will walk you through creating a package.json file."
      "It only covers the most common items, and tries to guess sane defaults."
      ""
      "See `npm help json` for definitive documentation on these fields"
      "and exactly what they do."
      ""
      "Use `npm install <pkg> --save` afterwards to install a package and"
      "save it as a dependency in the package.json file."
      ""
      "Press ^C at any time to quit."
    ].join("\n")
  initJson dir, initFile, npm.config, (er, data) ->
    log.resume()
    log.silly "package data", data
    log.info "init", "written successfully"
    if er and er.message is "canceled"
      log.warn "init", "canceled"
      return cb(null, data)
    cb er, data
    return

  return
module.exports = init
log = require("npmlog")
npm = require("./npm.js")
initJson = require("init-package-json")
init.usage = "npm init [--force/-f]"
