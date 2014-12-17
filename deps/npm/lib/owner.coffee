
# return the intersection

# kludge for server adminery.

# else fallthrough

# return mine that they're not already on.

# just list all users who aren't me.
owner = (args, cb) ->
  action = args.shift()
  switch action
    when "ls", "list"
      ls args[0], cb
    when "add"
      add args[0], args[1], cb
    when "rm", "remove"
      rm args[0], args[1], cb
    else
      unknown action, cb
ls = (pkg, cb) ->
  unless pkg
    return readLocalPkg((er, pkg) ->
      return cb(er)  if er
      return cb(owner.usage)  unless pkg
      ls pkg, cb
      return
    )
  mapToRegistry pkg, npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri, null, (er, data) ->
      msg = ""
      if er
        log.error "owner ls", "Couldn't get owner data", pkg
        return cb(er)
      owners = data.maintainers
      if not owners or not owners.length
        msg = "admin party!"
      else
        msg = owners.map((o) ->
          o.name + " <" + o.email + ">"
        ).join("\n")
      console.log msg
      cb er, owners
      return

    return

  return
add = (user, pkg, cb) ->
  return cb(owner.usage)  unless user
  unless pkg
    return readLocalPkg((er, pkg) ->
      return cb(er)  if er
      return cb(new Error(owner.usage))  unless pkg
      add user, pkg, cb
      return
    )
  log.verbose "owner add", "%s to %s", user, pkg
  mutate pkg, user, ((u, owners) ->
    owners = []  unless owners
    i = 0
    l = owners.length

    while i < l
      o = owners[i]
      if o.name is u.name
        log.info "owner add", "Already a package owner: " + o.name + " <" + o.email + ">"
        return false
      i++
    owners.push u
    owners
  ), cb
  return
rm = (user, pkg, cb) ->
  unless pkg
    return readLocalPkg((er, pkg) ->
      return cb(er)  if er
      return cb(new Error(owner.usage))  unless pkg
      rm user, pkg, cb
      return
    )
  log.verbose "owner rm", "%s from %s", user, pkg
  mutate pkg, null, ((u, owners) ->
    found = false
    m = owners.filter((o) ->
      match = (o.name is user)
      found = found or match
      not match
    )
    unless found
      log.info "owner rm", "Not a package owner: " + user
      return false
    return new Error("Cannot remove all owners of a package.  Add someone else first.")  unless m.length
    m
  ), cb
  return
mutate = (pkg, user, mutation, cb) ->
  mutate_ = (er, u) ->
    er = new Error("Couldn't get user data for " + user + ": " + JSON.stringify(u))  if not er and user and (not u or u.error)
    if er
      log.error "owner mutate", "Error getting user data for %s", user
      return cb(er)
    if u
      u =
        name: u.name
        email: u.email
    mapToRegistry pkg, npm.config, (er, uri) ->
      return cb(er)  if er
      registry.get uri, null, (er, data) ->
        if er
          log.error "owner mutate", "Error getting package data for %s", pkg
          return cb(er)
        m = mutation(u, data.maintainers)
        return cb()  unless m # handled
        return cb(m)  if m instanceof Error # error
        data =
          _id: data._id
          _rev: data._rev
          maintainers: m

        dataPath = pkg + "/-rev/" + data._rev
        mapToRegistry dataPath, npm.config, (er, uri) ->
          return cb(er)  if er
          registry.request "PUT", uri,
            body: data
          , (er, data) ->
            er = new Error("Failed to update package metadata: " + JSON.stringify(data))  if not er and data.error
            log.error "owner mutate", "Failed to update package metadata"  if er
            cb er, data
            return

          return

        return

      return

    return
  if user
    byUser = "-/user/org.couchdb.user:" + user
    mapToRegistry byUser, npm.config, (er, uri) ->
      return cb(er)  if er
      registry.get uri, null, mutate_
      return

  else
    mutate_ null, null
  return
readLocalPkg = (cb) ->
  return cb()  if npm.config.get("global")
  path = require("path")
  readJson path.resolve(npm.prefix, "package.json"), (er, d) ->
    cb er, d and d.name

  return
unknown = (action, cb) ->
  cb "Usage: \n" + owner.usage
  return
module.exports = owner
owner.usage = "npm owner add <username> <pkg>" + "\nnpm owner rm <username> <pkg>" + "\nnpm owner ls <pkg>"
npm = require("./npm.js")
registry = npm.registry
log = require("npmlog")
readJson = require("read-package-json")
mapToRegistry = require("./utils/map-to-registry.js")
owner.completion = (opts, cb) ->
  argv = opts.conf.argv.remain
  return cb()  if argv.length > 4
  if argv.length <= 2
    subs = [
      "add"
      "rm"
    ]
    if opts.partialWord is "l"
      subs.push "ls"
    else
      subs.push "ls", "list"
    return cb(null, subs)
  npm.commands.whoami [], true, (er, username) ->
    return cb()  if er
    un = encodeURIComponent(username)
    byUser = undefined
    theUser = undefined
    switch argv[2]
      when "ls"
        return cb()  if argv.length > 3
        mapToRegistry "-/short", npm.config, (er, uri) ->
          return cb(er)  if er
          registry.get uri, null, cb
          return

      when "rm"
        if argv.length > 3
          theUser = encodeURIComponent(argv[3])
          byUser = "-/by-user/" + theUser + "|" + un
          mapToRegistry byUser, npm.config, (er, uri) ->
            return cb(er)  if er
            console.error uri
            registry.get uri, null, (er, d) ->
              return cb(er)  if er
              cb null, d[theUser].filter((p) ->
                un is "isaacs" or d[un].indexOf(p) is -1
              )

            return

      when "add"
        if argv.length > 3
          theUser = encodeURIComponent(argv[3])
          byUser = "-/by-user/" + theUser + "|" + un
          return mapToRegistry(byUser, npm.config, (er, uri) ->
            return cb(er)  if er
            console.error uri
            registry.get uri, null, (er, d) ->
              console.error uri, er or d
              return cb(er)  if er
              mine = d[un] or []
              theirs = d[theUser] or []
              cb null, mine.filter((p) ->
                theirs.indexOf(p) is -1
              )

            return
          )
        mapToRegistry "-/users", npm.config, (er, uri) ->
          return cb(er)  if er
          registry.get uri, null, (er, list) ->
            return cb()  if er
            cb null, Object.keys(list).filter((n) ->
              n isnt un
            )

          return

      else
        cb()

  return
