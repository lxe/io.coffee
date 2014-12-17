
# underscore is already in the package.json,
# but --save will trigger a rewrite with sort
setup = ->
  mkdirp.sync pkg
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(
    name: "sorted-package-json"
    version: "0.0.0"
    description: ""
    main: "index.js"
    scripts:
      test: "echo \"Error: no test specified\" && exit 1"

    author: "Rocko Artischocko"
    license: "ISC"
    dependencies:
      underscore: "^1.3.3"
      request: "^0.9.0"
  , null, 2), "utf8"
  return
cleanup = ->
  process.chdir osenv.tmpdir()
  rimraf.sync cache
  rimraf.sync pkg
  return
test = require("tap").test
path = require("path")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
spawn = require("child_process").spawn
npm = require.resolve("../../bin/npm-cli.js")
node = process.execPath
pkg = path.resolve(__dirname, "sorted-package-json")
tmp = path.join(pkg, "tmp")
cache = path.join(pkg, "cache")
fs = require("fs")
common = require("../common-tap.js")
mr = require("npm-registry-mock")
osenv = require("osenv")
test "sorting dependencies", (t) ->
  packageJson = path.resolve(pkg, "package.json")
  cleanup()
  mkdirp.sync cache
  mkdirp.sync tmp
  setup()
  before = JSON.parse(fs.readFileSync(packageJson).toString())
  mr common.port, (s) ->
    child = spawn(node, [
      npm
      "install"
      "--save"
      "underscore@1.3.3"
    ],
      cwd: pkg
      env:
        npm_config_registry: common.registry
        npm_config_cache: cache
        npm_config_tmp: tmp
        npm_config_prefix: pkg
        npm_config_global: "false"
        HOME: process.env.HOME
        Path: process.env.PATH
        PATH: process.env.PATH
    )
    child.on "close", (code) ->
      t.equal code, 0, "npm install exited with code"
      result = fs.readFileSync(packageJson).toString()
      resultAsJson = JSON.parse(result)
      s.close()
      t.same Object.keys(resultAsJson.dependencies), Object.keys(before.dependencies).sort()
      t.notSame Object.keys(resultAsJson.dependencies), Object.keys(before.dependencies)
      t.ok resultAsJson.dependencies.underscore
      t.ok resultAsJson.dependencies.request
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  cleanup()
  t.pass "cleaned up"
  t.end()
  return

