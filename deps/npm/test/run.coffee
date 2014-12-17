# Everything in this file uses child processes, because we're
# testing a command line utility.

# lastly, make sure that we get the same node that is being used to do
# run this script.  That's very important, especially when running this
# test file from in the node source folder.

# the env for all the test installs etc.

# have to set this to false, or it'll try to test itself forever
cleanup = (cb) ->
  if failures isnt 0
    rimraf root, (er) ->
      cb er  if er
      mkdir root, 0755, cb
      return

prefix = (content, pref) ->
  pref + (content.trim().split(/\r?\n/).join("\n" + pref))
exec = (cmd, cwd, shouldFail, cb) ->
  if typeof shouldFail is "function"
    cb = shouldFail
    shouldFail = false
  console.error "\n+" + cmd + ((if shouldFail then " (expect failure)" else ""))
  
  # special: replace 'node' with the current execPath,
  # and 'npm' with the thing we installed.
  cmdShow = cmd
  npmReplace = path.resolve(npmPath, "npm")
  nodeReplace = process.execPath
  if process.platform is "win32"
    npmReplace = "\"" + npmReplace + "\""
    nodeReplace = "\"" + nodeReplace + "\""
  cmd = cmd.replace(/^npm /, npmReplace + " ")
  cmd = cmd.replace(/^node /, nodeReplace + " ")
  console.error "$$$$$$ cd %s; PATH=%s %s", cwd, env.PATH, cmd
  child_process.exec cmd,
    cwd: cwd
    env: env
  , (er, stdout, stderr) ->
    console.error "$$$$$$ after command", cmd, cwd
    console.error prefix(stdout, " 1> ")  if stdout
    console.error prefix(stderr, " 2> ")  if stderr
    execCount++
    if not shouldFail and not er or shouldFail and er
      
      # stdout = (""+stdout).trim()
      console.log "ok " + execCount + " " + cmdShow
      cb()
    else
      console.log "not ok " + execCount + " " + cmdShow
      cb new Error("failed " + cmdShow)
    return

  return
execChain = (cmds, cb) ->
  chain cmds.map((args) ->
    [exec].concat args
  ), cb
  return
flatten = (arr) ->
  arr.reduce ((l, r) ->
    l.concat r
  ), []
setup = (cb) ->
  cleanup (er) ->
    return cb(er)  if er
    execChain [
      [
        "node \"" + npmcli + "\" install \"" + npmpkg + "\""
        root
      ]
      [
        "npm config set package-config:foo boo"
        root
      ]
    ], cb
    return

  return
main = (cb) ->
  
  # get the list of packages
  installAllThenTestAll = ->
    packagesToRm = packages.slice(0)
    
    # Windows can't handle npm rm npm due to file-in-use issues.
    packagesToRm.push "npm"  if process.platform isnt "win32"
    chain [
      setup
      [
        exec
        "npm install " + npmpkg
        testdir
      ]
      [
        execChain
        packages.map((p) ->
          [
            "npm install packages/" + p
            testdir
          ]
        )
      ]
      [
        execChain
        packages.map((p) ->
          [
            "npm test -ddd"
            path.resolve(base, p)
          ]
        )
      ]
      [
        execChain
        packagesToRm.map((p) ->
          [
            "npm rm " + p
            root
          ]
        )
      ]
      installAndTestEach
    ], cb
    return
  installAndTestEach = (cb) ->
    thingsToChain = [
      setup
      [
        execChain
        flatten(packages.map((p) ->
          [
            [
              "npm install packages/" + p
              testdir
            ]
            [
              "npm test"
              path.resolve(base, p)
            ]
            [
              "npm rm " + p
              root
            ]
          ]
        ))
      ]
    ]
    if process.platform isnt "win32"
      
      # Windows can't handle npm rm npm due to file-in-use issues.
      thingsToChain.push [
        exec
        "npm rm npm"
        testdir
      ]
    chain thingsToChain, cb
    return
  console.log "# testing in %s", temp
  console.log "# global prefix = %s", root
  failures = 0
  process.chdir testdir
  base = path.resolve(root, path.join("lib", "node_modules"))
  packages = fs.readdirSync(path.resolve(testdir, "packages"))
  packages = packages.filter((p) ->
    p and not p.match(/^\./)
  )
  installAllThenTestAll()
  return
chain = require("slide").chain
child_process = require("child_process")
path = require("path")
testdir = __dirname
fs = require("graceful-fs")
npmpkg = path.dirname(testdir)
npmcli = path.resolve(npmpkg, "bin", "npm-cli.js")
temp = process.env.TMPDIR or process.env.TMP or process.env.TEMP or ((if process.platform is "win32" then "c:\\windows\\temp" else "/tmp"))
temp = path.resolve(temp, "npm-test-" + process.pid)
root = path.resolve(temp, "root")
failures = 0
mkdir = require("mkdirp")
rimraf = require("rimraf")
pathEnvSplit = (if process.platform is "win32" then ";" else ":")
pathEnv = process.env.PATH.split(pathEnvSplit)
npmPath = (if process.platform is "win32" then root else path.join(root, "bin"))
pathEnv.unshift npmPath, path.join(root, "node_modules", ".bin")
pathEnv.unshift path.dirname(process.execPath)
env = {}
Object.keys(process.env).forEach (i) ->
  env[i] = process.env[i]
  return

env.npm_config_prefix = root
env.npm_config_color = "always"
env.npm_config_global = "true"
env.npm_config_npat = "false"
env.PATH = pathEnv.join(pathEnvSplit)
env.NODE_PATH = path.join(root, "node_modules")
execCount = 0
main (er) ->
  console.log "1.." + execCount
  throw er  if er
  return

