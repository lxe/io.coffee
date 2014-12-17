common = require("../common-tap")
test = require("tap").test
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
pkg = path.join(__dirname, "install-from-local", "package-with-local-paths")
EXEC_OPTS = {}
test "setup", (t) ->
  process.chdir pkg
  t.end()
  return

test "\"npm install\" should install local packages", (t) ->
  common.npm [
    "install"
    "."
  ], EXEC_OPTS, (err, code) ->
    t.ifError err, "error should not exist"
    t.notOk code, "npm install exited with code 0"
    dependencyPackageJson = path.resolve(pkg, "node_modules/package-local-dependency/package.json")
    t.ok JSON.parse(fs.readFileSync(dependencyPackageJson, "utf8")), "package with local dependency installed"
    devDependencyPackageJson = path.resolve(pkg, "node_modules/package-local-dev-dependency/package.json")
    t.ok JSON.parse(fs.readFileSync(devDependencyPackageJson, "utf8")), "package with local dev dependency installed"
    t.end()
    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync path.resolve(pkg, "node_modules")
  t.end()
  return

