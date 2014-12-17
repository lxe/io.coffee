common = require("../common-tap.js")
test = require("tap").test
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.join(__dirname, "install-at-locally")
EXEC_OPTS = {}
test "setup", (t) ->
  mkdirp.sync pkg
  mkdirp.sync path.resolve(pkg, "node_modules")
  process.chdir pkg
  t.end()
  return

test "\"npm install ./package@1.2.3\" should install local pkg", (t) ->
  common.npm [
    "install"
    "./package@1.2.3"
  ], EXEC_OPTS, (err, code) ->
    p = path.resolve(pkg, "node_modules/install-at-locally/package.json")
    t.ifError err, "install local package successful"
    t.equal code, 0, "npm install exited with code"
    t.ok JSON.parse(fs.readFileSync(p, "utf8"))
    t.end()
    return

  return

test "\"npm install install/at/locally@./package@1.2.3\" should install local pkg", (t) ->
  common.npm [
    "install"
    "./package@1.2.3"
  ], EXEC_OPTS, (err, code) ->
    p = path.resolve(pkg, "node_modules/install-at-locally/package.json")
    t.ifError err, "install local package in explicit directory successful"
    t.equal code, 0, "npm install exited with code"
    t.ok JSON.parse(fs.readFileSync(p, "utf8"))
    t.end()
    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync path.resolve(pkg, "node_modules")
  t.end()
  return

