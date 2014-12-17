test = require("tap").test
fs = require("fs")
path = require("path")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
spawn = require("child_process").spawn
npmCli = require.resolve("../../bin/npm-cli.js")
node = process.execPath
pkg = path.resolve(__dirname, "git-cache-no-hooks")
tmp = path.join(pkg, "tmp")
cache = path.join(pkg, "cache")
test "setup", (t) ->
  rimraf.sync pkg
  mkdirp.sync pkg
  mkdirp.sync cache
  mkdirp.sync tmp
  mkdirp.sync path.resolve(pkg, "node_modules")
  t.end()
  return

test "git-cache-no-hooks: install a git dependency", (t) ->
  
  # disable git integration tests on Travis.
  return t.end()  if process.env.TRAVIS
  command = [
    npmCli
    "install"
    "git://github.com/nigelzor/npm-4503-a.git"
  ]
  child = spawn(node, command,
    cwd: pkg
    env:
      npm_config_cache: cache
      npm_config_tmp: tmp
      npm_config_prefix: pkg
      npm_config_global: "false"
      npm_config_umask: "00"
      HOME: process.env.HOME
      Path: process.env.PATH
      PATH: process.env.PATH

    stdio: "inherit"
  )
  child.on "close", (code) ->
    t.equal code, 0, "npm install should succeed"
    
    # verify permissions on git hooks
    repoDir = "git-github-com-nigelzor-npm-4503-a-git-40c5cb24"
    hooksPath = path.join(cache, "_git-remotes", repoDir, "hooks")
    fs.readdir hooksPath, (err) ->
      t.equal err and err.code, "ENOENT", "hooks are not brought along with repo"
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  rimraf.sync pkg
  t.end()
  return

