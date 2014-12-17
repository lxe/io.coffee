# shutdown mock registry.
setup = (cb) ->
  process.chdir path.join(__dirname, "dedupe")
  mr common.port, (s) -> # create mock registry.
    rimraf.sync path.join(__dirname, "dedupe", "node_modules")
    fs.mkdirSync path.join(__dirname, "dedupe", "node_modules")
    cb s
    return

  return
test = require("tap").test
fs = require("fs")
path = require("path")
existsSync = fs.existsSync or path.existsSync
rimraf = require("rimraf")
mr = require("npm-registry-mock")
common = require("../common-tap.js")
EXEC_OPTS = {}
test "dedupe finds the common module and moves it up one level", (t) ->
  setup (s) ->
    common.npm [
      "install"
      "."
      "--registry"
      common.registry
    ], EXEC_OPTS, (err, code) ->
      t.ifError err, "successfully installed directory"
      t.equal code, 0, "npm install exited with code"
      common.npm ["dedupe"], {}, (err, code) ->
        t.ifError err, "successfully deduped against previous install"
        t.notOk code, "npm dedupe exited with code"
        t.ok existsSync(path.join(__dirname, "dedupe", "node_modules", "minimist"))
        t.ok not existsSync(path.join(__dirname, "dedupe", "node_modules", "checker"))
        s.close()
        t.end()
        return

      return

    return

  return

