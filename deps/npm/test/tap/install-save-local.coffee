resetPackageJSON = (pkg) ->
  pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
  delete pkgJson.dependencies

  delete pkgJson.devDependencies

  json = JSON.stringify(pkgJson, null, 2) + "\n"
  fs.writeFileSync pkg + "/package.json", json, "ascii"
  return
common = require("../common-tap.js")
test = require("tap").test
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
pkg = path.join(__dirname, "install-save-local", "package")
EXEC_OPTS = {}
test "setup", (t) ->
  resetPackageJSON pkg
  process.chdir pkg
  t.end()
  return

test "\"npm install --save ../local/path\" should install local package and save to package.json", (t) ->
  resetPackageJSON pkg
  common.npm [
    "install"
    "--save"
    "../package-local-dependency"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm install exited with code 0"
    dependencyPackageJson = path.resolve(pkg, "node_modules/package-local-dependency/package.json")
    t.ok JSON.parse(fs.readFileSync(dependencyPackageJson, "utf8"))
    pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
    t.deepEqual pkgJson.dependencies,
      "package-local-dependency": "file:../package-local-dependency"

    t.end()
    return

  return

test "\"npm install --save-dev ../local/path\" should install local package and save to package.json", (t) ->
  resetPackageJSON pkg
  common.npm [
    "install"
    "--save-dev"
    "../package-local-dev-dependency"
  ], EXEC_OPTS, (err, code) ->
    t.ifError err
    t.notOk code, "npm install exited with code 0"
    dependencyPackageJson = path.resolve(pkg, "node_modules/package-local-dev-dependency/package.json")
    t.ok JSON.parse(fs.readFileSync(dependencyPackageJson, "utf8"))
    pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
    t.deepEqual pkgJson.devDependencies,
      "package-local-dev-dependency": "file:../package-local-dev-dependency"

    t.end()
    return

  return

test "cleanup", (t) ->
  resetPackageJSON pkg
  process.chdir __dirname
  rimraf.sync path.resolve(pkg, "node_modules")
  t.end()
  return

