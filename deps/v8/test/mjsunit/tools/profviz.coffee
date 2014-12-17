# Copyright 2009 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Load implementations from <project root>/tools.
# Files: tools/csvparser.js tools/splaytree.js tools/codemap.js
# Files: tools/consarray.js tools/profile.js tools/profile_view.js
# Files: tools/logreader.js tools/tickprocessor.js
# Files: tools/profviz/composer.js
# Env: TEST_FILE_NAME
input = ->
  content_lines[line_cursor++]
output = (line) ->
  output_lines.push line
  return
set_range = (start, end) ->
  range_start = start
  range_end = end
  return
assertEquals "string", typeof TEST_FILE_NAME
path_length = TEST_FILE_NAME.lastIndexOf("/")
path_length = TEST_FILE_NAME.lastIndexOf("\\")  if path_length is -1
assertTrue path_length isnt -1
path = TEST_FILE_NAME.substr(0, path_length + 1)
input_file = path + "profviz-test.log"
reference_file = path + "profviz-test.default"
content_lines = read(input_file).split("\n")
line_cursor = 0
output_lines = []
distortion = 4500 / 1000000
resx = 1600
resy = 600
psc = new PlotScriptComposer(resx, resy)
psc.collectData input, distortion
psc.findPlotRange `undefined`, `undefined`, set_range
objects = psc.assembleOutput(output)
output "# start: " + range_start
output "# end: " + range_end
output "# objects: " + objects
create_baseline = false
if create_baseline
  print JSON.stringify(output_lines, null, 2)
else
  assertArrayEquals output_lines, JSON.parse(read(reference_file))
