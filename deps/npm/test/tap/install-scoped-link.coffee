common = require("../common-tap.js")
existsSync = require("fs").existsSync
join = require("path").join
exec = require("child_process").exec
test = require("tap").test
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = join(__dirname, "install-scoped")
work = join(__dirname, "install-scoped-TEST")
modules = join(work, "node_modules")
EXEC_OPTS = {}
test "setup", (t) ->
  mkdirp.sync modules
  process.chdir work
  t.end()
  return

test "installing package with links", (t) ->
  common.npm [
    "install"
    pkg
  ], EXEC_OPTS, (err, code) ->
    t.ifError err, "install ran to completion without error"
    t.notOk code, "npm install exited with code 0"
    t.ok existsSync(join(modules, "@scoped", "package", "package.json")), "package installed"
    t.ok existsSync(join(modules, ".bin")), "binary link directory exists"
    hello = join(modules, ".bin", "hello")
    t.ok existsSync(hello), "binary link exists"
    exec "node " + hello, (err, stdout, stderr) ->
      t.ifError err, "command ran fine"
      t.notOk stderr, "got no error output back"
      t.equal stdout, "hello blrbld\n", "output was as expected"
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync work
  t.end()
  return

