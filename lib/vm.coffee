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
"use strict"
binding = process.binding("contextify")
Script = binding.ContextifyScript
util = require("util")

# The binding provides a few useful primitives:
# - ContextifyScript(code, { filename = "evalmachine.anonymous",
#                            displayErrors = true } = {})
#   with methods:
#   - runInThisContext({ displayErrors = true } = {})
#   - runInContext(sandbox, { displayErrors = true, timeout = undefined } = {})
# - makeContext(sandbox)
# - isContext(sandbox)
# From this we build the entire documented API.
Script::runInNewContext = (sandbox, options) ->
  context = exports.createContext(sandbox)
  @runInContext context, options

exports.Script = Script
exports.createScript = (code, options) ->
  new Script(code, options)

exports.createContext = (sandbox) ->
  if util.isUndefined(sandbox)
    sandbox = {}
  else return sandbox  if binding.isContext(sandbox)
  binding.makeContext sandbox
  sandbox

exports.runInDebugContext = (code) ->
  binding.runInDebugContext code

exports.runInContext = (code, contextifiedSandbox, options) ->
  script = new Script(code, options)
  script.runInContext contextifiedSandbox, options

exports.runInNewContext = (code, sandbox, options) ->
  script = new Script(code, options)
  script.runInNewContext sandbox, options

exports.runInThisContext = (code, options) ->
  script = new Script(code, options)
  script.runInThisContext options

exports.isContext = binding.isContext
