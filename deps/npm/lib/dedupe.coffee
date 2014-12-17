# traverse the node_modules/package.json tree
# looking for duplicates.  If any duplicates are found,
# then move them up to the highest level necessary
# in order to make them no longer duplicated.
#
# This is kind of ugly, and really highlights the need for
# much better "put pkg X at folder Y" abstraction.  Oh well,
# whatever.  Perfect enemy of the good, and all that.
dedupe = (args, silent, cb) ->
  if typeof silent is "function"
    cb = silent
    silent = false
  dryrun = false
  dryrun = true  if npm.command.match(/^find/)
  dedupe_ npm.prefix, args, {}, dryrun, silent, cb
dedupe_ = (dir, filter, unavoidable, dryrun, silent, cb) ->
  readInstalled path.resolve(dir), {}, null, (er, data, counter) ->
    return cb(er)  if er
    return cb()  unless data
    
    # find out which things are dupes
    dupes = Object.keys(counter or {}).filter((k) ->
      return false  if filter.length and -1 is filter.indexOf(k)
      counter[k] > 1 and not unavoidable[k]
    ).reduce((s, k) ->
      s[k] = []
      s
    , {})
    
    # any that are unavoidable need to remain as they are.  don't even
    # try to touch them or figure it out.  Maybe some day, we can do
    # something a bit more clever here, but for now, just skip over it,
    # and all its children.
    (U = (obj) ->
      obj.unavoidable = true  if unavoidable[obj.name]
      obj.unavoidable = true  if obj.parent and obj.parent.unavoidable
      Object.keys(obj.children).forEach (k) ->
        U obj.children[k]
        return

      return
    ) data
    
    # then collect them up and figure out who needs them
    (C = (obj) ->
      if dupes[obj.name] and not obj.unavoidable
        dupes[obj.name].push obj
        obj.duplicate = true
      obj.dependents = whoDepends(obj)
      Object.keys(obj.children).forEach (k) ->
        C obj.children[k]
        return

      return
    ) data
    if dryrun
      k = Object.keys(dupes)
      return cb()  unless k.length
      return npm.commands.ls(k, silent, cb)
    
    # a=/path/to/node_modules/foo/node_modules/bar
    # b=/path/to/node_modules/elk/node_modules/bar
    # ==/path/to/node_modules/bar
    
    # find the longest chain that both A and B share.
    # then push the name back on it, and join by /node_modules/
    summary = Object.keys(dupes).map((n) ->
      [
        n
        dupes[n].filter((d) ->
          d and d.parent and not d.parent.duplicate and not d.unavoidable
        ).map(M = (d) ->
          [
            d.path
            d.version
            d.dependents.map((k) ->
              [
                k.path
                k.version
                k.dependencies[d.name] or ""
              ]
            )
          ]
        )
      ]
    ).map((item) ->
      set = item[1]
      ranges = set.map((i) ->
        i[2].map (d) ->
          d[2]

      ).reduce((l, r) ->
        l.concat r
      , []).map((v, i, set) ->
        return false  if set.indexOf(v) isnt i
        v
      ).filter((v) ->
        v isnt false
      )
      locs = set.map((i) ->
        i[0]
      )
      versions = set.map((i) ->
        i[1]
      ).filter((v, i, set) ->
        set.indexOf(v) is i
      )
      has = set.map((i) ->
        [
          i[0]
          i[1]
        ]
      ).reduce((set, kv) ->
        set[kv[0]] = kv[1]
        set
      , {})
      loc = (if locs.length then locs.reduce((a, b) ->
        nmReg = new RegExp("\\" + path.sep + "node_modules\\" + path.sep)
        a = a.split(nmReg)
        b = b.split(nmReg)
        name = a.pop()
        b.pop()
        i = 0
        al = a.length
        bl = b.length

        while i < al and i < bl and a[i] is b[i]
          i++
        a.slice(0, i).concat(name).join path.sep + "node_modules" + path.sep
      ) else `undefined`)
      [
        item[0]
        {
          item: item
          ranges: ranges
          locs: locs
          loc: loc
          has: has
          versions: versions
        }
      ]
    ).filter((i) ->
      i[1].loc
    )
    findVersions npm, summary, (er, set) ->
      return cb(er)  if er
      return cb()  unless set.length
      installAndRetest set, filter, dir, unavoidable, silent, cb
      return

    return

  return
installAndRetest = (set, filter, dir, unavoidable, silent, cb) ->
  
  #return cb(null, set)
  remove = []
  asyncMap set, ((item, cb) ->
    
    # [name, has, loc, locMatch, regMatch, others]
    name = item[0]
    has = item[1]
    where = item[2]
    locMatch = item[3]
    regMatch = item[4]
    others = item[5]
    
    # nothing to be done here.  oh well.  just a conflict.
    if not locMatch and not regMatch
      log.warn "unavoidable conflict", item[0], item[1]
      log.warn "unavoidable conflict", "Not de-duplicating"
      unavoidable[item[0]] = true
      return cb()
    
    # nothing to do except to clean up the extraneous deps
    if locMatch and has[where] is locMatch
      remove.push.apply remove, others
      return cb()
    if regMatch
      what = name + "@" + regMatch
      
      # where is /path/to/node_modules/foo/node_modules/bar
      # for package "bar", but we need it to be just
      # /path/to/node_modules/foo
      nmReg = new RegExp("\\" + path.sep + "node_modules\\" + path.sep)
      where = where.split(nmReg)
      where.pop()
      where = where.join(path.sep + "node_modules" + path.sep)
      remove.push.apply remove, others
      return npm.commands.install(where, what, cb)
    
    # hrm?
    cb new Error("danger zone\n" + name + " " + regMatch + " " + locMatch)
  ), (er) ->
    return cb(er)  if er
    asyncMap remove, rm, (er) ->
      return cb(er)  if er
      remove.forEach (r) ->
        log.info "rm", r
        return

      dedupe_ dir, filter, unavoidable, false, silent, cb
      return

    return

  return
findVersions = (npm, summary, cb) ->
  
  # now, for each item in the summary, try to find the maximum version
  # that will satisfy all the ranges.  next step is to install it at
  # the specified location.
  asyncMap summary, ((item, cb) ->
    
    # not actually a dupe, or perhaps all the other copies were
    # children of a dupe, so this'll maybe be picked up later.
    
    # { <folder>: <version> }
    
    # the versions that we already have.
    # if one of these is ok, then prefer to use that.
    # otherwise, try fetching from the registry.
    next = (er, data) ->
      regVersions = (if er then [] else Object.keys(data.versions))
      locMatch = bestMatch(versions, ranges)
      tag = npm.config.get("tag")
      distTag = data["dist-tags"] and data["dist-tags"][tag]
      regMatch = undefined
      if distTag and data.versions[distTag] and matches(distTag, ranges)
        regMatch = distTag
      else
        regMatch = bestMatch(regVersions, ranges)
      cb null, [[
        name
        has
        loc
        locMatch
        regMatch
        locs
      ]]
      return
    name = item[0]
    data = item[1]
    loc = data.loc
    locs = data.locs.filter((l) ->
      l isnt loc
    )
    return cb(null, [])  if locs.length is 0
    has = data.has
    versions = data.versions
    ranges = data.ranges
    mapToRegistry name, npm.config, (er, uri) ->
      return cb(er)  if er
      npm.registry.get uri, null, next
      return

    return
  ), cb
  return
matches = (version, ranges) ->
  not ranges.some((r) ->
    not semver.satisfies(version, r, true)
  )
bestMatch = (versions, ranges) ->
  versions.filter((v) ->
    matches v, ranges
  ).sort(semver.compareLoose).pop()
readInstalled = (dir, counter, parent, cb) ->
  # not a package, probably.
  # error is ok, just means no children.
  next = ->
    if not children or not pkg or not realpath
      
      # ignore devDependencies.  Just leave them where they are.
      return children = children.filter((c) ->
        not pkg.devDependencies.hasOwnProperty(c)
      )
    pkg.realPath = realpath
    children = []  if pkg.realPath isnt pkg.path
    d = path.resolve(dir, "node_modules")
    asyncMap children, ((child, cb) ->
      readInstalled path.resolve(d, child), counter, pkg, cb
      return
    ), (er) ->
      cb er, pkg, counter
      return

    return
  pkg = undefined
  children = undefined
  realpath = undefined
  fs.realpath dir, (er, rp) ->
    realpath = rp
    next()
    return

  readJson path.resolve(dir, "package.json"), (er, data) ->
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    return cb()  if er
    counter[data.name] = counter[data.name] or 0
    counter[data.name]++
    pkg =
      _id: data._id
      name: data.name
      version: data.version
      dependencies: data.dependencies or {}
      optionalDependencies: data.optionalDependencies or {}
      devDependencies: data.devDependencies or {}
      bundledDependencies: data.bundledDependencies or []
      path: dir
      realPath: dir
      children: {}
      parent: parent
      family: Object.create((if parent then parent.family else null))
      unavoidable: false
      duplicate: false

    if parent
      parent.children[data.name] = pkg
      parent.family[data.name] = pkg
    next()
    return

  fs.readdir path.resolve(dir, "node_modules"), (er, c) ->
    children = c or []
    children = children.filter((p) ->
      not p.match(/^[\._-]/)
    )
    next()
    return

  return
whoDepends = (pkg) ->
  start = pkg.parent or pkg
  whoDepends_ pkg, [], start
whoDepends_ = (pkg, who, test) ->
  who.push test  if test isnt pkg and test.dependencies[pkg.name] and test.family[pkg.name] is pkg
  Object.keys(test.children).forEach (n) ->
    whoDepends_ pkg, who, test.children[n]
    return

  who
fs = require("fs")
asyncMap = require("slide").asyncMap
path = require("path")
readJson = require("read-package-json")
semver = require("semver")
rm = require("./utils/gently-rm.js")
log = require("npmlog")
npm = require("./npm.js")
mapToRegistry = require("./utils/map-to-registry.js")
module.exports = dedupe
dedupe.usage = "npm dedupe [pkg pkg...]"
