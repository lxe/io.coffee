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
x = 0
f 0, 0
x = 1
f 0, 0
f 1, 1
x = 2
f 0, 0
f 2, 1
f 4, 2
x = 3
f 0, 0
f 3, 1
f 6, 2
f 9, 3
x = 4
f 0, 0
f 4, 1
f 8, 2
f 12, 3
f 16, 4
x = 5
f 0, 0
f 5, 1
f 10, 2
f 15, 3
f 20, 4
f 25, 5
x = 7
f 0, 0
f 7, 1
f 14, 2
f 21, 3
f 28, 4
f 35, 5
f 49, 7
x = 8
f 0, 0
f 8, 1
f 16, 2
f 24, 3
f 32, 4
f 40, 5
f 56, 7
f 64, 8
x = 9
f 0, 0
f 9, 1
f 18, 2
f 27, 3
f 36, 4
f 45, 5
f 63, 7
f 72, 8
f 81, 9
x = 15
f 0, 0
f 15, 1
f 30, 2
f 45, 3
f 60, 4
f 75, 5
f 105, 7
f 120, 8
f 135, 9
f 225, 15
x = 16
f 0, 0
f 16, 1
f 32, 2
f 48, 3
f 64, 4
f 80, 5
f 112, 7
f 128, 8
f 144, 9
f 240, 15
f 256, 16
x = 17
f 0, 0
f 17, 1
f 34, 2
f 51, 3
f 68, 4
f 85, 5
f 119, 7
f 136, 8
f 153, 9
f 255, 15
f 272, 16
f 289, 17
x = 31
f 0, 0
f 31, 1
f 62, 2
f 93, 3
f 124, 4
f 155, 5
f 217, 7
f 248, 8
f 279, 9
f 465, 15
f 496, 16
f 527, 17
f 961, 31
x = 32
f 0, 0
f 32, 1
f 64, 2
f 96, 3
f 128, 4
f 160, 5
f 224, 7
f 256, 8
f 288, 9
f 480, 15
f 512, 16
f 544, 17
f 992, 31
f 1024, 32
x = 33
f 0, 0
f 33, 1
f 66, 2
f 99, 3
f 132, 4
f 165, 5
f 231, 7
f 264, 8
f 297, 9
f 495, 15
f 528, 16
f 561, 17
f 1023, 31
f 1056, 32
f 1089, 33
x = 63
f 0, 0
f 63, 1
f 126, 2
f 189, 3
f 252, 4
f 315, 5
f 441, 7
f 504, 8
f 567, 9
f 945, 15
f 1008, 16
f 1071, 17
f 1953, 31
f 2016, 32
f 2079, 33
f 3969, 63
x = 64
f 0, 0
f 64, 1
f 128, 2
f 192, 3
f 256, 4
f 320, 5
f 448, 7
f 512, 8
f 576, 9
f 960, 15
f 1024, 16
f 1088, 17
f 1984, 31
f 2048, 32
f 2112, 33
f 4032, 63
f 4096, 64
x = 65
f 0, 0
f 65, 1
f 130, 2
f 195, 3
f 260, 4
f 325, 5
f 455, 7
f 520, 8
f 585, 9
f 975, 15
f 1040, 16
f 1105, 17
f 2015, 31
f 2080, 32
f 2145, 33
f 4095, 63
f 4160, 64
f 4225, 65
x = 127
f 0, 0
f 127, 1
f 254, 2
f 381, 3
f 508, 4
f 635, 5
f 889, 7
f 1016, 8
f 1143, 9
f 1905, 15
f 2032, 16
f 2159, 17
f 3937, 31
f 4064, 32
f 4191, 33
f 8001, 63
f 8128, 64
f 8255, 65
f 16129, 127
x = 128
f 0, 0
f 128, 1
f 256, 2
f 384, 3
f 512, 4
f 640, 5
f 896, 7
f 1024, 8
f 1152, 9
f 1920, 15
f 2048, 16
f 2176, 17
f 3968, 31
f 4096, 32
f 4224, 33
f 8064, 63
f 8192, 64
f 8320, 65
f 16256, 127
f 16384, 128
x = 129
f 0, 0
f 129, 1
f 258, 2
f 387, 3
f 516, 4
f 645, 5
f 903, 7
f 1032, 8
f 1161, 9
f 1935, 15
f 2064, 16
f 2193, 17
f 3999, 31
f 4128, 32
f 4257, 33
f 8127, 63
f 8256, 64
f 8385, 65
f 16383, 127
f 16512, 128
f 16641, 129
x = 255
f 0, 0
f 255, 1
f 510, 2
f 765, 3
f 1020, 4
f 1275, 5
f 1785, 7
f 2040, 8
f 2295, 9
f 3825, 15
f 4080, 16
f 4335, 17
f 7905, 31
f 8160, 32
f 8415, 33
f 16065, 63
f 16320, 64
f 16575, 65
f 32385, 127
f 32640, 128
f 32895, 129
f 65025, 255
x = 256
f 0, 0
f 256, 1
f 512, 2
f 768, 3
f 1024, 4
f 1280, 5
f 1792, 7
f 2048, 8
f 2304, 9
f 3840, 15
f 4096, 16
f 4352, 17
f 7936, 31
f 8192, 32
f 8448, 33
f 16128, 63
f 16384, 64
f 16640, 65
f 32512, 127
f 32768, 128
f 33024, 129
f 65280, 255
f 65536, 256
x = 257
f 0, 0
f 257, 1
f 514, 2
f 771, 3
f 1028, 4
f 1285, 5
f 1799, 7
f 2056, 8
f 2313, 9
f 3855, 15
f 4112, 16
f 4369, 17
f 7967, 31
f 8224, 32
f 8481, 33
f 16191, 63
f 16448, 64
f 16705, 65
f 32639, 127
f 32896, 128
f 33153, 129
f 65535, 255
f 65792, 256
f 66049, 257
x = 511
f 0, 0
f 511, 1
f 1022, 2
f 1533, 3
f 2044, 4
f 2555, 5
f 3577, 7
f 4088, 8
f 4599, 9
f 7665, 15
f 8176, 16
f 8687, 17
f 15841, 31
f 16352, 32
f 16863, 33
f 32193, 63
f 32704, 64
f 33215, 65
f 64897, 127
f 65408, 128
f 65919, 129
f 130305, 255
f 130816, 256
f 131327, 257
f 261121, 511
x = 512
f 0, 0
f 512, 1
f 1024, 2
f 1536, 3
f 2048, 4
f 2560, 5
f 3584, 7
f 4096, 8
f 4608, 9
f 7680, 15
f 8192, 16
f 8704, 17
f 15872, 31
f 16384, 32
f 16896, 33
f 32256, 63
f 32768, 64
f 33280, 65
f 65024, 127
f 65536, 128
f 66048, 129
f 130560, 255
f 131072, 256
f 131584, 257
f 261632, 511
f 262144, 512
x = 513
f 0, 0
f 513, 1
f 1026, 2
f 1539, 3
f 2052, 4
f 2565, 5
f 3591, 7
f 4104, 8
f 4617, 9
f 7695, 15
f 8208, 16
f 8721, 17
f 15903, 31
f 16416, 32
f 16929, 33
f 32319, 63
f 32832, 64
f 33345, 65
f 65151, 127
f 65664, 128
f 66177, 129
f 130815, 255
f 131328, 256
f 131841, 257
f 262143, 511
f 262656, 512
f 263169, 513
x = 1023
f 0, 0
f 1023, 1
f 2046, 2
f 3069, 3
f 4092, 4
f 5115, 5
f 7161, 7
f 8184, 8
f 9207, 9
f 15345, 15
f 16368, 16
f 17391, 17
f 31713, 31
f 32736, 32
f 33759, 33
f 64449, 63
f 65472, 64
f 66495, 65
f 129921, 127
f 130944, 128
f 131967, 129
f 260865, 255
f 261888, 256
f 262911, 257
f 522753, 511
f 523776, 512
f 524799, 513
f 1046529, 1023
