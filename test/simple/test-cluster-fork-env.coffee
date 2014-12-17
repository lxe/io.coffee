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
common = require("../common")
assert = require("assert")
cluster = require("cluster")
if cluster.isWorker
  cluster.worker.send
    prop: process.env["cluster_test_prop"]
    overwrite: process.env["cluster_test_overwrite"]

else if cluster.isMaster
  checks =
    using: false
    overwrite: false

  
  # To check that the cluster extend on the process.env we will overwrite a
  # property
  process.env["cluster_test_overwrite"] = "old"
  
  # Fork worker
  worker = cluster.fork(
    cluster_test_prop: "custom"
    cluster_test_overwrite: "new"
  )
  
  # Checks worker env
  worker.on "message", (data) ->
    checks.using = (data.prop is "custom")
    checks.overwrite = (data.overwrite is "new")
    process.exit 0
    return

  process.once "exit", ->
    assert.ok checks.using, "The worker did not receive the correct env."
    assert.ok checks.overwrite, "The custom environment did not overwrite " + "the existing environment."
    return

