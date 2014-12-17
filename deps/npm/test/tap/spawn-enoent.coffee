path = require("path")
test = require("tap").test
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
common = require("../common-tap.js")
pkg = path.resolve(__dirname, "spawn-enoent")
pj = JSON.stringify(
  name: "x"
  version: "1.2.3"
  scripts:
    start: "wharble-garble-blorst"
, null, 2) + "\n"
test "setup", (t) ->
  rimraf.sync pkg
  mkdirp.sync pkg
  fs.writeFileSync pkg + "/package.json", pj
  t.end()
  return

test "enoent script", (t) ->
  common.npm ["start"],
    cwd: pkg
    env:
      PATH: process.env.PATH
      Path: process.env.Path
      npm_config_loglevel: "warn"
  , (er, code, sout, serr) ->
    t.similar serr, /npm ERR! Failed at the x@1\.2\.3 start script\./
    t.end()
    return

  return

test "clean", (t) ->
  rimraf.sync pkg
  t.end()
  return

