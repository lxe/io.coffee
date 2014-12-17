contains = (list, element) ->
  i = 0

  while i < list.length
    return true  if list[i] is element
    ++i
  false
parseNpmInstallOutput = (stdout) ->
  stdout.trim().split /\n\n|\s+/
common = require("../common-tap")
existsSync = require("fs").existsSync
join = require("path").join
test = require("tap").test
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = join(__dirname, "install-from-local", "package-with-scoped-paths")
modules = join(pkg, "node_modules")
EXEC_OPTS = cwd: pkg
test "setup", (t) ->
  rimraf.sync modules
  rimraf.sync join(pkg, "cache")
  process.chdir pkg
  mkdirp.sync modules
  t.end()
  return

test "installing already installed local scoped package", (t) ->
  common.npm [
    "install"
    "--loglevel"
    "silent"
  ], EXEC_OPTS, (err, code, stdout) ->
    installed = parseNpmInstallOutput(stdout)
    t.ifError err, "error should not exist"
    t.notOk code, "npm install exited with code 0"
    t.ifError err, "install ran to completion without error"
    t.ok existsSync(join(modules, "@scoped", "package", "package.json")), "package installed"
    t.ok contains(installed, "node_modules/@scoped/package"), "installed @scoped/package"
    t.ok contains(installed, "node_modules/package-local-dependency"), "installed package-local-dependency"
    common.npm [
      "install"
      "--loglevel"
      "silent"
    ], EXEC_OPTS, (err, code, stdout) ->
      installed = parseNpmInstallOutput(stdout)
      t.ifError err, "error should not exist"
      t.notOk code, "npm install exited with code 0"
      t.ifError err, "install ran to completion without error"
      t.ok existsSync(join(modules, "@scoped", "package", "package.json")), "package installed"
      t.notOk contains(installed, "node_modules/@scoped/package"), "did not reinstall @scoped/package"
      t.notOk contains(installed, "node_modules/package-local-dependency"), "did not reinstall package-local-dependency"
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync join(modules)
  rimraf.sync join(pkg, "cache")
  t.end()
  return

