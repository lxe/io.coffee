getCacheRoot = (data) ->
  assert data, "must pass package metadata"
  assert data.name, "package metadata must include name"
  assert data.version, "package metadata must include version"
  resolve npm.cache, data.name, data.version
assert = require("assert")
resolve = require("path").resolve
npm = require("../npm.js")
module.exports = getCacheRoot
