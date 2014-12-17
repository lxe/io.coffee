benchmark = (name, fun) ->
  timestamp = process.hrtime()
  i = 0

  while i < n
    j = 0
    k = urls.length

    while j < k
      fun urls[j]
      ++j
    ++i
  timestamp = process.hrtime(timestamp)
  seconds = timestamp[0]
  nanos = timestamp[1]
  time = seconds + nanos / 1e9
  rate = n / time
  console.log "misc/url.js %s: %s", name, rate.toPrecision(5)
  return
url = require("url")
n = 25 * 100
urls = [
  "http://nodejs.org/docs/latest/api/url.html#url_url_format_urlobj"
  "http://blog.nodejs.org/"
  "https://encrypted.google.com/search?q=url&q=site:npmjs.org&hl=en"
  "javascript:alert(\"node is awesome\");"
  "some.ran/dom/url.thing?oh=yes#whoo"
]
paths = [
  "../foo/bar?baz=boom"
  "foo/bar"
  "http://nodejs.org"
  "./foo/bar?baz"
]
benchmark "parse()", url.parse
benchmark "format()", url.format
paths.forEach (p) ->
  benchmark "resolve(\"" + p + "\")", (u) ->
    url.resolve u, p
    return

  return

