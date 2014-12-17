# Copyright 2008 the V8 project authors. All rights reserved.
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
assertEquals 0, "\u0000".charCodeAt(0)
assertEquals 1, "\u0001".charCodeAt(0)
assertEquals 2, "\u0002".charCodeAt(0)
assertEquals 3, "\u0003".charCodeAt(0)
assertEquals 4, "\u0004".charCodeAt(0)
assertEquals 5, "\u0005".charCodeAt(0)
assertEquals 6, "\u0006".charCodeAt(0)
assertEquals 7, "\u0007".charCodeAt(0)
assertEquals 56, "8".charCodeAt(0)
assertEquals "\b", "\b"
assertEquals "\t", "\t"
assertEquals "\n", "\n"
assertEquals "\u000b", "\u000b"
assertEquals "\f", "\f"
assertEquals "\r", "\r"
assertEquals "\u000e", "\u000e"
assertEquals "\u000f", "\u000f"
assertEquals "\u0010", "\u0010"
assertEquals "\u0011", "\u0011"
assertEquals "\u0012", "\u0012"
assertEquals "\u0013", "\u0013"
assertEquals "\u0014", "\u0014"
assertEquals "\u0015", "\u0015"
assertEquals "\u0016", "\u0016"
assertEquals "\u0017", "\u0017"
assertEquals 73, "I".charCodeAt(0)
assertEquals 105, "i".charCodeAt(0)
