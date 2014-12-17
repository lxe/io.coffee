common = require("../common-tap.js")
test = require("tap").test
osenv = require("osenv")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
tmp = osenv.tmpdir()
t1dir = path.resolve(tmp, "view-local-no-pkg")
t2dir = path.resolve(tmp, "view-local-notmine")
t3dir = path.resolve(tmp, "view-local-mine")
mr = require("npm-registry-mock")
test "setup", (t) ->
  mkdirp.sync t1dir
  mkdirp.sync t2dir
  mkdirp.sync t3dir
  fs.writeFileSync t2dir + "/package.json", JSON.stringify(
    author: "Evan Lucas"
    name: "test-repo-url-https"
    version: "0.0.1"
  ), "utf8"
  fs.writeFileSync t3dir + "/package.json", JSON.stringify(
    author: "Evan Lucas"
    name: "biscuits"
    version: "0.0.1"
  ), "utf8"
  t.pass "created fixtures"
  t.end()
  return

test "npm view . in global mode", (t) ->
  process.chdir t1dir
  common.npm [
    "view"
    "."
    "--registry=" + common.registry
    "--global"
  ],
    cwd: t1dir
  , (err, code, stdout, stderr) ->
    t.ifError err, "view command finished successfully"
    t.equal code, 1, "exit not ok"
    t.similar stderr, /Cannot use view command in global mode./m
    t.end()
    return

  return

test "npm view --global", (t) ->
  process.chdir t1dir
  common.npm [
    "view"
    "--registry=" + common.registry
    "--global"
  ],
    cwd: t1dir
  , (err, code, stdout, stderr) ->
    t.ifError err, "view command finished successfully"
    t.equal code, 1, "exit not ok"
    t.similar stderr, /Cannot use view command in global mode./m
    t.end()
    return

  return

test "npm view . with no package.json", (t) ->
  process.chdir t1dir
  common.npm [
    "view"
    "."
    "--registry=" + common.registry
  ],
    cwd: t1dir
  , (err, code, stdout, stderr) ->
    t.ifError err, "view command finished successfully"
    t.equal code, 1, "exit not ok"
    t.similar stderr, /Invalid package.json/m
    t.end()
    return

  return

test "npm view . with no published package", (t) ->
  process.chdir t3dir
  mr common.port, (s) ->
    common.npm [
      "view"
      "."
      "--registry=" + common.registry
    ],
      cwd: t3dir
    , (err, code, stdout, stderr) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 1, "exit not ok"
      t.similar stderr, /version not found/m
      s.close()
      t.end()
      return

    return

  return

test "npm view .", (t) ->
  process.chdir t2dir
  mr common.port, (s) ->
    common.npm [
      "view"
      "."
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      re = new RegExp("name: 'test-repo-url-https'")
      t.similar stdout, re
      s.close()
      t.end()
      return

    return

  return

test "npm view . select fields", (t) ->
  process.chdir t2dir
  mr common.port, (s) ->
    common.npm [
      "view"
      "."
      "main"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      t.equal stdout.trim(), "index.js", "should print `index.js`"
      s.close()
      t.end()
      return

    return

  return

test "npm view .@<version>", (t) ->
  process.chdir t2dir
  mr common.port, (s) ->
    common.npm [
      "view"
      ".@0.0.0"
      "version"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      t.equal stdout.trim(), "0.0.0", "should print `0.0.0`"
      s.close()
      t.end()
      return

    return

  return

test "npm view .@<version> --json", (t) ->
  process.chdir t2dir
  mr common.port, (s) ->
    common.npm [
      "view"
      ".@0.0.0"
      "version"
      "--json"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      t.equal stdout.trim(), "\"0.0.0\"", "should print `\"0.0.0\"`"
      s.close()
      t.end()
      return

    return

  return

test "npm view <package name>", (t) ->
  mr common.port, (s) ->
    common.npm [
      "view"
      "underscore"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      re = new RegExp("name: 'underscore'")
      t.similar stdout, re, "should have name `underscore`"
      s.close()
      t.end()
      return

    return

  return

test "npm view <package name> --global", (t) ->
  mr common.port, (s) ->
    common.npm [
      "view"
      "underscore"
      "--global"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      re = new RegExp("name: 'underscore'")
      t.similar stdout, re, "should have name `underscore`"
      s.close()
      t.end()
      return

    return

  return

test "npm view <package name> --json", (t) ->
  t.plan 3
  mr common.port, (s) ->
    common.npm [
      "view"
      "underscore"
      "--json"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      s.close()
      try
        out = JSON.parse(stdout.trim())
        t.similar out,
          maintainers: "jashkenas <jashkenas@gmail.com>"
        , "should have the same maintainer"
      catch er
        t.fail "Unable to parse JSON"
      return

    return

  return

test "npm view <package name> <field>", (t) ->
  mr common.port, (s) ->
    common.npm [
      "view"
      "underscore"
      "homepage"
      "--registry=" + common.registry
    ],
      cwd: t2dir
    , (err, code, stdout) ->
      t.ifError err, "view command finished successfully"
      t.equal code, 0, "exit ok"
      t.equal stdout.trim(), "http://underscorejs.org", "homepage should equal `http://underscorejs.org`"
      s.close()
      t.end()
      return

    return

  return

test "cleanup", (t) ->
  process.chdir osenv.tmpdir()
  rimraf.sync t1dir
  rimraf.sync t2dir
  rimraf.sync t3dir
  t.pass "cleaned up"
  t.end()
  return

