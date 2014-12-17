help = (args, cb) ->
  npm.spinner.stop()
  argv = npm.config.get("argv").cooked
  argnum = 0
  argnum = ~~args.shift()  if args.length is 2 and ~~args[0]
  
  # npm help foo bar baz: search topics
  return npm.commands["help-search"](args, argnum, cb)  if args.length > 1 and args[0]
  section = npm.deref(args[0]) or args[0]
  
  # npm help <noargs>:  show basic usage
  unless section
    valid = (if argv[0] is "help" then 0 else 1)
    return npmUsage(valid, cb)
  
  # npm <cmd> -h: show command usage
  if npm.config.get("usage") and npm.commands[section] and npm.commands[section].usage
    npm.config.set "loglevel", "silent"
    log.level = "silent"
    console.log npm.commands[section].usage
    return cb()
  
  # npm apihelp <section>: Prefer section 3 over section 1
  apihelp = argv.length and -1 isnt argv[0].indexOf("api")
  pref = (if apihelp then [
    3
    1
    5
    7
  ] else [
    1
    3
    5
    7
  ])
  if argnum
    pref = [argnum].concat(pref.filter((n) ->
      n isnt argnum
    ))
  
  # npm help <section>: Try to find the path
  manroot = path.resolve(__dirname, "..", "man")
  
  # legacy
  if section is "global"
    section = "folders"
  else section = "package.json"  if section is "json"
  
  # find either /section.n or /npm-section.n
  f = "+(npm-" + section + "|" + section + ").[0-9]"
  glob manroot + "/*/" + f, (er, mans) ->
    return cb(er)  if er
    return npm.commands["help-search"](args, cb)  unless mans.length
    viewMan pickMan(mans, pref), cb
    return

pickMan = (mans, pref_) ->
  nre = /([0-9]+)$/
  pref = {}
  pref_.forEach (sect, i) ->
    pref[sect] = i
    return

  mans = mans.sort((a, b) ->
    an = a.match(nre)[1]
    bn = b.match(nre)[1]
    (if an is bn then ((if a > b then -1 else 1)) else (if pref[an] < pref[bn] then -1 else 1))
  )
  mans[0]
viewMan = (man, cb) ->
  nre = /([0-9]+)$/
  num = man.match(nre)[1]
  section = path.basename(man, "." + num)
  
  # at this point, we know that the specified man page exists
  manpath = path.join(__dirname, "..", "man")
  env = {}
  Object.keys(process.env).forEach (i) ->
    env[i] = process.env[i]
    return

  env.MANPATH = manpath
  viewer = npm.config.get("viewer")
  conf = undefined
  switch viewer
    when "woman"
      a = [
        "-e"
        "(woman-find-file \"" + man + "\")"
      ]
      conf =
        env: env
        stdio: "inherit"

      woman = spawn("emacsclient", a, conf)
      woman.on "close", cb
    when "browser"
      opener htmlMan(man),
        command: npm.config.get("browser")
      , cb
    else
      conf =
        env: env
        stdio: "inherit"

      manProcess = spawn("man", [
        num
        section
      ], conf)
      manProcess.on "close", cb
htmlMan = (man) ->
  sect = +man.match(/([0-9]+)$/)[1]
  f = path.basename(man).replace(/([0-9]+)$/, "html")
  switch sect
    when 1
      sect = "cli"
    when 3
      sect = "api"
    when 5
      sect = "files"
    when 7
      sect = "misc"
    else
      throw new Error("invalid man section: " + sect)
  path.resolve __dirname, "..", "html", "doc", sect, f
npmUsage = (valid, cb) ->
  npm.config.set "loglevel", "silent"
  log.level = "silent"
  console.log [
    "\nUsage: npm <command>"
    ""
    "where <command> is one of:"
    (if npm.config.get("long") then usages() else "    " + wrap(Object.keys(npm.commands)))
    ""
    "npm <cmd> -h     quick help on <cmd>"
    "npm -l           display full usage info"
    "npm faq          commonly asked questions"
    "npm help <term>  search for help on <term>"
    "npm help npm     involved overview"
    ""
    "Specify configs in the ini-formatted file:"
    "    " + npm.config.get("userconfig")
    "or on the command line via: npm <command> --key value"
    "Config info can be viewed via: npm help config"
    ""
    "npm@" + npm.version + " " + path.dirname(__dirname)
  ].join("\n")
  cb valid
  return
usages = ->
  
  # return a string of <cmd>: <usage>
  maxLen = 0
  Object.keys(npm.commands).filter((c) ->
    c is npm.deref(c)
  ).reduce((set, c) ->
    set.push [
      c
      npm.commands[c].usage or ""
    ]
    maxLen = Math.max(maxLen, c.length)
    set
  , []).map((item) ->
    c = item[0]
    usage = item[1]
    "\n    " + c + (new Array(maxLen - c.length + 2).join(" ")) + (usage.split("\n").join("\n" + (new Array(maxLen + 6).join(" "))))
  ).join "\n"
wrap = (arr) ->
  out = [""]
  l = 0
  line = undefined
  line = process.stdout.columns
  unless line
    line = 60
  else
    line = Math.min(60, Math.max(line - 16, 24))
  arr.sort((a, b) ->
    (if a < b then -1 else 1)
  ).forEach (c) ->
    if out[l].length + c.length + 2 < line
      out[l] += ", " + c
    else
      out[l++] += ","
      out[l] = c
    return

  out.join("\n    ").substr 2
getSections = (cb) ->
  g = path.resolve(__dirname, "../man/man[0-9]/*.[0-9]")
  glob g, (er, files) ->
    return cb(er)  if er
    cb null, Object.keys(files.reduce((acc, file) ->
      file = path.basename(file).replace(/\.[0-9]+$/, "")
      file = file.replace(/^npm-/, "")
      acc[file] = true
      acc
    ,
      help: true
    ))
    return

  return
module.exports = help
help.completion = (opts, cb) ->
  return cb(null, [])  if opts.conf.argv.remain.length > 2
  getSections cb
  return

path = require("path")
spawn = require("child_process").spawn
npm = require("./npm.js")
log = require("npmlog")
opener = require("opener")
glob = require("glob")
