
# windows fix for locked files
setup = ->
  mkdirp.sync pkg
  mkdirp.sync cache
  fs.writeFileSync path.resolve(pkg, "package.json"), JSON.stringify(
    author: "Evan Lucas"
    name: "version-no-tags-test"
    version: "0.0.0"
    description: "Test for git-tag-version flag"
  ), "utf8"
  process.chdir pkg
  return
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
osenv = require("osenv")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
which = require("which")
spawn = require("child_process").spawn
pkg = path.resolve(__dirname, "version-no-tags")
cache = path.resolve(pkg, "cache")
test "npm version <semver> without git tag", (t) ->
  setup()
  npm.load
    cache: cache
    registry: common.registry
  , ->
    which "git", (err, git) ->
      tagExists = (tag, _cb) ->
        child1 = spawn(git, [
          "tag"
          "-l"
          tag
        ])
        out = ""
        child1.stdout.on "data", (d) ->
          out += d.toString()
          return

        child1.on "exit", ->
          _cb null, Boolean(~out.indexOf(tag))

        return
      t.ifError err, "git found on system"
      child2 = spawn(git, ["init"])
      child2.stdout.pipe process.stdout
      child2.on "exit", ->
        npm.config.set "git-tag-version", false
        npm.commands.version ["patch"], (err) ->
          return t.fail("Error perform version patch")  if err
          p = path.resolve(pkg, "package")
          testPkg = require(p)
          t.fail testPkg.version + " !== \"0.0.1\""  if testPkg.version isnt "0.0.1"
          t.equal "0.0.1", testPkg.version
          tagExists "v0.0.1", (err, exists) ->
            t.ifError err, "tag found to exist"
            t.equal exists, false, "git tag DOES exist"
            t.pass "git tag does not exist"
            t.end()
            return

          return

        return

      return

    return

  return

test "cleanup", (t) ->
  process.chdir osenv.tmpdir()
  rimraf.sync pkg
  t.end()
  return

