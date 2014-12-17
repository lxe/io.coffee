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

# something like "C:\\"

# On Windows, creating symlinks requires admin privileges.
# We'll only try to run symlink test if we have enough privileges.

# better safe than sorry
tmp = (p) ->
  path.join common.tmpDir, p
asynctest = (testBlock, args, callback, assertBlock) ->
  async_expected++
  testBlock.apply testBlock, args.concat((err) ->
    ignoreError = false
    if assertBlock
      try
        ignoreError = assertBlock.apply(assertBlock, arguments)
      catch e
        err = e
    async_completed++
    callback (if ignoreError then null else err)
    return
  )
  return

# sub-tests:
test_simple_error_callback = (cb) ->
  ncalls = 0
  fs.realpath "/this/path/does/not/exist", (err, s) ->
    assert err
    assert not s
    ncalls++
    cb()
    return

  process.on "exit", ->
    assert.equal ncalls, 1
    return

  return
test_simple_relative_symlink = (callback) ->
  console.log "test_simple_relative_symlink"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  entry = common.tmpDir + "/symlink"
  expected = common.tmpDir + "/cycles/root.js"
  [[
    entry
    "../tmp/cycles/root.js"
  ]].forEach (t) ->
    try
      fs.unlinkSync t[0]
    console.log "fs.symlinkSync(%j, %j, %j)", t[1], t[0], "file"
    fs.symlinkSync t[1], t[0], "file"
    unlink.push t[0]
    return

  result = fs.realpathSync(entry)
  assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(expected)
    return

  return
test_simple_absolute_symlink = (callback) ->
  console.log "test_simple_absolute_symlink"
  
  # this one should still run, even if skipSymlinks is set,
  # because it uses a junction.
  type = (if skipSymlinks then "junction" else "dir")
  console.log "using type=%s", type
  entry = tmpAbsDir + "/symlink"
  expected = fixturesAbsDir + "/nested-index/one"
  [[
    entry
    expected
  ]].forEach (t) ->
    try
      fs.unlinkSync t[0]
    console.error "fs.symlinkSync(%j, %j, %j)", t[1], t[0], type
    fs.symlinkSync t[1], t[0], type
    unlink.push t[0]
    return

  result = fs.realpathSync(entry)
  assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(expected)
    return

  return
test_deep_relative_file_symlink = (callback) ->
  console.log "test_deep_relative_file_symlink"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  expected = path.join(common.fixturesDir, "cycles", "root.js")
  linkData1 = "../../cycles/root.js"
  linkPath1 = path.join(common.fixturesDir, "nested-index", "one", "symlink1.js")
  try
    fs.unlinkSync linkPath1
  fs.symlinkSync linkData1, linkPath1, "file"
  linkData2 = "../one/symlink1.js"
  entry = path.join(common.fixturesDir, "nested-index", "two", "symlink1-b.js")
  try
    fs.unlinkSync entry
  fs.symlinkSync linkData2, entry, "file"
  unlink.push linkPath1
  unlink.push entry
  assert.equal fs.realpathSync(entry), path.resolve(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(path.resolve(expected))
    return

  return
test_deep_relative_dir_symlink = (callback) ->
  console.log "test_deep_relative_dir_symlink"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  expected = path.join(common.fixturesDir, "cycles", "folder")
  linkData1b = "../../cycles/folder"
  linkPath1b = path.join(common.fixturesDir, "nested-index", "one", "symlink1-dir")
  try
    fs.unlinkSync linkPath1b
  fs.symlinkSync linkData1b, linkPath1b, "dir"
  linkData2b = "../one/symlink1-dir"
  entry = path.join(common.fixturesDir, "nested-index", "two", "symlink12-dir")
  try
    fs.unlinkSync entry
  fs.symlinkSync linkData2b, entry, "dir"
  unlink.push linkPath1b
  unlink.push entry
  assert.equal fs.realpathSync(entry), path.resolve(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(path.resolve(expected))
    return

  return
test_cyclic_link_protection = (callback) ->
  console.log "test_cyclic_link_protection"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  entry = common.tmpDir + "/cycles/realpath-3a"
  [
    [
      entry
      "../cycles/realpath-3b"
    ]
    [
      common.tmpDir + "/cycles/realpath-3b"
      "../cycles/realpath-3c"
    ]
    [
      common.tmpDir + "/cycles/realpath-3c"
      "../cycles/realpath-3a"
    ]
  ].forEach (t) ->
    try
      fs.unlinkSync t[0]
    fs.symlinkSync t[1], t[0], "dir"
    unlink.push t[0]
    return

  assert.throws ->
    fs.realpathSync entry
    return

  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.ok err and true
    true

  return
test_cyclic_link_overprotection = (callback) ->
  console.log "test_cyclic_link_overprotection"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  cycles = common.tmpDir + "/cycles"
  expected = fs.realpathSync(cycles)
  folder = cycles + "/folder"
  link = folder + "/cycles"
  testPath = cycles
  i = 0

  while i < 10
    testPath += "/folder/cycles"
    i++
  try
    fs.unlinkSync link
  fs.symlinkSync cycles, link, "dir"
  unlink.push link
  assert.equal fs.realpathSync(testPath), path.resolve(expected)
  asynctest fs.realpath, [testPath], callback, (er, res) ->
    assert.equal res, path.resolve(expected)
    return

  return
test_relative_input_cwd = (callback) ->
  console.log "test_relative_input_cwd"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  
  # we need to get the relative path to the tmp dir from cwd.
  # When the test runner is running it, that will be .../node/test
  # but it's more common to run `./node test/.../`, so detect it here.
  entrydir = process.cwd()
  entry = common.tmpDir.substr(entrydir.length + 1) + "/cycles/realpath-3a"
  expected = common.tmpDir + "/cycles/root.js"
  [
    [
      entry
      "../cycles/realpath-3b"
    ]
    [
      common.tmpDir + "/cycles/realpath-3b"
      "../cycles/realpath-3c"
    ]
    [
      common.tmpDir + "/cycles/realpath-3c"
      "root.js"
    ]
  ].forEach (t) ->
    fn = t[0]
    console.error "fn=%j", fn
    try
      fs.unlinkSync fn
    b = path.basename(t[1])
    type = ((if b is "root.js" then "file" else "dir"))
    console.log "fs.symlinkSync(%j, %j, %j)", t[1], fn, type
    fs.symlinkSync t[1], fn, "file"
    unlink.push fn
    return

  origcwd = process.cwd()
  process.chdir entrydir
  assert.equal fs.realpathSync(entry), path.resolve(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    process.chdir origcwd
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(path.resolve(expected))
    true

  return
test_deep_symlink_mix = (callback) ->
  console.log "test_deep_symlink_mix"
  if isWindows
    
    # This one is a mix of files and directories, and it's quite tricky
    # to get the file/dir links sorted out correctly.
    console.log "skipping symlink test (no way to work on windows)"
    return runNextTest()
  
  # todo: check to see that common.fixturesDir is not rooted in the
  #       same directory as our test symlink.
  #
  #  /tmp/node-test-realpath-f1 -> ../tmp/node-test-realpath-d1/foo
  #  /tmp/node-test-realpath-d1 -> ../node-test-realpath-d2
  #  /tmp/node-test-realpath-d2/foo -> ../node-test-realpath-f2
  #  /tmp/node-test-realpath-f2
  #    -> /node/test/fixtures/nested-index/one/realpath-c
  #  /node/test/fixtures/nested-index/one/realpath-c
  #    -> /node/test/fixtures/nested-index/two/realpath-c
  #  /node/test/fixtures/nested-index/two/realpath-c -> ../../cycles/root.js
  #  /node/test/fixtures/cycles/root.js (hard)
  #  
  entry = tmp("node-test-realpath-f1")
  try
    fs.unlinkSync tmp("node-test-realpath-d2/foo")
  try
    fs.rmdirSync tmp("node-test-realpath-d2")
  fs.mkdirSync tmp("node-test-realpath-d2"), 0700
  try
    [
      [
        entry
        "../tmp/node-test-realpath-d1/foo"
      ]
      [
        tmp("node-test-realpath-d1")
        "../tmp/node-test-realpath-d2"
      ]
      [
        tmp("node-test-realpath-d2/foo")
        "../node-test-realpath-f2"
      ]
      [
        tmp("node-test-realpath-f2")
        fixturesAbsDir + "/nested-index/one/realpath-c"
      ]
      [
        fixturesAbsDir + "/nested-index/one/realpath-c"
        fixturesAbsDir + "/nested-index/two/realpath-c"
      ]
      [
        fixturesAbsDir + "/nested-index/two/realpath-c"
        "../../../tmp/cycles/root.js"
      ]
    ].forEach (t) ->
      
      #common.debug('setting up '+t[0]+' -> '+t[1]);
      try
        fs.unlinkSync t[0]
      fs.symlinkSync t[1], t[0]
      unlink.push t[0]
      return

  finally
    unlink.push tmp("node-test-realpath-d2")
  expected = tmpAbsDir + "/cycles/root.js"
  assert.equal fs.realpathSync(entry), path.resolve(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(path.resolve(expected))
    true

  return
test_non_symlinks = (callback) ->
  console.log "test_non_symlinks"
  entrydir = path.dirname(tmpAbsDir)
  entry = tmpAbsDir.substr(entrydir.length + 1) + "/cycles/root.js"
  expected = tmpAbsDir + "/cycles/root.js"
  origcwd = process.cwd()
  process.chdir entrydir
  assert.equal fs.realpathSync(entry), path.resolve(expected)
  asynctest fs.realpath, [entry], callback, (err, result) ->
    process.chdir origcwd
    assert.equal result, path.resolve(expected), "got " + common.inspect(result) + " expected " + common.inspect(path.resolve(expected))
    true

  return
test_escape_cwd = (cb) ->
  console.log "test_escape_cwd"
  asynctest fs.realpath, [".."], cb, (er, uponeActual) ->
    assert.equal upone, uponeActual, "realpath(\"..\") expected: " + path.resolve(upone) + " actual:" + uponeActual
    return

  return

# going up with .. multiple times
# .
# `-- a/
#     |-- b/
#     |   `-- e -> ..
#     `-- d -> ..
# realpath(a/b/e/d/a/b/e/d/a) ==> a
test_up_multiple = (cb) ->
  cleanup = ->
    [
      "a/b"
      "a"
    ].forEach (folder) ->
      try
        fs.rmdirSync tmp(folder)
      return

    return
  setup = ->
    cleanup()
    return
  console.error "test_up_multiple"
  if skipSymlinks
    console.log "skipping symlink test (no privs)"
    return runNextTest()
  setup()
  fs.mkdirSync tmp("a"), 0755
  fs.mkdirSync tmp("a/b"), 0755
  fs.symlinkSync "..", tmp("a/d"), "dir"
  unlink.push tmp("a/d")
  fs.symlinkSync "..", tmp("a/b/e"), "dir"
  unlink.push tmp("a/b/e")
  abedabed = tmp("abedabed".split("").join("/"))
  abedabed_real = tmp("")
  abedabeda = tmp("abedabeda".split("").join("/"))
  abedabeda_real = tmp("a")
  assert.equal fs.realpathSync(abedabeda), abedabeda_real
  assert.equal fs.realpathSync(abedabed), abedabed_real
  fs.realpath abedabeda, (er, real) ->
    throw er  if er
    assert.equal abedabeda_real, real
    fs.realpath abedabed, (er, real) ->
      throw er  if er
      assert.equal abedabed_real, real
      cb()
      cleanup()
      return

    return

  return

# absolute symlinks with children.
# .
# `-- a/
#     |-- b/
#     |   `-- c/
#     |       `-- x.txt
#     `-- link -> /tmp/node-test-realpath-abs-kids/a/b/
# realpath(root+'/a/link/c/x.txt') ==> root+'/a/b/c/x.txt'
test_abs_with_kids = (cb) ->
  
  # this one should still run, even if skipSymlinks is set,
  # because it uses a junction.
  cleanup = ->
    [
      "/a/b/c/x.txt"
      "/a/link"
    ].forEach (file) ->
      try
        fs.unlinkSync root + file
      return

    [
      "/a/b/c"
      "/a/b"
      "/a"
      ""
    ].forEach (folder) ->
      try
        fs.rmdirSync root + folder
      return

    return
  setup = ->
    cleanup()
    [
      ""
      "/a"
      "/a/b"
      "/a/b/c"
    ].forEach (folder) ->
      console.log "mkdir " + root + folder
      fs.mkdirSync root + folder, 0700
      return

    fs.writeFileSync root + "/a/b/c/x.txt", "foo"
    fs.symlinkSync root + "/a/b", root + "/a/link", type
    return
  console.log "test_abs_with_kids"
  type = (if skipSymlinks then "junction" else "dir")
  console.log "using type=%s", type
  root = tmpAbsDir + "/node-test-realpath-abs-kids"
  setup()
  linkPath = root + "/a/link/c/x.txt"
  expectPath = root + "/a/b/c/x.txt"
  actual = fs.realpathSync(linkPath)
  
  # console.log({link:linkPath,expect:expectPath,actual:actual},'sync');
  assert.equal actual, path.resolve(expectPath)
  asynctest fs.realpath, [linkPath], cb, (er, actual) ->
    
    # console.log({link:linkPath,expect:expectPath,actual:actual},'async');
    assert.equal actual, path.resolve(expectPath)
    cleanup()
    return

  return
test_lying_cache_liar = (cb) ->
  n = 2
  
  # this should not require *any* stat calls, since everything
  # checked by realpath will be found in the cache.
  console.log "test_lying_cache_liar"
  cache =
    "/foo/bar/baz/bluff": "/foo/bar/bluff"
    "/1/2/3/4/5/6/7": "/1"
    "/a": "/a"
    "/a/b": "/a/b"
    "/a/b/c": "/a/b"
    "/a/b/d": "/a/b/d"

  if isWindows
    wc = {}
    Object.keys(cache).forEach (k) ->
      wc[path.resolve(k)] = path.resolve(cache[k])
      return

    cache = wc
  bluff = path.resolve("/foo/bar/baz/bluff")
  rps = fs.realpathSync(bluff, cache)
  assert.equal cache[bluff], rps
  nums = path.resolve("/1/2/3/4/5/6/7")
  called = false # no sync cb calling!
  fs.realpath nums, cache, (er, rp) ->
    called = true
    assert.equal cache[nums], rp
    cb()  if --n is 0
    return

  assert called is false
  test = path.resolve("/a/b/c/d")
  expect = path.resolve("/a/b/d")
  actual = fs.realpathSync(test, cache)
  assert.equal expect, actual
  fs.realpath test, cache, (er, actual) ->
    assert.equal expect, actual
    cb()  if --n is 0
    return

  return

# ----------------------------------------------------------------------------
runNextTest = (err) ->
  throw err  if err
  test = tests.shift()
  return console.log(numtests + " subtests completed OK for fs.realpath")  unless test
  testsRun++
  test runNextTest
  return
runTest = ->
  tmpDirs = [
    "cycles"
    "cycles/folder"
  ]
  tmpDirs.forEach (t) ->
    t = tmp(t)
    s = undefined
    try
      s = fs.statSync(t)
    return  if s
    fs.mkdirSync t, 0700
    return

  fs.writeFileSync tmp("cycles/root.js"), "console.error('roooot!');"
  console.error "start tests"
  runNextTest()
  return
common = require("../common")
assert = require("assert")
fs = require("fs")
path = require("path")
exec = require("child_process").exec
async_completed = 0
async_expected = 0
unlink = []
isWindows = process.platform is "win32"
skipSymlinks = false
root = "/"
if isWindows
  root = process.cwd().substr(0, 3)
  try
    exec "whoami /priv", (err, o) ->
      skipSymlinks = true  if err or o.indexOf("SeCreateSymbolicLinkPrivilege") is -1
      runTest()
      return

  catch er
    skipSymlinks = true
    process.nextTick runTest
else
  process.nextTick runTest
fixturesAbsDir = common.fixturesDir
tmpAbsDir = common.tmpDir
console.error "absolutes\n%s\n%s", fixturesAbsDir, tmpAbsDir
upone = path.join(process.cwd(), "..")
uponeActual = fs.realpathSync("..")
assert.equal upone, uponeActual, "realpathSync(\"..\") expected: " + path.resolve(upone) + " actual:" + uponeActual
tests = [
  test_simple_error_callback
  test_simple_relative_symlink
  test_simple_absolute_symlink
  test_deep_relative_file_symlink
  test_deep_relative_dir_symlink
  test_cyclic_link_protection
  test_cyclic_link_overprotection
  test_relative_input_cwd
  test_deep_symlink_mix
  test_non_symlinks
  test_escape_cwd
  test_abs_with_kids
  test_lying_cache_liar
  test_up_multiple
]
numtests = tests.length
testsRun = 0
assert.equal root, fs.realpathSync("/")
fs.realpath "/", (err, result) ->
  assert.equal null, err
  assert.equal root, result
  return

process.on "exit", ->
  assert.equal numtests, testsRun
  unlink.forEach (path) ->
    try
      fs.unlinkSync path
    return

  assert.equal async_completed, async_expected
  return

