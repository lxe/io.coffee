# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
main = (conf) ->
  rmrf tmpDirectory
  try
    fs.mkdirSync tmpDirectory
  try
    fs.mkdirSync benchmarkDirectory
  n = +conf.thousands * 1e3
  i = 0

  while i <= n
    fs.mkdirSync benchmarkDirectory + i
    fs.writeFileSync benchmarkDirectory + i + "/package.json", "{\"main\": \"index.js\"}"
    fs.writeFileSync benchmarkDirectory + i + "/index.js", "module.exports = \"\";"
    i++
  measure n
  return
measure = (n) ->
  bench.start()
  i = 0

  while i <= n
    require benchmarkDirectory + i
    i++
  bench.end n / 1e3
  return
rmrf = (location) ->
  if fs.existsSync(location)
    things = fs.readdirSync(location)
    things.forEach (thing) ->
      cur = path.join(location, thing)
      isDirectory = fs.statSync(cur).isDirectory()
      if isDirectory
        rmrf cur
        return
      fs.unlinkSync cur
      return

    fs.rmdirSync location
  return
fs = require("fs")
path = require("path")
common = require("../common.js")
packageJson = "{\"main\": \"index.js\"}"
tmpDirectory = path.join(__dirname, "..", "tmp")
benchmarkDirectory = path.join(tmpDirectory, "nodejs-benchmark-module")
bench = common.createBenchmark(main,
  thousands: [50]
)
