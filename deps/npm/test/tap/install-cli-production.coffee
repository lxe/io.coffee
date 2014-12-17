common = require("../common-tap.js")
test = require("tap").test
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.join(__dirname, "install-cli-production")
EXEC_OPTS = cwd: pkg
test "setup", (t) ->
  mkdirp.sync pkg
  mkdirp.sync path.resolve(pkg, "node_modules")
  process.chdir pkg
  t.end()
  return

test "\"npm install --production\" should install dependencies", (t) ->
  common.npm [
    "install"
    "--production"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err, "install production successful"
    t.equal code, 0, "npm install exited with code"
    p = path.resolve(pkg, "node_modules/dependency/package.json")
    t.ok JSON.parse(fs.readFileSync(p, "utf8"))
    t.end()
    return

  return

test "\"npm install --production\" should not install dev dependencies", (t) ->
  common.npm [
    "install"
    "--production"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err, "install production successful"
    t.equal code, 0, "npm install exited with code"
    p = path.resolve(pkg, "node_modules/dev-dependency/package.json")
    t.ok not fs.existsSync(p), ""
    t.end()
    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync path.resolve(pkg, "node_modules")
  t.end()
  return

