a = require("./node_modules/glob/node_modules/minimatch/package.json")
e = require("./minimatch-expected.json")
assert = require("assert")
assert.deepEqual a, e, "didn't get expected minimatch/package.json"
