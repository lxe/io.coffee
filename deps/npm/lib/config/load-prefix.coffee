loadPrefix = (cb) ->
  cli = @list[0]
  Object.defineProperty this, "prefix",
    set: ((prefix) ->
      g = @get("global")
      this[(if g then "globalPrefix" else "localPrefix")] = prefix
      return
    ).bind(this)
    get: (->
      g = @get("global")
      (if g then @globalPrefix else @localPrefix)
    ).bind(this)
    enumerable: true

  Object.defineProperty this, "globalPrefix",
    set: ((prefix) ->
      @set "prefix", prefix
      return
    ).bind(this)
    get: (->
      path.resolve @get("prefix")
    ).bind(this)
    enumerable: true

  p = undefined
  Object.defineProperty this, "localPrefix",
    set: (prefix) ->
      p = prefix
      return

    get: ->
      p

    enumerable: true

  
  # try to guess at a good node_modules location.
  # If we are *explicitly* given a prefix on the cli, then
  # always use that.  otherwise, infer local prefix from cwd.
  if Object::hasOwnProperty.call(cli, "prefix")
    p = path.resolve(cli.prefix)
    process.nextTick cb
  else
    findPrefix process.cwd(), (er, found) ->
      p = found
      cb er
      return

  return
module.exports = loadPrefix
findPrefix = require("./find-prefix.js")
path = require("path")
