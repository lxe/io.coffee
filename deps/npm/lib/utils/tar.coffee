# commands for packing and unpacking tarballs
# this file is used by lib/cache.js
pack = (tarball, folder, pkg, dfc, cb) ->
  log.verbose "tar pack", [
    tarball
    folder
  ]
  if typeof cb isnt "function"
    cb = dfc
    dfc = false
  log.verbose "tarball", tarball
  log.verbose "folder", folder
  if dfc
    
    # do fancy crap
    lifecycle pkg, "prepublish", folder, (er) ->
      return cb(er)  if er
      pack_ tarball, folder, pkg, cb
      return

  else
    pack_ tarball, folder, pkg, cb
  return
pack_ = (tarball, folder, pkg, cb) ->
  
  # By default, npm includes some proprietary attributes in the
  # package tarball.  This is sane, and allowed by the spec.
  # However, npm *itself* excludes these from its own package,
  # so that it can be more easily bootstrapped using old and
  # non-compliant tar implementations.
  new Packer(
    path: folder
    type: "Directory"
    isDirectory: true
  ).on("error", (er) ->
    log.error "tar pack", "Error reading " + folder  if er
    cb er
  ).pipe(tar.Pack(noProprietary: not npm.config.get("proprietary-attribs"))).on("error", (er) ->
    log.error "tar.pack", "tar creation error", tarball  if er
    cb er
    return
  ).pipe(zlib.Gzip()).on("error", (er) ->
    log.error "tar.pack", "gzip error " + tarball  if er
    cb er
    return
  ).pipe(fstream.Writer(
    type: "File"
    path: tarball
  )).on("error", (er) ->
    log.error "tar.pack", "Could not write " + tarball  if er
    cb er
    return
  ).on "close", cb
  return
unpack = (tarball, unpackTarget, dMode, fMode, uid, gid, cb) ->
  log.verbose "tar", "unpack", tarball
  log.verbose "tar", "unpacking to", unpackTarget
  if typeof cb isnt "function"
    cb = gid
    gid = null
  if typeof cb isnt "function"
    cb = uid
    uid = null
  if typeof cb isnt "function"
    cb = fMode
    fMode = npm.modes.file
  if typeof cb isnt "function"
    cb = dMode
    dMode = npm.modes.exec
  uidNumber uid, gid, (er, uid, gid) ->
    return cb(er)  if er
    unpack_ tarball, unpackTarget, dMode, fMode, uid, gid, cb
    return

  return
unpack_ = (tarball, unpackTarget, dMode, fMode, uid, gid, cb) ->
  rm unpackTarget, (er) ->
    return cb(er)  if er
    
    # gzip {tarball} --decompress --stdout \
    #   | tar -mvxpf - --strip-components=1 -C {unpackTarget}
    gunzTarPerm tarball, unpackTarget, dMode, fMode, uid, gid, (er, folder) ->
      return cb(er)  if er
      readJson path.resolve(folder, "package.json"), cb
      return

    return

  return
gunzTarPerm = (tarball, target, dMode, fMode, uid, gid, cb_) ->
  cb = (er) ->
    return cbCalled = true  if cbCalled
    cb_ er, target
    return
  
  # figure out who we're supposed to be, if we're not pretending
  # to be a specific user.
  extractEntry = (entry) ->
    log.silly "gunzTarPerm", "extractEntry", entry.path
    
    # never create things that are user-unreadable,
    # or dirs that are user-un-listable. Only leads to headaches.
    originalMode = entry.mode = entry.mode or entry.props.mode
    entry.mode = entry.mode | ((if entry.type is "Directory" then dMode else fMode))
    entry.mode = entry.mode & (~npm.modes.umask)
    entry.props.mode = entry.mode
    if originalMode isnt entry.mode
      log.silly "gunzTarPerm", "modified mode", [
        entry.path
        originalMode
        entry.mode
      ]
    
    # if there's a specific owner uid/gid that we want, then set that
    if process.platform isnt "win32" and typeof uid is "number" and typeof gid is "number"
      entry.props.uid = entry.uid = uid
      entry.props.gid = entry.gid = gid
    return
  dMode = npm.modes.exec  unless dMode
  fMode = npm.modes.file  unless fMode
  log.silly "gunzTarPerm", "modes", [
    dMode.toString(8)
    fMode.toString(8)
  ]
  cbCalled = false
  fst = fs.createReadStream(tarball)
  fst.on "open", (fd) ->
    fs.fstat fd, (er, st) ->
      return fst.emit("error", er)  if er
      if st.size is 0
        er = new Error("0-byte tarball\n" + "Please run `npm cache clean`")
        fst.emit "error", er
      return

    return

  if npm.config.get("unsafe-perm") and process.platform isnt "win32"
    uid = myUid
    gid = myGid
  extractOpts =
    type: "Directory"
    path: target
    strip: 1

  if process.platform isnt "win32" and typeof uid is "number" and typeof gid is "number"
    extractOpts.uid = uid
    extractOpts.gid = gid
  sawIgnores = {}
  extractOpts.filter = ->
    
    # symbolic links are not allowed in packages.
    if @type.match(/^.*Link$/)
      log.warn "excluding symbolic link", @path.substr(target.length + 1) + " -> " + @linkpath
      return false
    
    # Note: This mirrors logic in the fs read operations that are
    # employed during tarball creation, in the fstream-npm module.
    # It is duplicated here to handle tarballs that are created
    # using other means, such as system tar or git archive.
    if @type is "File"
      base = path.basename(@path)
      if base is ".npmignore"
        sawIgnores[@path] = true
      else if base is ".gitignore"
        npmignore = @path.replace(/\.gitignore$/, ".npmignore")
        if sawIgnores[npmignore]
          
          # Skip this one, already seen.
          return false
        else
          
          # Rename, may be clobbered later.
          @path = npmignore
          @_path = npmignore
    true

  fst.on("error", (er) ->
    log.error "tar.unpack", "error reading " + tarball  if er
    cb er
    return
  ).on "data", OD = (c) ->
    
    # detect what it is.
    # Then, depending on that, we'll figure out whether it's
    # a single-file module, gzipped tarball, or naked tarball.
    # gzipped files all start with 1f8b08
    if c[0] is 0x1f and c[1] is 0x8b and c[2] is 0x08
      fst.pipe(zlib.Unzip()).on("error", (er) ->
        log.error "tar.unpack", "unzip error " + tarball  if er
        cb er
        return
      ).pipe(tar.Extract(extractOpts)).on("entry", extractEntry).on("error", (er) ->
        log.error "tar.unpack", "untar error " + tarball  if er
        cb er
        return
      ).on "close", cb
    else if c.toString().match(/^package\//) or c.toString().match(/^pax_global_header/)
      
      # naked tar
      fst.pipe(tar.Extract(extractOpts)).on("entry", extractEntry).on("error", (er) ->
        log.error "tar.unpack", "untar error " + tarball  if er
        cb er
        return
      ).on "close", cb
    else
      
      # naked js file
      jsOpts = path: path.resolve(target, "index.js")
      if process.platform isnt "win32" and typeof uid is "number" and typeof gid is "number"
        jsOpts.uid = uid
        jsOpts.gid = gid
      fst.pipe(fstream.Writer(jsOpts)).on("error", (er) ->
        log.error "tar.unpack", "copy error " + tarball  if er
        cb er
        return
      ).on "close", ->
        j = path.resolve(target, "package.json")
        readJson j, (er, d) ->
          if er
            log.error "not a package", tarball
            return cb(er)
          writeFileAtomic j, JSON.stringify(d) + "\n", cb
          return

        return

    
    # now un-hook, and re-emit the chunk
    fst.removeListener "data", OD
    fst.emit "data", c
    return

  return
npm = require("../npm.js")
fs = require("graceful-fs")
writeFileAtomic = require("write-file-atomic")
path = require("path")
log = require("npmlog")
uidNumber = require("uid-number")
rm = require("./gently-rm.js")
readJson = require("read-package-json")
myUid = process.getuid and process.getuid()
myGid = process.getgid and process.getgid()
tar = require("tar")
zlib = require("zlib")
fstream = require("fstream")
Packer = require("fstream-npm")
lifecycle = require("./lifecycle.js")
if process.env.SUDO_UID and myUid is 0
  myUid = +process.env.SUDO_UID  unless isNaN(process.env.SUDO_UID)
  myGid = +process.env.SUDO_GID  unless isNaN(process.env.SUDO_GID)
exports.pack = pack
exports.unpack = unpack
