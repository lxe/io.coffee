fs = require("fs")
assert = require("assert")
path = require("path")

# sax should be the only dep that ends up installed
dir = path.resolve(__dirname, "node_modules")
assert.deepEqual fs.readdirSync(dir), ["sax"]
assert.equal require("sax/package.json").version, "0.3.5"
