
# get the batch of data that matches so far.
# this is an example of using npm.commands.search programmatically
# to fetch data that has been filtered by a set of arguments.
search = (args, silent, staleness, cb) ->
  if typeof cb isnt "function"
    cb = staleness
    staleness = 600
  if typeof cb isnt "function"
    cb = silent
    silent = false
  searchopts = npm.config.get("searchopts")
  searchexclude = npm.config.get("searchexclude")
  searchopts = ""  if typeof searchopts isnt "string"
  searchopts = searchopts.split(/\s+/)
  if typeof searchexclude is "string"
    searchexclude = searchexclude.split(/\s+/)
  else
    searchexclude = []
  opts = searchopts.concat(args).map((s) ->
    s.toLowerCase()
  ).filter((s) ->
    s
  )
  searchexclude = searchexclude.map((s) ->
    s.toLowerCase()
  )
  getFilteredData staleness, opts, searchexclude, (er, data) ->
    
    # now data is the list of data that we want to show.
    # prettify and print it, and then provide the raw
    # data to the cb.
    return cb(er, data)  if er or silent
    console.log prettify(data, args)
    cb null, data
    return

  return
getFilteredData = (staleness, args, notArgs, cb) ->
  opts =
    timeout: staleness
    follow: true
    staleOk: true

  mapToRegistry "-/all", npm.config, (er, uri) ->
    return cb(er)  if er
    registry.get uri, opts, (er, data) ->
      return cb(er)  if er
      cb null, filter(data, args, notArgs)

    return

  return
filter = (data, args, notArgs) ->
  
  # data={<name>:{package data}}
  Object.keys(data).map((d) ->
    data[d]
  ).filter((d) ->
    typeof d is "object"
  ).map(stripData).map(getWords).filter((data) ->
    filterWords data, args, notArgs
  ).reduce ((l, r) ->
    l[r.name] = r
    l
  ), {}
stripData = (data) ->
  name: data.name
  description: (if npm.config.get("description") then data.description else "")
  maintainers: (data.maintainers or []).map((m) ->
    "=" + m.name
  )
  url: (if not Object.keys(data.versions or {}).length then data.url else null)
  keywords: data.keywords or []
  version: Object.keys(data.versions or {})[0] or []
  # remove time
  time: data.time and data.time.modified and (new Date(data.time.modified).toISOString().split("T").join(" ").replace(/:[0-9]{2}\.[0-9]{3}Z$/, "")).slice(0, -5) or "prehistoric"
getWords = (data) ->
  data.words = [data.name].concat(data.description).concat(data.maintainers).concat(data.url and ("<" + data.url + ">")).concat(data.keywords).map((f) ->
    f and f.trim and f.trim()
  ).filter((f) ->
    f
  ).join(" ").toLowerCase()
  data
filterWords = (data, args, notArgs) ->
  words = data.words
  i = 0
  l = args.length

  while i < l
    return false  unless match(words, args[i])
    i++
  i = 0
  l = notArgs.length

  while i < l
    return false  if match(words, notArgs[i])
    i++
  true
match = (words, arg) ->
  if arg.charAt(0) is "/"
    arg = arg.replace(/\/$/, "")
    arg = new RegExp(arg.substr(1, arg.length - 1))
    return words.match(arg)
  words.indexOf(arg) isnt -1
prettify = (data, args) ->
  searchsort = (npm.config.get("searchsort") or "NAME").toLowerCase()
  sortField = searchsort.replace(/^\-+/, "")
  searchRev = searchsort.charAt(0) is "-"
  truncate = not npm.config.get("long")
  return "No match found for " + (args.map(JSON.stringify).join(" "))  if Object.keys(data).length is 0
  
  # strip keyname
  lines = Object.keys(data).map((d) ->
    data[d]
  ).map((dat) ->
    dat.author = dat.maintainers
    delete dat.maintainers

    dat.date = dat.time
    delete dat.time

    dat
  ).map((dat) ->
    
    # split keywords on whitespace or ,
    dat.keywords = dat.keywords.split(/[,\s]+/)  if typeof dat.keywords is "string"
    dat.keywords = dat.keywords.join(" ")  if Array.isArray(dat.keywords)
    
    # split author on whitespace or ,
    dat.author = dat.author.split(/[,\s]+/)  if typeof dat.author is "string"
    dat.author = dat.author.join(" ")  if Array.isArray(dat.author)
    dat
  )
  lines.sort (a, b) ->
    aa = a[sortField].toLowerCase()
    bb = b[sortField].toLowerCase()
    (if aa is bb then 0 else (if aa < bb then -1 else 1))

  lines.reverse()  if searchRev
  columns = (if npm.config.get("description") then [
    "name"
    "description"
    "author"
    "date"
    "version"
    "keywords"
  ] else [
    "name"
    "author"
    "date"
    "version"
    "keywords"
  ])
  output = columnify(lines,
    include: columns
    truncate: truncate
    config:
      name:
        maxWidth: 40
        truncate: false
        truncateMarker: ""

      description:
        maxWidth: 60

      author:
        maxWidth: 20

      date:
        maxWidth: 11

      version:
        maxWidth: 11

      keywords:
        maxWidth: Infinity
  )
  output = trimToMaxWidth(output)
  output = highlightSearchTerms(output, args)
  output
addColorMarker = (str, arg, i) ->
  m = i % cl + 1
  markStart = String.fromCharCode(m)
  markEnd = String.fromCharCode(0)
  if arg.charAt(0) is "/"
    
    #arg = arg.replace(/\/$/, "")
    return str.replace(new RegExp(arg.substr(1, arg.length - 2), "gi"), (bit) ->
      markStart + bit + markEnd
    )
  
  # just a normal string, do the split/map thing
  pieces = str.toLowerCase().split(arg.toLowerCase())
  p = 0
  pieces.map((piece) ->
    piece = str.substr(p, piece.length)
    mark = markStart + str.substr(p + piece.length, arg.length) + markEnd
    p += piece.length + arg.length
    piece + mark
  ).join ""
colorize = (line) ->
  i = 0

  while i < cl
    m = i + 1
    color = (if npm.color then "\u001b[" + colors[i] + "m" else "")
    line = line.split(String.fromCharCode(m)).join(color)
    i++
  uncolor = (if npm.color then "\u001b[0m" else "")
  line.split("\u0000").join uncolor
getMaxWidth = ->
  cols = undefined
  try
    tty = require("tty")
    stdout = process.stdout
    cols = (if not tty.isatty(stdout.fd) then Infinity else process.stdout.getWindowSize()[0])
    cols = (if (cols is 0) then Infinity else cols)
  catch ex
    cols = Infinity
  cols
trimToMaxWidth = (str) ->
  maxWidth = getMaxWidth()
  str.split("\n").map((line) ->
    line.slice 0, maxWidth
  ).join "\n"
highlightSearchTerms = (str, terms) ->
  terms.forEach (arg, i) ->
    str = addColorMarker(str, arg, i)
    return

  colorize(str).trim()
module.exports = exports = search
npm = require("./npm.js")
registry = npm.registry
columnify = require("columnify")
mapToRegistry = require("./utils/map-to-registry.js")
search.usage = "npm search [some search terms ...]"
search.completion = (opts, cb) ->
  compl = {}
  partial = opts.partialWord
  ipartial = partial.toLowerCase()
  plen = partial.length
  search opts.conf.argv.remain.slice(2), true, (er, data) ->
    return cb(er)  if er
    Object.keys(data).forEach (name) ->
      data[name].words.split(" ").forEach (w) ->
        compl[partial + w.substr(plen)] = true  if w.toLowerCase().indexOf(ipartial) is 0
        return

      return

    cb null, Object.keys(compl)
    return

  return

colors = [
  31
  33
  32
  36
  34
  35
]
cl = colors.length
