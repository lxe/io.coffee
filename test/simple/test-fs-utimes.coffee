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
stat_resource = (resource) ->
  if typeof resource is "string"
    fs.statSync resource
  else
    
    # ensure mtime has been written to disk
    fs.fsyncSync resource
    fs.fstatSync resource
check_mtime = (resource, mtime) ->
  mtime = fs._toUnixTimestamp(mtime)
  stats = stat_resource(resource)
  real_mtime = fs._toUnixTimestamp(stats.mtime)
  
  # check up to single-second precision
  # sub-second precision is OS and fs dependant
  Math.floor(mtime) is Math.floor(real_mtime)
expect_errno = (syscall, resource, err, errno) ->
  if err and (err.code is errno or err.code is "ENOSYS")
    tests_ok++
  else
    console.log "FAILED:", arguments.callee.name, util.inspect(arguments)
  return
expect_ok = (syscall, resource, err, atime, mtime) ->
  if not err and check_mtime(resource, mtime) or err and err.code is "ENOSYS"
    tests_ok++
  else
    console.log "FAILED:", arguments.callee.name, util.inspect(arguments)
  return

# the tests assume that __filename belongs to the user running the tests
# this should be a fairly safe assumption; testing against a temp file
# would be even better though (node doesn't have such functionality yet)
runTest = (atime, mtime, callback) ->
  
  #
  # test synchronized code paths, these functions throw on failure
  #
  syncTests = ->
    fs.utimesSync __filename, atime, mtime
    expect_ok "utimesSync", __filename, `undefined`, atime, mtime
    tests_run++
    
    # some systems don't have futimes
    # if there's an error, it should be ENOSYS
    try
      tests_run++
      fs.futimesSync fd, atime, mtime
      expect_ok "futimesSync", fd, `undefined`, atime, mtime
    catch ex
      expect_errno "futimesSync", fd, ex, "ENOSYS"
    err = undefined
    err = `undefined`
    try
      fs.utimesSync "foobarbaz", atime, mtime
    catch ex
      err = ex
    expect_errno "utimesSync", "foobarbaz", err, "ENOENT"
    tests_run++
    err = `undefined`
    try
      fs.futimesSync -1, atime, mtime
    catch ex
      err = ex
    expect_errno "futimesSync", -1, err, "EBADF"
    tests_run++
    return
  fd = undefined
  err = undefined
  
  #
  # test async code paths
  #
  fs.utimes __filename, atime, mtime, (err) ->
    expect_ok "utimes", __filename, err, atime, mtime
    fs.utimes "foobarbaz", atime, mtime, (err) ->
      expect_errno "utimes", "foobarbaz", err, "ENOENT"
      
      # don't close this fd
      if is_windows
        fd = fs.openSync(__filename, "r+")
      else
        fd = fs.openSync(__filename, "r")
      fs.futimes fd, atime, mtime, (err) ->
        expect_ok "futimes", fd, err, atime, mtime
        fs.futimes -1, atime, mtime, (err) ->
          expect_errno "futimes", -1, err, "EBADF"
          syncTests()
          callback()
          return

        tests_run++
        return

      tests_run++
      return

    tests_run++
    return

  tests_run++
  return
common = require("../common")
assert = require("assert")
util = require("util")
fs = require("fs")
is_windows = process.platform is "win32"
tests_ok = 0
tests_run = 0
stats = fs.statSync(__filename)
runTest new Date("1982-09-10 13:37"), new Date("1982-09-10 13:37"), ->
  runTest new Date(), new Date(), ->
    runTest 123456.789, 123456.789, ->
      runTest stats.mtime, stats.mtime, ->

      return

    return

  return


# done
process.on "exit", ->
  console.log "Tests run / ok:", tests_run, "/", tests_ok
  assert.equal tests_ok, tests_run
  return

