hasControlCodes = (str) ->
  str.length isnt ansiTrim(str).length
ansiTrim = (str) ->
  r = new RegExp("\u001b(?:\\[(?:\\d+[ABCDEFGJKSTm]|\\d+;\\d+[Hfm]|" + "\\d+;\\d+;\\d+m|6n|s|u|\\?25[lh])|\\w)", "g")
  str.replace r, ""
common = require("../common-tap.js")
test = require("tap").test
mkdirp = require("mkdirp")
rimraf = require("rimraf")
mr = require("npm-registry-mock")
path = require("path")
pkg = path.resolve(__dirname, "outdated")
cache = path.resolve(pkg, "cache")
mkdirp.sync cache
EXEC_OPTS = cwd: pkg

# note hard to automate tests for color = true
# as npm kills the color config when it detects
# it"s not running in a tty
test "does not use ansi styling", (t) ->
  t.plan 4
  mr common.port, (s) -> # create mock registry.
    common.npm [
      "outdated"
      "--registry"
      common.registry
      "underscore"
    ], EXEC_OPTS, (err, code, stdout) ->
      t.ifError err
      t.notOk code, "npm outdated exited with code 0"
      t.ok stdout, stdout.length
      t.ok not hasControlCodes(stdout)
      s.close()
      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync cache
  t.end()
  return

