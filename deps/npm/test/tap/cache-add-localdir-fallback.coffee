path = require("path")
test = require("tap").test
npm = require("../../lib/npm.js")
requireInject = require("require-inject")
realizePackageSpecifier = requireInject("realize-package-specifier",
  fs:
    stat: (file, cb) ->
      process.nextTick ->
        switch file
          when path.resolve("named")
            cb new Error("ENOENT")
          when path.resolve("file.tgz")
            cb null,
              isDirectory: ->
                false

          when path.resolve("dir-no-package")
            cb null,
              isDirectory: ->
                true

          when path.resolve("dir-no-package/package.json")
            cb new Error("ENOENT")
          when path.resolve("dir-with-package")
            cb null,
              isDirectory: ->
                true

          when path.resolve("dir-with-package/package.json")
            cb null, {}
          when path.resolve(__dirname, "dir-with-package")
            cb null,
              isDirectory: ->
                true

          when path.join(__dirname, "dir-with-package", "package.json")
            cb null, {}
          when path.resolve(__dirname, "file.tgz")
            cb null,
              isDirectory: ->
                false

          else
            throw new Error("Unknown test file passed to stat: " + file)
        return

      return
)
npm.load
  loglevel: "silent"
, ->
  cache = requireInject("../../lib/cache.js",
    "realize-package-specifier": realizePackageSpecifier
    "../../lib/cache/add-named.js": addNamed = (name, version, data, cb) ->
      cb null, "addNamed"
      return

    "../../lib/cache/add-local.js": addLocal = (name, data, cb) ->
      cb null, "addLocal"
      return
  )
  test "npm install localdir fallback", (t) ->
    t.plan 12
    cache.add "named", null, null, false, (er, which) ->
      t.ifError er, "named was cached"
      t.is which, "addNamed", "registry package name"
      return

    cache.add "file.tgz", null, null, false, (er, which) ->
      t.ifError er, "file.tgz was cached"
      t.is which, "addLocal", "local file"
      return

    cache.add "dir-no-package", null, null, false, (er, which) ->
      t.ifError er, "local directory was cached"
      t.is which, "addNamed", "local directory w/o package.json"
      return

    cache.add "dir-with-package", null, null, false, (er, which) ->
      t.ifError er, "local directory with package was cached"
      t.is which, "addLocal", "local directory with package.json"
      return

    cache.add "file:./dir-with-package", null, __dirname, false, (er, which) ->
      t.ifError er, "local directory (as URI) with package was cached"
      t.is which, "addLocal", "file: URI to local directory with package.json"
      return

    cache.add "file:./file.tgz", null, __dirname, false, (er, which) ->
      t.ifError er, "local file (as URI) with package was cached"
      t.is which, "addLocal", "file: URI to local file with package.json"
      return

    return

  return

