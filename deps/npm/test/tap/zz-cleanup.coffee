common = require("../common-tap")
test = require("tap").test
fs = require("fs")
test "cleanup", (t) ->
  res = common.deleteNpmCacheRecursivelySync()
  t.equal res, 0, "Deleted test npm cache successfully"
  
  # ensure cache is clean
  fs.readdir common.npm_config_cache, (err) ->
    t.ok err, "error expected"
    t.equal err.code, "ENOENT", "npm cache directory no longer exists"
    t.end()
    return

  return

