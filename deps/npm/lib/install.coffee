# npm install <pkg> <pkg> <pkg>
#
# See doc/install.md for more description

# Managing contexts...
# there's a lot of state associated with an "install" operation, including
# packages that are already installed, parent packages, current shrinkwrap, and
# so on. We maintain this state in a "context" object that gets passed around.
# every time we dive into a deeper node_modules folder, the "family" list that
# gets passed along uses the previous "family" list as its __proto__.  Any
# "resolved precise dependency" things that aren't already on this object get
# added, and then that's passed to the next generation of installation.

# install can complete to a folder with a package.json, or any package.
# if it has a slash, then it's gotta be a folder
# if it starts with https?://, then just give up, because it's a url
# for now, not yet implemented.
install = (args, cb_) ->
  cb = (er, installed) ->
    return cb_(er)  if er
    findPeerInvalid where, (er, problem) ->
      return cb_(er)  if er
      if problem
        peerInvalidError = new Error("The package " + problem.name + " does not satisfy its siblings' peerDependencies requirements!")
        peerInvalidError.code = "EPEERINVALID"
        peerInvalidError.packageName = problem.name
        peerInvalidError.peersDepending = problem.peersDepending
        return cb(peerInvalidError)
      tree = treeify(installed or [])
      pretty = prettify(tree, installed).trim()
      console.log pretty  if pretty
      save where, installed, tree, pretty, hasArguments, cb_
      return

    return
  hasArguments = !!args.length
  
  # the /path/to/node_modules/..
  where = path.resolve(npm.dir, "..")
  
  # internal api: install(where, what, cb)
  if arguments.length is 3
    where = args
    args = [].concat(cb_) # pass in [] to do default dep-install
    cb_ = arguments[2]
    log.verbose "install", "where, what", [
      where
      args
    ]
  unless npm.config.get("global")
    args = args.filter((a) ->
      path.resolve(a) isnt where
    )
  mkdir where, (er) ->
    return cb(er)  if er
    
    # install dependencies locally by default,
    # or install current folder globally
    unless args.length
      opt = dev: npm.config.get("dev") or not npm.config.get("production")
      if npm.config.get("global")
        args = ["."]
      else
        return readDependencies(null, where, opt, (er, data) ->
          if er
            log.error "install", "Couldn't read dependencies"
            return cb(er)
          deps = Object.keys(data.dependencies or {})
          log.verbose "install", "where, deps", [
            where
            deps
          ]
          
          # FIXME: Install peerDependencies as direct dependencies, but only at
          # the top level. Should only last until peerDependencies are nerfed to
          # no longer implicitly install themselves.
          peers = []
          Object.keys(data.peerDependencies or {}).forEach (dep) ->
            unless data.dependencies[dep]
              log.verbose "install", "peerDependency", dep, "wasn't going to be installed; adding"
              peers.push dep
            return

          log.verbose "install", "where, peers", [
            where
            peers
          ]
          context =
            family: {}
            ancestors: {}
            explicit: false
            parent: data
            root: true
            wrap: null

          
          # Only include in ancestry if it can actually be required.
          # Otherwise, it does not count.
          context.family[data.name] = context.ancestors[data.name] = data.version  if data.name is path.basename(where) and path.basename(path.dirname(where)) is "node_modules"
          installManyTop deps.map((dep) ->
            target = data.dependencies[dep]
            dep + "@" + target
          ).concat(peers.map((dep) ->
            target = data.peerDependencies[dep]
            dep + "@" + target
          )), where, context, (er, results) ->
            return cb(er, results)  if er or npm.config.get("production")
            lifecycle data, "prepublish", where, (er) ->
              cb er, results

            return

          return
        )
    
    # initial "family" is the name:version of the root, if it's got
    # a package.json file.
    jsonFile = path.resolve(where, "package.json")
    readJson jsonFile, log.warn, (er, data) ->
      return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
      data = null  if er
      context =
        family: {}
        ancestors: {}
        explicit: true
        parent: data
        root: true
        wrap: null

      context.family[data.name] = context.ancestors[data.name] = data.version  if data and data.name is path.basename(where) and path.basename(path.dirname(where)) is "node_modules"
      fn = (if npm.config.get("global") then installMany else installManyTop)
      fn args, where, context, cb
      return

    return

  return
findPeerInvalid = (where, cb) ->
  readInstalled where,
    log: log.warn
    dev: true
  , (er, data) ->
    return cb(er)  if er
    cb null, findPeerInvalid_(data.dependencies, [])
    return

  return
findPeerInvalid_ = (packageMap, fpiList) ->
  return `undefined`  if fpiList.indexOf(packageMap) isnt -1
  fpiList.push packageMap
  for packageName of packageMap
    pkg = packageMap[packageName]
    if pkg.peerInvalid
      peersDepending = {}
      for peerName of packageMap
        peer = packageMap[peerName]
        peersDepending[peer.name + "@" + peer.version] = peer.peerDependencies[packageName]  if peer.peerDependencies and peer.peerDependencies[packageName]
      return (
        name: pkg.name
        peersDepending: peersDepending
      )
    if pkg.dependencies
      invalid = findPeerInvalid_(pkg.dependencies, fpiList)
      return invalid  if invalid
  null

# reads dependencies for the package at "where". There are several cases,
# depending on our current state and the package's configuration:
#
# 1. If "context" is specified, then we examine the context to see if there's a
#    shrinkwrap there. In that case, dependencies are read from the shrinkwrap.
# 2. Otherwise, if an npm-shrinkwrap.json file is present, dependencies are
#    read from there.
# 3. Otherwise, dependencies come from package.json.
#
# Regardless of which case we fall into, "cb" is invoked with a first argument
# describing the full package (as though readJson had been used) but with
# "dependencies" read as described above. The second argument to "cb" is the
# shrinkwrap to use in processing this package's dependencies, which may be
# "wrap" (in case 1) or a new shrinkwrap (in case 2).
readDependencies = (context, where, opts, cb) ->
  wrap = (if context then context.wrap else null)
  readJson path.resolve(where, "package.json"), log.warn, (er, data) ->
    er.code = "ENOPACKAGEJSON"  if er and er.code is "ENOENT"
    return cb(er)  if er
    if opts and opts.dev
      data.dependencies = {}  unless data.dependencies
      Object.keys(data.devDependencies or {}).forEach (k) ->
        if data.dependencies[k]
          log.warn "package.json", "Dependency '%s' exists in both dependencies " + "and devDependencies, using '%s@%s' from dependencies", k, k, data.dependencies[k]
        else
          data.dependencies[k] = data.devDependencies[k]
        return

    if not npm.config.get("optional") and data.optionalDependencies
      Object.keys(data.optionalDependencies).forEach (d) ->
        delete data.dependencies[d]

        return

    
    # User has opted out of shrinkwraps entirely
    return cb(null, data, null)  if npm.config.get("shrinkwrap") is false
    if wrap
      log.verbose "readDependencies: using existing wrap", [
        where
        wrap
      ]
      rv = {}
      Object.keys(data).forEach (key) ->
        rv[key] = data[key]
        return

      rv.dependencies = {}
      Object.keys(wrap).forEach (key) ->
        log.verbose "from wrap", [
          key
          wrap[key]
        ]
        rv.dependencies[key] = readWrap(wrap[key])
        return

      log.verbose "readDependencies returned deps", rv.dependencies
      return cb(null, rv, wrap)
    wrapfile = path.resolve(where, "npm-shrinkwrap.json")
    fs.readFile wrapfile, "utf8", (er, wrapjson) ->
      return cb(null, data, null)  if er
      log.verbose "readDependencies", "npm-shrinkwrap.json is overriding dependencies"
      newwrap = undefined
      try
        newwrap = JSON.parse(wrapjson)
      catch ex
        return cb(ex)
      log.info "shrinkwrap", "file %j", wrapfile
      rv = {}
      Object.keys(data).forEach (key) ->
        rv[key] = data[key]
        return

      rv.dependencies = {}
      Object.keys(newwrap.dependencies or {}).forEach (key) ->
        rv.dependencies[key] = readWrap(newwrap.dependencies[key])
        return

      
      # fold in devDependencies if not already present, at top level
      if opts and opts.dev
        Object.keys(data.devDependencies or {}).forEach (k) ->
          rv.dependencies[k] = rv.dependencies[k] or data.devDependencies[k]
          return

      log.verbose "readDependencies returned deps", rv.dependencies
      cb null, rv, newwrap.dependencies

    return

  return
readWrap = (w) ->
  (if (w.resolved) then w.resolved else (if (w.from and url.parse(w.from).protocol) then w.from else w.version))

# if the -S|--save option is specified, then write installed packages
# as dependencies to a package.json file.
# This is experimental.
save = (where, installed, tree, pretty, hasArguments, cb) ->
  return cb(null, installed, tree, pretty)  if not hasArguments or not npm.config.get("save") and not npm.config.get("save-dev") and not npm.config.get("save-optional") or npm.config.get("global")
  saveBundle = npm.config.get("save-bundle")
  savePrefix = npm.config.get("save-prefix")
  
  # each item in the tree is a top-level thing that should be saved
  # to the package.json file.
  # The relevant tree shape is { <folder>: {what:<pkg>} }
  saveTarget = path.resolve(where, "package.json")
  asyncMap Object.keys(tree), ((k, cb) ->
    
    # if "what" was a url, then save that instead.
    t = tree[k]
    u = url.parse(t.from)
    a = npa(t.what)
    w = [
      a.name
      a.spec
    ]
    fs.stat t.from, (er) ->
      unless er
        w[1] = "file:" + t.from
      else w[1] = t.from  if u and u.protocol
      cb null, [w]
      return

    return
  ), (er, arr) ->
    things = arr.reduce((set, k) ->
      rangeDescriptor = (if semver.valid(k[1], true) and semver.gte(k[1], "0.1.0", true) and not npm.config.get("save-exact") then savePrefix else "")
      set[k[0]] = rangeDescriptor + k[1]
      set
    , {})
    
    # don't use readJson, because we don't want to do all the other
    # tricky npm-specific stuff that's in there.
    fs.readFile saveTarget, (er, data) ->
      
      # ignore errors here, just don't save it.
      try
        data = JSON.parse(data.toString("utf8"))
      catch ex
        er = ex
      return cb(null, installed, tree, pretty)  if er
      deps = (if npm.config.get("save-optional") then "optionalDependencies" else (if npm.config.get("save-dev") then "devDependencies" else "dependencies"))
      if saveBundle
        bundle = data.bundleDependencies or data.bundledDependencies
        delete data.bundledDependencies

        bundle = []  unless Array.isArray(bundle)
        data.bundleDependencies = bundle.sort()
      log.verbose "saving", things
      data[deps] = data[deps] or {}
      Object.keys(things).forEach (t) ->
        data[deps][t] = things[t]
        if saveBundle
          i = bundle.indexOf(t)
          bundle.push t  if i is -1
          data.bundleDependencies = bundle.sort()
        return

      data[deps] = sortedObject(data[deps])
      data = JSON.stringify(data, null, 2) + "\n"
      writeFileAtomic saveTarget, data, (er) ->
        cb er, installed, tree, pretty
        return

      return

    return

  return

# Outputting *all* the installed modules is a bit confusing,
# because the length of the path does not make it clear
# that the submodules are not immediately require()able.
# TODO: Show the complete tree, ls-style, but only if --long is provided
prettify = (tree, installed) ->
  red = (set, kv) ->
    set[kv[0]] = kv[1]
    set
  if npm.config.get("json")
    tree = Object.keys(tree).map((p) ->
      return null  unless tree[p]
      what = npa(tree[p].what)
      name = what.name
      version = what.spec
      o =
        name: name
        version: version
        from: tree[p].from

      o.dependencies = tree[p].children.map(P = (dep) ->
        what = npa(dep.what)
        name = what.name
        version = what.spec
        o =
          version: version
          from: dep.from

        o.dependencies = dep.children.map(P).reduce(red, {})
        [
          name
          o
        ]
      ).reduce(red, {})
      o
    )
    return JSON.stringify(tree, null, 2)
  return parseable(installed)  if npm.config.get("parseable")
  Object.keys(tree).map((p) ->
    archy
      label: tree[p].what + " " + p
      nodes: (tree[p].children or []).map(P = (c) ->
        if npm.config.get("long")
          return (
            label: c.what
            nodes: c.children.map(P)
          )
        g = c.children.map((g) ->
          g.what
        ).join(", ")
        g = " (" + g + ")"  if g
        c.what + g
      )
    , "",
      unicode: npm.config.get("unicode")

  ).join "\n"
parseable = (installed) ->
  long = npm.config.get("long")
  cwd = process.cwd()
  installed.map((item) ->
    path.resolve(cwd, item[1]) + ((if long then ":" + item[0] else ""))
  ).join "\n"
treeify = (installed) ->
  
  # each item is [what, where, parent, parentDir]
  # If no parent, then report it.
  # otherwise, tack it into the parent's children list.
  # If the parent isn't a top-level then ignore it.
  whatWhere = installed.reduce((l, r) ->
    parentDir = r[3]
    parent = r[2]
    where = r[1]
    what = r[0]
    from = r[4]
    l[where] =
      parentDir: parentDir
      parent: parent
      children: []
      where: where
      what: what
      from: from

    l
  , {})
  
  # log.warn("install", whatWhere, "whatWhere")
  Object.keys(whatWhere).reduce ((l, r) ->
    ww = whatWhere[r]
    
    #log.warn("r, ww", [r, ww])
    unless ww.parent
      l[r] = ww
    else
      p = whatWhere[ww.parentDir]
      if p
        p.children.push ww
      else
        l[r] = ww
    l
  ), {}

# just like installMany, but also add the existing packages in
# where/node_modules to the family object.
installManyTop = (what, where, context, cb_) ->
  cb = (er, d) ->
    return cb_(er, d)  if context.explicit or er
    
    # since this wasn't an explicit install, let's build the top
    # folder, so that `npm install` also runs the lifecycle scripts.
    npm.commands.build [where], false, true, (er) ->
      cb_ er, d

    return
  next = (er) ->
    return cb(er)  if er
    installManyTop_ what, where, context, cb
    return
  return next()  if context.explicit
  readJson path.join(where, "package.json"), log.warn, (er, data) ->
    return next(er)  if er
    lifecycle data, "preinstall", where, next
    return

  return
installManyTop_ = (what, where, context, cb) ->
  nm = path.resolve(where, "node_modules")
  fs.readdir nm, (er, pkgs) ->
    return installMany(what, where, context, cb)  if er
    scopes = []
    unscoped = []
    pkgs.filter((p) ->
      not p.match(/^[\._-]/)
    ).forEach (p) ->
      
      # @names deserve deeper investigation
      if p[0] is "@"
        scopes.push p
      else
        unscoped.push p
      return

    maybeScoped scopes, nm, (er, scoped) ->
      return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
      
      # recombine unscoped with @scope/package packages
      asyncMap unscoped.concat(scoped).map((p) ->
        path.resolve nm, p, "package.json"
      ), ((jsonfile, cb) ->
        readJson jsonfile, log.warn, (er, data) ->
          return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
          return cb(null, [])  if er
          cb null, [[
            data.name
            data.version
          ]]
          return

        return
      ), (er, packages) ->
        
        # if there's nothing in node_modules, then don't freak out.
        packages = []  if er
        
        # add all the existing packages to the family list.
        # however, do not add to the ancestors list.
        packages.forEach (p) ->
          context.family[p[0]] = p[1]
          return

        installMany what, where, context, cb
        return

      return

    return

  return
maybeScoped = (scopes, where, cb) ->
  
  # find packages in scopes
  asyncMap scopes, ((scope, cb) ->
    fs.readdir path.resolve(where, scope), (er, scoped) ->
      return cb(er)  if er
      paths = scoped.map((p) ->
        path.join scope, p
      )
      cb null, paths
      return

    return
  ), cb
  return
installMany = (what, where, context, cb) ->
  
  # readDependencies takes care of figuring out whether the list of
  # dependencies we'll iterate below comes from an existing shrinkwrap from a
  # parent level, a new shrinkwrap at this level, or package.json at this
  # level, as well as which shrinkwrap (if any) our dependencies should use.
  opt = dev: npm.config.get("dev")
  readDependencies context, where, opt, (er, data, wrap) ->
    data = {}  if er
    parent = data
    d = data.dependencies or {}
    
    # if we're explicitly installing "what" into "where", then the shrinkwrap
    # for "where" doesn't apply. This would be the case if someone were adding
    # a new package to a shrinkwrapped package. (data.dependencies will not be
    # used here except to indicate what packages are already present, so
    # there's no harm in using that.)
    wrap = null  if context.explicit
    
    # what is a list of things.
    # resolve each one.
    asyncMap what, targetResolver(where, context, d), (er, targets) ->
      return cb(er)  if er
      
      # each target will be a data object corresponding
      # to a package, folder, or whatever that is in the cache now.
      newPrev = Object.create(context.family)
      newAnc = Object.create(context.ancestors)
      newAnc[data.name] = data.version  unless context.root
      targets.forEach (t) ->
        newPrev[t.name] = t.version
        return

      log.silly "install resolved", targets
      targets.filter((t) ->
        t
      ).forEach (t) ->
        log.info "install", "%s into %s", t._id, where
        return

      asyncMap targets, ((target, cb) ->
        log.info "installOne", target._id
        wrapData = (if wrap then wrap[target.name] else null)
        newWrap = (if wrapData and wrapData.dependencies then wrap[target.name].dependencies or {} else null)
        newContext =
          family: newPrev
          ancestors: newAnc
          parent: parent
          explicit: false
          wrap: newWrap

        installOne target, where, newContext, cb
        return
      ), cb
      return

    return

  return
targetResolver = (where, context, deps) ->
  readdir = (name) ->
    resolveLeft++
    fs.readdir name, (er, inst) ->
      return resolveLeft--  if er
      
      # don't even mess with non-package looking things
      inst = inst.filter((p) ->
        return true  unless p.match(/^[@\._-]/)
        
        # scoped packages
        readdir path.join(name, p)
        return
      )
      asyncMap inst, ((pkg, cb) ->
        readJson path.resolve(name, pkg, "package.json"), log.warn, (er, d) ->
          return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
          
          # error means it's not a package, most likely.
          return cb(null, [])  if er
          
          # if it's a bundled dep, then assume that anything there is valid.
          # otherwise, make sure that it's a semver match with what we want.
          bd = parent.bundleDependencies
          return cb(null, d.name)  if bd and bd.indexOf(d.name) isnt -1 or semver.satisfies(d.version, deps[d.name] or "*", true) or deps[d.name] is d._resolved
          
          # see if the package had been previously linked
          fs.lstat path.resolve(nm, pkg), (err, s) ->
            return cb(null, [])  if err
            return cb(null, d.name)  if s.isSymbolicLink()
            
            # something is there, but it's not satisfactory.  Clobber it.
            cb null, []

          return

        return
      ), (er, inst) ->
        
        # this is the list of things that are valid and should be ignored.
        alreadyInstalledManually = alreadyInstalledManually.concat(inst)
        resolveLeft--
        return

      return

    return
  alreadyInstalledManually = []
  resolveLeft = 0
  nm = path.resolve(where, "node_modules")
  parent = context.parent
  wrap = context.wrap
  readdir nm  unless context.explicit
  to = 0
  resolver = (what, cb) ->
    if resolveLeft
      return setTimeout(->
        resolver what, cb
        return
      , to++)
    
    # now we know what's been installed here manually,
    # or tampered with in some way that npm doesn't want to overwrite.
    if alreadyInstalledManually.indexOf(npa(what).name) isnt -1
      log.verbose "already installed", "skipping %s %s", what, where
      return cb(null, [])
    
    # check for a version installed higher in the tree.
    # If installing from a shrinkwrap, it must match exactly.
    if context.family[what]
      if wrap and wrap[what].version is context.family[what]
        log.verbose "shrinkwrap", "use existing", what
        return cb(null, [])
    
    # if it's identical to its parent, then it's probably someone
    # doing `npm install foo` inside of the foo project.  Print
    # a warning, and skip it.
    if parent and parent.name is what and not npm.config.get("force")
      log.warn "install", "Refusing to install %s as a dependency of itself", what
      return cb(null, [])
    if wrap
      name = npa(what).name
      if wrap[name]
        wrapTarget = readWrap(wrap[name])
        what = name + "@" + wrapTarget
      else
        log.verbose "shrinkwrap", "skipping %s (not in shrinkwrap)", what
    else what = what + "@" + deps[what]  if deps[what]
    
    # This is where we actually fetch the package, if it's not already
    # in the cache.
    # If it's a git repo, then we want to install it, even if the parent
    # already has a matching copy.
    # If it's not a git repo, and the parent already has that pkg, then
    # we can skip installing it again.
    pkgroot = path.resolve(npm.prefix, (parent and parent._from) or "")
    cache.add what, null, pkgroot, false, (er, data) ->
      if er and parent and parent.optionalDependencies and parent.optionalDependencies.hasOwnProperty(npa(what).name)
        log.warn "optional dep failed, continuing", what
        log.verbose "optional dep failed, continuing", [
          what
          er
        ]
        return cb(null, [])
      isGit = npa(what).type is "git"
      if not er and data and not context.explicit and context.family[data.name] is data.version and not npm.config.get("force") and not isGit
        log.info "already installed", data.name + "@" + data.version
        return cb(null, [])
      data._from = what  if data and not data._from
      er.parent = parent.name  if er and parent and parent.name
      cb er, data or []

    return

# we've already decided to install this.  if anything's in the way,
# then uninstall it first.
installOne = (target, where, context, cb) ->
  
  # the --link flag makes this a "link" command if it's at the
  # the top level.
  return localLink(target, where, context, cb)  if where is npm.prefix and npm.config.get("link") and not npm.config.get("global")
  installOne_ target, where, context, (er, installedWhat) ->
    
    # check if this one is optional to its parent.
    if er and context.parent and context.parent.optionalDependencies and context.parent.optionalDependencies.hasOwnProperty(target.name)
      log.warn "optional dep failed, continuing", target._id
      log.verbose "optional dep failed, continuing", [
        target._id
        er
      ]
      er = null
    cb er, installedWhat
    return

  return
localLink = (target, where, context, cb) ->
  log.verbose "localLink", target._id
  jsonFile = path.resolve(npm.globalDir, target.name, "package.json")
  parent = context.parent
  readJson jsonFile, log.warn, (er, data) ->
    thenLink = ->
      npm.commands.link [target.name], (er, d) ->
        log.silly "localLink", "back from link", [
          er
          d
        ]
        cb er, [resultList(target, where, parent and parent._id)]
        return

      return
    return cb(er)  if er and er.code isnt "ENOENT" and er.code isnt "ENOTDIR"
    if er or data._id is target._id
      if er
        install path.resolve(npm.globalDir, ".."), target._id, (er) ->
          return cb(er, [])  if er
          thenLink()
          return

      else
        thenLink()
    else
      log.verbose "localLink", "install locally (no link)", target._id
      installOne_ target, where, context, cb
    return

  return
resultList = (target, where, parentId) ->
  nm = path.resolve(where, "node_modules")
  targetFolder = path.resolve(nm, target.name)
  prettyWhere = where
  prettyWhere = path.relative(process.cwd(), where)  unless npm.config.get("global")
  prettyWhere = null  if prettyWhere is "."
  
  # print out the folder relative to where we are right now.
  targetFolder = path.relative(process.cwd(), targetFolder)  unless npm.config.get("global")
  [
    target._id
    targetFolder
    prettyWhere and parentId
    parentId and prettyWhere
    target._from
  ]
installOne_ = (target, where, context, cb_) ->
  cb = (er, data) ->
    unlock nm, target.name, ->
      cb_ er, data
      return

    return
  nm = path.resolve(where, "node_modules")
  targetFolder = path.resolve(nm, target.name)
  prettyWhere = path.relative(process.cwd(), where)
  parent = context.parent
  prettyWhere = null  if prettyWhere is "."
  cb_ = inflight(target.name + ":" + where, cb_)
  unless cb_
    return log.verbose("installOne", "of", target.name, "to", where, "already in flight; waiting")
  else
    log.verbose "installOne", "of", target.name, "to", where, "not in flight; installing"
  lock nm, target.name, (er) ->
    return cb(er)  if er
    if targetFolder of installed
      log.error "install", "trying to install", target.version, "to", targetFolder
      log.error "install", "but already installed versions", installed[targetFolder]
      installed[targetFolder].push target.version
    else
      installed[targetFolder] = [target.version]
    force = npm.config.get("force")
    nodeVersion = npm.config.get("node-version")
    strict = npm.config.get("engine-strict")
    c = npmInstallChecks
    chain [
      [
        c.checkEngine
        target
        npm.version
        nodeVersion
        force
        strict
      ]
      [
        c.checkPlatform
        target
        force
      ]
      [
        c.checkCycle
        target
        context.ancestors
      ]
      [
        c.checkGit
        targetFolder
      ]
      [
        write
        target
        targetFolder
        context
      ]
    ], (er, d) ->
      return cb(er)  if er
      d.push resultList(target, where, parent and parent._id)
      cb er, d
      return

    return

  return
write = (target, targetFolder, context, cb_) ->
  cb = (er, data) ->
    
    # cache.unpack returns the data object, and all we care about
    # is the list of installed packages from that last thing.
    return cb_(er, data)  unless er
    return cb_(er)  if npm.config.get("rollback") is false
    npm.rollbacks.push targetFolder
    cb_ er, data
    return
  up = npm.config.get("unsafe-perm")
  user = (if up then null else npm.config.get("user"))
  group = (if up then null else npm.config.get("group"))
  family = context.family
  bundled = []
  log.silly "install write", "writing", target.name, target.version, "to", targetFolder
  chain [
    [
      cache.unpack
      target.name
      target.version
      targetFolder
      null
      null
      user
      group
    ]
    [
      fs
      "writeFile"
      path.resolve(targetFolder, "package.json")
      JSON.stringify(target, null, 2) + "\n"
    ]
    [
      lifecycle
      target
      "preinstall"
      targetFolder
    ]
    (cb) ->
      return cb()  unless target.bundleDependencies
      bd = path.resolve(targetFolder, "node_modules")
      fs.readdir bd, (er, b) ->
        
        # nothing bundled, maybe
        return cb()  if er
        bundled = b or []
        cb()
        return

  
  # nest the chain so that we can throw away the results returned
  # up until this point, since we really don't care about it.
  ], X = (er) ->
    return cb(er)  if er
    
    # before continuing to installing dependencies, check for a shrinkwrap.
    opt = dev: npm.config.get("dev")
    readDependencies context, targetFolder, opt, (er, data, wrap) ->
      deps = prepareForInstallMany(data, "dependencies", bundled, wrap, family)
      depsTargetFolder = targetFolder
      depsContext =
        family: family
        ancestors: context.ancestors
        parent: target
        explicit: false
        wrap: wrap

      actions = [[
        installManyAndBuild
        deps
        depsTargetFolder
        depsContext
      ]]
      
      # FIXME: This is an accident waiting to happen!
      #
      # 1. If multiple children at the same level of the tree share a
      #    peerDependency that's not in the parent's dependencies, because
      #    the peerDeps don't get added to the family, they will keep
      #    getting reinstalled (worked around by inflighting installOne).
      # 2. The installer can't safely build at the parent level because
      #    that's already being done by the parent's installAndBuild. This
      #    runs the risk of the peerDependency never getting built.
      #
      #  The fix: Don't install peerDependencies; require them to be
      #  included as explicit dependencies / devDependencies, and warn
      #  or error when they're missing. See #5080 for more arguments in
      #  favor of killing implicit peerDependency installs with fire.
      peerDeps = prepareForInstallMany(data, "peerDependencies", bundled, wrap, family)
      pdTargetFolder = path.resolve(targetFolder, "..", "..")
      pdContext = context
      if peerDeps.length > 0
        actions.push [
          installMany
          peerDeps
          pdTargetFolder
          pdContext
        ]
      chain actions, cb
      return

    return

  return
installManyAndBuild = (deps, targetFolder, context, cb) ->
  installMany deps, targetFolder, context, (er, d) ->
    log.verbose "about to build", targetFolder
    return cb(er)  if er
    npm.commands.build [targetFolder], npm.config.get("global"), true, (er) ->
      cb er, d

    return

  return
prepareForInstallMany = (packageData, depsKey, bundled, wrap, family) ->
  deps = Object.keys(packageData[depsKey] or {})
  
  # don't install bundleDependencies, unless they're missing.
  if packageData.bundleDependencies
    deps = deps.filter((d) ->
      packageData.bundleDependencies.indexOf(d) is -1 or bundled.indexOf(d) is -1
    )
  
  # prefer to not install things that are satisfied by
  # something in the "family" list, unless we're installing
  # from a shrinkwrap.
  deps.filter((d) ->
    return wrap  if wrap
    return not semver.satisfies(family[d], packageData[depsKey][d], true)  if semver.validRange(family[d], true)
    true
  ).map (d) ->
    v = packageData[depsKey][d]
    t = d + "@" + v
    log.silly "prepareForInstallMany", "adding", t, "from", packageData.name, depsKey
    t

module.exports = install
install.usage = "npm install" + "\nnpm install <pkg>" + "\nnpm install <pkg>@<tag>" + "\nnpm install <pkg>@<version>" + "\nnpm install <pkg>@<version range>" + "\nnpm install <folder>" + "\nnpm install <tarball file>" + "\nnpm install <tarball url>" + "\nnpm install <git:// url>" + "\nnpm install <github username>/<github project>" + "\n\nCan specify one or more: npm install ./foo.tgz bar@stable /some/folder" + "\nIf no argument is supplied and ./npm-shrinkwrap.json is " + "\npresent, installs dependencies specified in the shrinkwrap." + "\nOtherwise, installs dependencies from ./package.json."
install.completion = (opts, cb) ->
  registry = npm.registry
  mapToRegistry "-/short", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri, null, (er, pkgs) ->
      return cb()  if er
      return cb(null, pkgs)  unless opts.partialWord
      name = npa(opts.partialWord).name
      pkgs = pkgs.filter((p) ->
        p.indexOf(name) is 0
      )
      return cb(null, pkgs)  if pkgs.length isnt 1 and opts.partialWord is name
      mapToRegistry pkgs[0], npm.config, (er, uri) ->
        return cb(er)  if er
        registry.get uri, null, (er, d) ->
          return cb()  if er
          cb null, Object.keys(d["dist-tags"] or {}).concat(Object.keys(d.versions or {})).map((t) ->
            pkgs[0] + "@" + t
          )

        return

      return

    return

  return

npm = require("./npm.js")
semver = require("semver")
readJson = require("read-package-json")
readInstalled = require("read-installed")
log = require("npmlog")
path = require("path")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
cache = require("./cache.js")
asyncMap = require("slide").asyncMap
chain = require("slide").chain
url = require("url")
mkdir = require("mkdirp")
lifecycle = require("./utils/lifecycle.js")
archy = require("archy")
npmInstallChecks = require("npm-install-checks")
sortedObject = require("sorted-object")
mapToRegistry = require("./utils/map-to-registry.js")
npa = require("npm-package-arg")
inflight = require("inflight")
locker = require("./utils/locker.js")
lock = locker.lock
unlock = locker.unlock
installed = Object.create(null)
