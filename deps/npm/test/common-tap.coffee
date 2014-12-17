
# based on http://bit.ly/1tkI6DJ
deleteNpmCacheRecursivelySync = (cache) ->
  cache = (if cache then cache else npm_config_cache)
  files = []
  res = undefined
  if fs.existsSync(cache)
    files = fs.readdirSync(cache)
    files.forEach (file, index) ->
      curPath = path.resolve(cache, file)
      if fs.lstatSync(curPath).isDirectory() # recurse
        deleteNpmCacheRecursivelySync curPath
      else # delete file
        throw Error("Failed to delete file " + curPath + ", error " + res)  if res = fs.unlinkSync(curPath)
      return

    throw Error("Failed to delete directory " + cache + ", error " + res)  if res = fs.rmdirSync(cache)
  0
spawn = require("child_process").spawn
path = require("path")
fs = require("fs")
port = exports.port = 1337
exports.registry = "http://localhost:" + port
process.env.npm_config_loglevel = "error"
npm_config_cache = path.resolve(__dirname, "npm_cache")
exports.npm_config_cache = npm_config_cache
bin = exports.bin = require.resolve("../bin/npm-cli.js")
once = require("once")
exports.npm = (cmd, opts, cb) ->
  cb = once(cb)
  cmd = [bin].concat(cmd)
  opts = opts or {}
  opts.env = (if opts.env then opts.env else process.env)
  opts.env.npm_config_cache = npm_config_cache  unless opts.env.npm_config_cache
  stdout = ""
  stderr = ""
  node = process.execPath
  child = spawn(node, cmd, opts)
  if child.stderr
    child.stderr.on "data", (chunk) ->
      stderr += chunk
      return

  if child.stdout
    child.stdout.on "data", (chunk) ->
      stdout += chunk
      return

  child.on "error", cb
  child.on "close", (code) ->
    cb null, code, stdout, stderr
    return

  child

exports.deleteNpmCacheRecursivelySync = deleteNpmCacheRecursivelySync
