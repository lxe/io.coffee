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

# Converts a number to string respecting -0.
stringify = (n) ->
  return "-0"  if (1 / n) is -Infinity
  String n
f = (expected, y) ->
  testEval = (string, x, y) ->
    mulFunction = Function("x, y", "return " + string)
    mulFunction x, y
  mulTest = (expected, x, y) ->
    assertEquals expected, x * y
    assertEquals expected, testEval(stringify(x) + " * y", x, y)
    assertEquals expected, testEval("x * " + stringify(y), x, y)
    assertEquals expected, testEval(stringify(x) + " * " + stringify(y), x, y)
    return
  mulTest expected, x, y
  mulTest -expected, -x, y
  mulTest -expected, x, -y
  mulTest expected, -x, -y
  return  if x is y # Symmetric cases not necessary.
  mulTest expected, y, x
  mulTest -expected, -y, x
  mulTest -expected, y, -x
  mulTest expected, -y, -x
  return
x = undefined
x = 33554432
f 0, 0
f 33554432, 1
f 67108864, 2
f 100663296, 3
f 134217728, 4
f 167772160, 5
f 234881024, 7
f 268435456, 8
f 301989888, 9
f 503316480, 15
f 536870912, 16
f 570425344, 17
f 1040187392, 31
f 1073741824, 32
f 1107296256, 33
f 2113929216, 63
f 2147483648, 64
f 2181038080, 65
f 4261412864, 127
f 4294967296, 128
f 4328521728, 129
f 8556380160, 255
f 8589934592, 256
f 8623489024, 257
f 17146314752, 511
f 17179869184, 512
f 17213423616, 513
f 34326183936, 1023
f 34359738368, 1024
f 34393292800, 1025
f 68685922304, 2047
f 68719476736, 2048
f 68753031168, 2049
f 137405399040, 4095
f 137438953472, 4096
f 137472507904, 4097
f 274844352512, 8191
f 274877906944, 8192
f 274911461376, 8193
f 549722259456, 16383
f 549755813888, 16384
f 549789368320, 16385
f 1099478073344, 32767
f 1099511627776, 32768
f 1099545182208, 32769
f 2198989701120, 65535
f 2199023255552, 65536
f 2199056809984, 65537
f 4398012956672, 131071
f 4398046511104, 131072
f 4398080065536, 131073
f 8796059467776, 262143
f 8796093022208, 262144
f 8796126576640, 262145
f 17592152489984, 524287
f 17592186044416, 524288
f 17592219598848, 524289
f 35184338534400, 1048575
f 35184372088832, 1048576
f 35184405643264, 1048577
f 70368710623232, 2097151
f 70368744177664, 2097152
f 70368777732096, 2097153
f 140737454800896, 4194303
f 140737488355328, 4194304
f 140737521909760, 4194305
f 281474943156224, 8388607
f 281474976710656, 8388608
f 281475010265088, 8388609
f 562949919866880, 16777215
f 562949953421312, 16777216
f 562949986975744, 16777217
f 1125899873288192, 33554431
f 1125899906842624, 33554432
x = 33554433
f 0, 0
f 33554433, 1
f 67108866, 2
f 100663299, 3
f 134217732, 4
f 167772165, 5
f 234881031, 7
f 268435464, 8
f 301989897, 9
f 503316495, 15
f 536870928, 16
f 570425361, 17
f 1040187423, 31
f 1073741856, 32
f 1107296289, 33
f 2113929279, 63
f 2147483712, 64
f 2181038145, 65
f 4261412991, 127
f 4294967424, 128
f 4328521857, 129
f 8556380415, 255
f 8589934848, 256
f 8623489281, 257
f 17146315263, 511
f 17179869696, 512
f 17213424129, 513
f 34326184959, 1023
f 34359739392, 1024
f 34393293825, 1025
f 68685924351, 2047
f 68719478784, 2048
f 68753033217, 2049
f 137405403135, 4095
f 137438957568, 4096
f 137472512001, 4097
f 274844360703, 8191
f 274877915136, 8192
f 274911469569, 8193
f 549722275839, 16383
f 549755830272, 16384
f 549789384705, 16385
f 1099478106111, 32767
f 1099511660544, 32768
f 1099545214977, 32769
f 2198989766655, 65535
f 2199023321088, 65536
f 2199056875521, 65537
f 4398013087743, 131071
f 4398046642176, 131072
f 4398080196609, 131073
f 8796059729919, 262143
f 8796093284352, 262144
f 8796126838785, 262145
f 17592153014271, 524287
f 17592186568704, 524288
f 17592220123137, 524289
f 35184339582975, 1048575
f 35184373137408, 1048576
f 35184406691841, 1048577
f 70368712720383, 2097151
f 70368746274816, 2097152
f 70368779829249, 2097153
f 140737458995199, 4194303
f 140737492549632, 4194304
f 140737526104065, 4194305
f 281474951544831, 8388607
f 281474985099264, 8388608
f 281475018653697, 8388609
f 562949936644095, 16777215
f 562949970198528, 16777216
f 562950003752961, 16777217
f 1125899906842623, 33554431
f 1125899940397056, 33554432
f 1125899973951489, 33554433
x = 67108863
f 0, 0
f 67108863, 1
f 134217726, 2
f 201326589, 3
f 268435452, 4
f 335544315, 5
f 469762041, 7
f 536870904, 8
f 603979767, 9
f 1006632945, 15
f 1073741808, 16
f 1140850671, 17
f 2080374753, 31
f 2147483616, 32
f 2214592479, 33
f 4227858369, 63
f 4294967232, 64
f 4362076095, 65
f 8522825601, 127
f 8589934464, 128
f 8657043327, 129
f 17112760065, 255
f 17179868928, 256
f 17246977791, 257
f 34292628993, 511
f 34359737856, 512
f 34426846719, 513
f 68652366849, 1023
f 68719475712, 1024
f 68786584575, 1025
f 137371842561, 2047
f 137438951424, 2048
f 137506060287, 2049
f 274810793985, 4095
f 274877902848, 4096
f 274945011711, 4097
f 549688696833, 8191
f 549755805696, 8192
f 549822914559, 8193
f 1099444502529, 16383
f 1099511611392, 16384
f 1099578720255, 16385
f 2198956113921, 32767
f 2199023222784, 32768
f 2199090331647, 32769
f 4397979336705, 65535
f 4398046445568, 65536
f 4398113554431, 65537
f 8796025782273, 131071
f 8796092891136, 131072
f 8796159999999, 131073
f 17592118673409, 262143
f 17592185782272, 262144
f 17592252891135, 262145
f 35184304455681, 524287
f 35184371564544, 524288
f 35184438673407, 524289
f 70368676020225, 1048575
f 70368743129088, 1048576
f 70368810237951, 1048577
f 140737419149313, 2097151
f 140737486258176, 2097152
f 140737553367039, 2097153
f 281474905407489, 4194303
f 281474972516352, 4194304
f 281475039625215, 4194305
f 562949877923841, 8388607
f 562949945032704, 8388608
f 562950012141567, 8388609
f 1125899822956545, 16777215
f 1125899890065408, 16777216
f 1125899957174271, 16777217
x = 67108864
f 0, 0
f 67108864, 1
f 134217728, 2
f 201326592, 3
f 268435456, 4
f 335544320, 5
f 469762048, 7
f 536870912, 8
f 603979776, 9
f 1006632960, 15
f 1073741824, 16
f 1140850688, 17
f 2080374784, 31
f 2147483648, 32
f 2214592512, 33
f 4227858432, 63
f 4294967296, 64
f 4362076160, 65
f 8522825728, 127
f 8589934592, 128
f 8657043456, 129
f 17112760320, 255
f 17179869184, 256
f 17246978048, 257
f 34292629504, 511
f 34359738368, 512
f 34426847232, 513
f 68652367872, 1023
f 68719476736, 1024
f 68786585600, 1025
f 137371844608, 2047
f 137438953472, 2048
f 137506062336, 2049
f 274810798080, 4095
f 274877906944, 4096
f 274945015808, 4097
f 549688705024, 8191
f 549755813888, 8192
f 549822922752, 8193
f 1099444518912, 16383
f 1099511627776, 16384
f 1099578736640, 16385
f 2198956146688, 32767
f 2199023255552, 32768
f 2199090364416, 32769
f 4397979402240, 65535
f 4398046511104, 65536
f 4398113619968, 65537
f 8796025913344, 131071
f 8796093022208, 131072
f 8796160131072, 131073
f 17592118935552, 262143
f 17592186044416, 262144
f 17592253153280, 262145
f 35184304979968, 524287
f 35184372088832, 524288
f 35184439197696, 524289
f 70368677068800, 1048575
f 70368744177664, 1048576
f 70368811286528, 1048577
f 140737421246464, 2097151
f 140737488355328, 2097152
f 140737555464192, 2097153
f 281474909601792, 4194303
f 281474976710656, 4194304
f 281475043819520, 4194305
f 562949886312448, 8388607
f 562949953421312, 8388608
f 562950020530176, 8388609
f 1125899839733760, 16777215
f 1125899906842624, 16777216
f 1125899973951488, 16777217
x = 67108865
f 0, 0
f 67108865, 1
f 134217730, 2
f 201326595, 3
f 268435460, 4
f 335544325, 5
f 469762055, 7
f 536870920, 8
f 603979785, 9
f 1006632975, 15
f 1073741840, 16
f 1140850705, 17
f 2080374815, 31
f 2147483680, 32
f 2214592545, 33
f 4227858495, 63
f 4294967360, 64
f 4362076225, 65
f 8522825855, 127
f 8589934720, 128
f 8657043585, 129
f 17112760575, 255
f 17179869440, 256
f 17246978305, 257
f 34292630015, 511
f 34359738880, 512
f 34426847745, 513
f 68652368895, 1023
f 68719477760, 1024
f 68786586625, 1025
f 137371846655, 2047
f 137438955520, 2048
f 137506064385, 2049
f 274810802175, 4095
f 274877911040, 4096
f 274945019905, 4097
f 549688713215, 8191
f 549755822080, 8192
f 549822930945, 8193
f 1099444535295, 16383
f 1099511644160, 16384
f 1099578753025, 16385
f 2198956179455, 32767
f 2199023288320, 32768
f 2199090397185, 32769
f 4397979467775, 65535
f 4398046576640, 65536
f 4398113685505, 65537
f 8796026044415, 131071
f 8796093153280, 131072
f 8796160262145, 131073
f 17592119197695, 262143
f 17592186306560, 262144
f 17592253415425, 262145
f 35184305504255, 524287
f 35184372613120, 524288
f 35184439721985, 524289
f 70368678117375, 1048575
f 70368745226240, 1048576
f 70368812335105, 1048577
f 140737423343615, 2097151
f 140737490452480, 2097152
f 140737557561345, 2097153
f 281474913796095, 4194303
f 281474980904960, 4194304
f 281475048013825, 4194305
f 562949894701055, 8388607
f 562949961809920, 8388608
f 562950028918785, 8388609
f 1125899856510975, 16777215
f 1125899923619840, 16777216
f 1125899990728705, 16777217
x = 134217727
f 0, 0
f 134217727, 1
f 268435454, 2
f 402653181, 3
f 536870908, 4
f 671088635, 5
f 939524089, 7
f 1073741816, 8
f 1207959543, 9
f 2013265905, 15
f 2147483632, 16
f 2281701359, 17
f 4160749537, 31
f 4294967264, 32
f 4429184991, 33
f 8455716801, 63
f 8589934528, 64
f 8724152255, 65
f 17045651329, 127
f 17179869056, 128
f 17314086783, 129
f 34225520385, 255
f 34359738112, 256
f 34493955839, 257
f 68585258497, 511
f 68719476224, 512
f 68853693951, 513
f 137304734721, 1023
f 137438952448, 1024
f 137573170175, 1025
f 274743687169, 2047
f 274877904896, 2048
f 275012122623, 2049
f 549621592065, 4095
f 549755809792, 4096
f 549890027519, 4097
f 1099377401857, 8191
f 1099511619584, 8192
f 1099645837311, 8193
f 2198889021441, 16383
f 2199023239168, 16384
f 2199157456895, 16385
f 4397912260609, 32767
f 4398046478336, 32768
f 4398180696063, 32769
f 8795958738945, 65535
f 8796092956672, 65536
f 8796227174399, 65537
f 17592051695617, 131071
f 17592185913344, 131072
f 17592320131071, 131073
f 35184237608961, 262143
f 35184371826688, 262144
f 35184506044415, 262145
f 70368609435649, 524287
f 70368743653376, 524288
f 70368877871103, 524289
f 140737353089025, 1048575
f 140737487306752, 1048576
f 140737621524479, 1048577
f 281474840395777, 2097151
f 281474974613504, 2097152
f 281475108831231, 2097153
f 562949815009281, 4194303
f 562949949227008, 4194304
f 562950083444735, 4194305
f 1125899764236289, 8388607
f 1125899898454016, 8388608
f 1125900032671743, 8388609
