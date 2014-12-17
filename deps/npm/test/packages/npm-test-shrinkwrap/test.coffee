rmFrom = (obj) ->
  for i of obj
    if i is "from"
      delete obj[i]
    else if i is "dependencies"
      for j of obj[i]
        rmFrom obj[i][j]
  return
path = require("path")
assert = require("assert")
process.env.npm_config_prefix = process.cwd()
delete process.env.npm_config_global

delete process.env.npm_config_depth

npm = process.env.npm_execpath
require("child_process").execFile process.execPath, [
  npm
  "ls"
  "--json"
],
  stdio: "pipe"
  env: process.env
  cwd: process.cwd()
, (err, stdout, stderr) ->
  throw err  if err
  actual = JSON.parse(stdout)
  expected = require("./npm-shrinkwrap.json")
  rmFrom actual
  actual = actual.dependencies
  rmFrom expected
  expected = expected.dependencies
  console.error JSON.stringify(actual, null, 2)
  console.error JSON.stringify(expected, null, 2)
  assert.deepEqual actual, expected
  return

