resetPackageJSON = (pkg) ->
  pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
  delete pkgJson.dependencies

  delete pkgJson.devDependencies

  delete pkgJson.optionalDependencies

  json = JSON.stringify(pkgJson, null, 2) + "\n"
  fs.writeFileSync pkg + "/package.json", json, "ascii"
  return
common = require("../common-tap.js")
test = require("tap").test
npm = require("../../")
path = require("path")
fs = require("fs")
rimraf = require("rimraf")
mkdirp = require("mkdirp")
pkg = path.join(__dirname, "install-save-prefix")
mr = require("npm-registry-mock")
test "setup", (t) ->
  mkdirp.sync pkg
  mkdirp.sync path.resolve(pkg, "node_modules")
  process.chdir pkg
  t.end()
  return

test "npm install --save with default save-prefix should install local pkg versioned to allow minor updates", (t) ->
  resetPackageJSON pkg
  mr common.port, (s) ->
    npm.load
      cache: pkg + "/cache"
      loglevel: "silent"
      "save-prefix": "^"
      registry: common.registry
    , (err) ->
      t.ifError err
      npm.config.set "save", true
      npm.commands.install ["underscore@latest"], (err) ->
        t.ifError err
        p = path.resolve(pkg, "node_modules/underscore/package.json")
        t.ok JSON.parse(fs.readFileSync(p))
        pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
        t.deepEqual pkgJson.dependencies,
          underscore: "^1.5.1"
        , "Underscore dependency should specify ^1.5.1"
        npm.config.set "save", `undefined`
        s.close()
        t.end()
        return

      return

    return

  return

test "npm install --save-dev with default save-prefix should install local pkg to dev dependencies versioned to allow minor updates", (t) ->
  resetPackageJSON pkg
  mr common.port, (s) ->
    npm.load
      cache: pkg + "/cache"
      loglevel: "silent"
      "save-prefix": "^"
      registry: common.registry
    , (err) ->
      t.ifError err
      npm.config.set "save-dev", true
      npm.commands.install ["underscore@1.3.1"], (err) ->
        t.ifError err
        p = path.resolve(pkg, "node_modules/underscore/package.json")
        t.ok JSON.parse(fs.readFileSync(p))
        pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
        t.deepEqual pkgJson.devDependencies,
          underscore: "^1.3.1"
        , "Underscore devDependency should specify ^1.3.1"
        npm.config.set "save-dev", `undefined`
        s.close()
        t.end()
        return

      return

    return

  return

test "npm install --save with \"~\" save-prefix should install local pkg versioned to allow patch updates", (t) ->
  resetPackageJSON pkg
  mr common.port, (s) ->
    npm.load
      cache: pkg + "/cache"
      loglevel: "silent"
      registry: common.registry
    , (err) ->
      t.ifError err
      npm.config.set "save", true
      npm.config.set "save-prefix", "~"
      npm.commands.install ["underscore@1.3.1"], (err) ->
        t.ifError err
        p = path.resolve(pkg, "node_modules/underscore/package.json")
        t.ok JSON.parse(fs.readFileSync(p))
        pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
        t.deepEqual pkgJson.dependencies,
          underscore: "~1.3.1"
        , "Underscore dependency should specify ~1.3.1"
        npm.config.set "save", `undefined`
        npm.config.set "save-prefix", `undefined`
        s.close()
        t.end()
        return

      return

    return

  return

test "npm install --save-dev with \"~\" save-prefix should install local pkg to dev dependencies versioned to allow patch updates", (t) ->
  resetPackageJSON pkg
  mr common.port, (s) ->
    npm.load
      cache: pkg + "/cache"
      loglevel: "silent"
      registry: common.registry
    , (err) ->
      t.ifError err
      npm.config.set "save-dev", true
      npm.config.set "save-prefix", "~"
      npm.commands.install ["underscore@1.3.1"], (err) ->
        t.ifError err
        p = path.resolve(pkg, "node_modules/underscore/package.json")
        t.ok JSON.parse(fs.readFileSync(p))
        pkgJson = JSON.parse(fs.readFileSync(pkg + "/package.json", "utf8"))
        t.deepEqual pkgJson.devDependencies,
          underscore: "~1.3.1"
        , "Underscore devDependency should specify ~1.3.1"
        npm.config.set "save-dev", `undefined`
        npm.config.set "save-prefix", `undefined`
        s.close()
        t.end()
        return

      return

    return

  return

test "cleanup", (t) ->
  process.chdir __dirname
  rimraf.sync path.resolve(pkg, "node_modules")
  rimraf.sync path.resolve(pkg, "cache")
  resetPackageJSON pkg
  t.end()
  return

