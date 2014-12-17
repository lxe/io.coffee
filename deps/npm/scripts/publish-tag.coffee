semver = require("semver")
version = semver.parse(require("../package.json").version)
console.log "v%s.%s-next", version.major, version.minor
