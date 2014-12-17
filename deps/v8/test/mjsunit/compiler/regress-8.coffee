# Copyright 2010 the V8 project authors. All rights reserved.
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

# Regression test for the register allocator.
O = ->
  @append = (a, b, c, d, e) ->
    a + b + c + d + e

  return
Nob = (b, a) ->
  c = undefined
  if b is 2
    c = new O
    c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + (zE + (AE + (LA + (a.total + Gob))))))))), p
    c = c.toString()
  else
    if b is 1
      if a.total >= 2e6
        c = new O
        c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + Hob))))), p
        c = c.toString()
      else
        if a.total >= 2e5
          c = new O
          c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + Iob))))), p
          c = c.toString()
        else
          if a.total >= 2e4
            c = new O
            c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + Job))))), p
            c = c.toString()
          else
            if a.total >= 2e3
              c = new O
              c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + Kob))))), p
              c = c.toString()
            else
              if a.total >= 200
                c = new O
                c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + Lob))))), p
                c = c.toString()
              else
                c = new O
                c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + (zE + (Mob + (LA + (a.total + zE))))))))), p
                c = c.toString()
              c = c
            c = c
          c = c
        c = c
      c = c
    else
      c = new O
      c.append gp, yE, W, LA + (a.Un + (zE + (Fp + (LA + (a.Im + (zE + (AE + (LA + (a.total + zE))))))))), p
      c = c.toString()
    c = c
  c
gp = ""
yE = ""
W = ""
LA = ""
zE = ""
Fp = ""
AE = ""
Gob = ""
Hob = ""
Iob = ""
Job = ""
Kob = ""
Lob = ""
Mob = ""
p = ""
Nob 2,
  Un: ""
  Im: ""
  total: 42

