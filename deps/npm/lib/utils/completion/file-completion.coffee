fileCompletion = (root, req, depth, cb) ->
  if typeof cb isnt "function"
    cb = depth
    depth = Infinity
  mkdir root, (er) ->
    return cb(er)  if er
    
    # can be either exactly the req, or a descendent
    pattern = root + "/{" + req + "," + req + "/**/*}"
    opts =
      mark: true
      dot: true
      maxDepth: depth

    glob pattern, opts, (er, files) ->
      return cb(er)  if er
      cb null, (files or []).map((f) ->
        path.join req, f.substr(root.length + 1).substr(((if f is req then path.dirname(req) else req)).length).replace(/^\//, "")
      )

    return

  return
module.exports = fileCompletion
mkdir = require("mkdirp")
path = require("path")
glob = require("glob")
