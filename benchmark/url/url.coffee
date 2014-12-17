main = (conf) ->
  type = conf.type
  n = conf.n | 0
  inputs =
    one: "http://nodejs.org/docs/latest/api/url.html#url_url_format_urlobj"
    two: "http://blog.nodejs.org/"
    three: "https://encrypted.google.com/search?q=url&q=site:npmjs.org&hl=en"
    four: "javascript:alert(\"node is awesome\");"
    five: "some.ran/dom/url.thing?oh=yes#whoo"
    six: "https://user:pass@example.com/"

  input = inputs[type] or ""
  bench.start()
  i = 0

  while i < n
    url.parse input
    i += 1
  bench.end n
  return
common = require("../common.js")
url = require("url")
bench = common.createBenchmark(main,
  type: "one two three four five six".split(" ")
  n: [25e4]
)
