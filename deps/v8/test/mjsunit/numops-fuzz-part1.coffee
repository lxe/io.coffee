# Copyright 2011 the V8 project authors. All rights reserved.
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
f = ->
  x = 0
  tmp = 0
  assertEquals 0, x /= (tmp = 798469700.4090232
  tmp
  )
  assertEquals 0, x *= (2714102322.365509)
  assertEquals 0, x *= x
  assertEquals 139516372, x -= (tmp = -139516372
  tmp
  )
  assertEquals 1, x /= (x % (2620399703.344006))
  assertEquals 0, x >>>= x
  assertEquals -2772151192.8633175, x -= (tmp = 2772151192.8633175
  tmp
  )
  assertEquals -2786298206.8633175, x -= (14147014)
  assertEquals 1509750523, x |= ((1073767916) - (tmp = 919311632.2789925
  tmp
  ))
  assertEquals 2262404051.926751, x += ((752653528.9267509) % x)
  assertEquals -270926893, x |= (tmp = 1837232194
  tmp
  )
  assertEquals 0.17730273401688765, x /= ((tmp = -2657202795
  tmp
  ) - (((((x | (tmp = -1187733892.282897
  tmp
  )) - x) << (556523578)) - x) + (-57905508.42881298)))
  assertEquals 122483.56550261026, x *= ((((tmp = 2570017060.15193
  tmp
  ) % ((-1862621126.9968336) >> x)) >> (x >> (tmp = 2388674677
  tmp
  ))) >>> (-2919657526.470434))
  assertEquals 0, x ^= x
  assertEquals 0, x <<= (tmp = 2705124845.0455265
  tmp
  )
  assertEquals 0, x &= (-135286835.07069612)
  assertEquals -0, x *= ((tmp = -165810479.10020828
  tmp
  ) | x)
  assertEquals 248741888, x += ((735976871.1308595) << (-2608055185.0700903))
  assertEquals 139526144, x &= (tmp = -1454301068
  tmp
  )
  assertEquals -0.047221345672746884, x /= (tmp = -2954726130.994727
  tmp
  )
  assertEquals 0, x <<= (x >> x)
  assertEquals 0, x >>>= ((x + (912111201.488966)) - (tmp = 1405800042.6070075
  tmp
  ))
  assertEquals -1663642733, x |= (((-1663642733.5700119) << (x ^ x)) << x)
  assertEquals -914358272, x <<= ((((-308411676) - (-618261840.9113789)) % (-68488626.58621716)) - x)
  assertEquals -1996488704, x &= (-1358622641.5848842)
  assertEquals -345978263, x += (1650510441)
  assertEquals 3, x >>>= (-1106714178.701668)
  assertEquals 1, x %= (((x >> (x >> (tmp = -3052773846.817114
  tmp
  ))) * (tmp = 1659218887.379526
  tmp
  )) & x)
  assertEquals -943225672, x += (-943225673)
  assertEquals -0.41714300120060854, x /= (tmp = 2261156652
  tmp
  )
  assertEquals 0, x >>>= ((3107060934.8863482) << (tmp = 1902730887
  tmp
  ))
  assertEquals 0, x &= x
  assertEquals 1476628, x |= ((tmp = -2782899841.390033
  tmp
  ) >>> (2097653770))
  assertEquals 0.0008887648921591833, x /= ((tmp = 1661438264.5253348
  tmp
  ) % ((tmp = 2555939813
  tmp
  ) * (-877024323.6515315)))
  assertEquals 0, x <<= (tmp = -2366551345
  tmp
  )
  assertEquals 0, x &= (tmp = 1742843591
  tmp
  )
  assertEquals 0, x -= x
  assertEquals 4239, x += ((-3183564176.232031) >>> (349622674.1255014))
  assertEquals -67560, x -= ((2352742295) >>> x)
  assertEquals -67560, x &= x
  assertEquals -0.00003219917807302283, x /= (2098190203.699741)
  assertEquals 0, x -= x
  assertEquals 0, x >>= ((((tmp = -869086522.8358297
  tmp
  ) / (187820779)) - (tmp = -2000970995.1931965
  tmp
  )) | (1853528755.6064696))
  assertEquals 0, x >>= (-3040509919)
  assertEquals 0, x %= (((tmp = -2386688049.194946
  tmp
  ) << (tmp = -669711391
  tmp
  )) | x)
  assertEquals 0, x %= (tmp = -298431511.4839926
  tmp
  )
  assertEquals 0, x /= (2830845091.2793818)
  assertEquals 0, x /= ((((-2529926178) | x) ^ ((tmp = 2139313707.0894063
  tmp
  ) % ((-1825768525.0541775) - (-952600362.7758243)))) + x)
  assertEquals NaN, x /= x
  assertEquals NaN, x -= x
  assertEquals NaN, x /= (tmp = -432944480
  tmp
  )
  assertEquals 0, x <<= (((((x ^ ((-1777523727) + (2194962794))) >>> (((((-590335134.8224905) % (x * (2198198974))) | (tmp = -2068556796
  tmp
  )) / (1060765637)) * (-147051676))) / ((tmp = -477350113.92686677
  tmp
  ) << ((x / (2018712621.0397925)) ^ ((tmp = 491163813.3921983
  tmp
  ) + (((x | ((((x % (1990073256.812654)) % ((-2024388518.9599915) >> ((tmp = 223182187
  tmp
  ) * (-722241065)))) >>> (tmp = 2517147885.305745
  tmp
  )) % (1189996239.11222))) & x) % (-306932860)))))) & ((tmp = 1117802724.485684
  tmp
  ) + ((-1391614045) - x))) % ((((x >> ((2958453447) * x)) ^ (((410825859) | (((tmp = -1119269292.5495896
  tmp
  ) >>> (((((((x % (tmp = 648541746.6059314
  tmp
  )) * ((-2304508480) << ((((x ^ (1408199888.1454597)) | ((251623937) | x)) / ((-382389946.9984102) | (tmp = -2082681143.5893767
  tmp
  ))) - (((tmp = 631243472
  tmp
  ) >>> (1407556544)) / (((x >>> x) >>> (tmp = -6329025.47865057
  tmp
  )) >>> (tmp = 948664752.543093
  tmp
  )))))) / ((((-183248880) >> x) & x) & x)) >> x) & (((-978737284.8492057) % (tmp = 2983300011.737006
  tmp
  )) & (tmp = 2641937234.2954116
  tmp
  ))) << x) >> (2795416632.9722223))) % ((((tmp = -50926632
  tmp
  ) / x) & (((tmp = -2510786916
  tmp
  ) / x) / (-699755674))) | ((((tmp = 1411792593
  tmp
  ) >> (924286570.2637128)) >> ((1609997725) >> (2735658951.0762663))) * (tmp = 726205435
  tmp
  ))))) << (tmp = -2135055357.3156831
  tmp
  ))) / (tmp = 1408695065
  tmp
  )) ^ (tmp = -1343267739.8562133
  tmp
  )))
  assertEquals 0, x %= (-437232116)
  assertEquals -2463314518.2747326, x -= (2463314518.2747326)
  assertEquals 109, x >>= (2401429560)
  assertEquals -2687641732.0253763, x += (-2687641841.0253763)
  assertEquals -2336375490019484000, x *= (tmp = 869303174.6678596
  tmp
  )
  assertEquals 5.458650430363785e+36, x *= x
  assertEquals 0, x |= ((((-1676972008.797291) * x) * ((tmp = 2606991807
  tmp
  ) - x)) << x)
  assertEquals 0, x &= ((-3053393759.3496876) + (-1431008367))
  assertEquals -856728369, x |= (x - (((((764337872) / x) << ((x | (((tmp = 1409368192.1268077
  tmp
  ) + (tmp = -848083676
  tmp
  )) | (-2797102463.7915916))) ^ x)) / x) ^ (tmp = 856728369.0589117
  tmp
  )))
  assertEquals -0, x %= x
  assertEquals 1116550103, x ^= (-3178417193)
  assertEquals 1116550103, x %= (tmp = -1482481942
  tmp
  )
  assertEquals 133, x >>>= x
  assertEquals -1.381429241671034e-7, x /= ((tmp = -962771116.8101778
  tmp
  ) ^ x)
  assertEquals -1092268961, x |= ((tmp = 3202672531
  tmp
  ) - ((x - (tmp = 845529357
  tmp
  )) >> (tmp = -868680593
  tmp
  )))
  assertEquals -1092268961, x %= (tmp = 2670840415.304719
  tmp
  )
  assertEquals -122794480, x %= (tmp = 969474481
  tmp
  )
  assertEquals -297606521542193600, x *= (2423614820)
  assertEquals 72460064, x >>>= (tmp = -1230798655
  tmp
  )
  assertEquals -203714325373689600, x *= (-2811401400)
  assertEquals 2154914048, x >>>= (((2241377026.001436) / x) + x)
  assertEquals 1177864081, x ^= (tmp = -968513903
  tmp
  )
  assertEquals 35947664, x &= (-2086226758.2704995)
  assertEquals 20795732539020670, x += (x * (578500247))
  assertEquals -892004992, x >>= x
  assertEquals -7023661.354330708, x /= ((((((1740714214) % ((tmp = -459699286
  tmp
  ) + (tmp = -1700187400
  tmp
  ))) >> (tmp = -3170295237
  tmp
  )) + (tmp = -497509780
  tmp
  )) + ((1971976144.6197853) + (661992813.6077721))) >>> (-1683802728))
  assertEquals -1634205696, x <<= x
  assertEquals -7, x >>= (-3187653764.930914)
  assertEquals -5.095345981491203, x -= ((tmp = 748315289
  tmp
  ) / (tmp = -392887780
  tmp
  ))
  assertEquals 1486531570, x &= (1486531570.9300508)
  assertEquals 5670, x >>= (((tmp = -2486758205.26425
  tmp
  ) * (732510414)) | x)
  assertEquals 5670, x >>= (((-1811879946.2553763) % (1797475764)) / (((tmp = -2159923884
  tmp
  ) | x) + (tmp = -1774410807
  tmp
  )))
  assertEquals 38, x %= (x >>> x)
  assertEquals -151134215, x ^= (((tmp = -2593085609.5622163
  tmp
  ) + ((tmp = -814992345.7516887
  tmp
  ) - (534809571))) | (tmp = -232678571
  tmp
  ))
  assertEquals -234881024, x <<= x
  assertEquals -234881024, x <<= (x >>> x)
  assertEquals 55169095435288580, x *= x
  assertEquals 0, x >>= (tmp = 1176612256
  tmp
  )
  assertEquals 0, x <<= (1321866341.2486475)
  assertEquals 0, x %= (x - (-602577995))
  assertEquals 0, x >>>= (((((tmp = -125628635.79970193
  tmp
  ) ^ (tmp = 1294209955.229382
  tmp
  )) & (((tmp = -2353256654.0725203
  tmp
  ) | ((-1136743028.9425385) | ((((950703429.1110399) - (x >>> x)) / ((((x % (-252705869.21126103)) / ((tmp = 886957620
  tmp
  ) << (x % ((tmp = -1952249741
  tmp
  ) * (tmp = -1998149844
  tmp
  ))))) | (tmp = 1933366713
  tmp
  )) | ((tmp = -2957141565
  tmp
  ) >>> (tmp = 1408598804
  tmp
  )))) + (((((((-2455002047.4910946) % (tmp = -528017836
  tmp
  )) & ((-2693432769) / (tmp = 2484427670.9045153
  tmp
  ))) % (-356969659)) - ((((((tmp = 3104828644.0753174
  tmp
  ) % (x >>> (tmp = 820832137.8175925
  tmp
  ))) * ((tmp = 763080553.9260503
  tmp
  ) + (3173597855))) << (((-510785437) ^ x) << (x | (((x * (x % ((tmp = -1391951515
  tmp
  ) / x))) - x) | (x - ((-522681793.93221474) / ((2514619703.2162743) * (2936688324)))))))) | x) >>> (-2093210042))) & (763129279.3651779)) & x)))) - x)) % (((-1331164821) & (tmp = 1342684586
  tmp
  )) << (x << (tmp = 2675008614.588005
  tmp
  )))) >> ((2625292569.8984914) + (-3185992401)))
  assertEquals 0, x *= (tmp = 671817215.1147974
  tmp
  )
  assertEquals -1608821121, x ^= ((tmp = 2686146175.04077
  tmp
  ) >>> x)
  assertEquals -0, x %= x
  assertEquals -0, x /= ((tmp = 286794551.0720866
  tmp
  ) | (x % x))
  assertEquals 0, x <<= (x | (tmp = 1095503996.2285218
  tmp
  ))
  assertEquals 443296752, x ^= (443296752)
  assertEquals 110824188, x >>= ((184708570) >> (x & x))
  assertEquals 0.7908194935161674, x /= ((((167151154.63381648) & ((tmp = -1434120690
  tmp
  ) - (tmp = 2346173080
  tmp
  ))) / (56656051.87305987)) ^ (140138414))
  assertEquals -0.9027245492678485, x *= ((tmp = 1724366578
  tmp
  ) / (((2979477411) << (((897038568) >> (tmp = 348960298
  tmp
  )) % (281056223.2037884))) ^ ((((-1383133388) - (((-1379748375) - ((x >> (x & (tmp = 2456582046
  tmp
  ))) >>> (-2923911755.565961))) & x)) << (-2825791731)) ^ (tmp = -1979992970
  tmp
  ))))
  assertEquals 0, x &= (2482304279)
  assertEquals -0, x *= (-2284213673)
  assertEquals 0, x <<= ((2874381218.015819) | x)
  assertEquals 0, x *= (x >>> (tmp = 2172786480
  tmp
  ))
  assertEquals 0, x &= (-1638727867.2978938)
  assertEquals 0, x %= ((tmp = -2213947368.285817
  tmp
  ) >> x)
  assertEquals 0, x >>>= (tmp = -531324706
  tmp
  )
  assertEquals 0, x %= (tmp = -2338792486
  tmp
  )
  assertEquals 0, x <<= (((tmp = 351012164
  tmp
  ) << (x | ((tmp = -3023836638.5337825
  tmp
  ) ^ (-2678806692)))) | x)
  assertEquals 0, x %= (x - (tmp = -3220231305.45039
  tmp
  ))
  assertEquals 0, x <<= (-2132833261)
  assertEquals 0, x >>>= x
  assertEquals 0, x %= ((2544970469) + (((-2633093458.5911965) & (644108176)) - (x >>> (tmp = -949043718
  tmp
  ))))
  assertEquals -2750531265, x += (-2750531265)
  assertEquals 0, x >>= x
  assertEquals 0, x *= ((tmp = 1299005700
  tmp
  ) - x)
  assertEquals 0, x >>= x
  assertEquals -1785515304, x -= (((((-806054462.5563161) / x) >>> x) + (1785515304)) | ((tmp = 2937069788.9396844
  tmp
  ) / x))
  assertEquals -3810117159.173689, x -= (2024601855.1736891)
  assertEquals -6.276064139320051, x /= (607087033.3053156)
  assertEquals 134217727, x >>>= (((x % (tmp = 924293127
  tmp
  )) ^ x) | ((x >>> (x & ((((tmp = -413386639
  tmp
  ) / (x >> (tmp = 599075308.8479941
  tmp
  ))) ^ (tmp = -1076703198
  tmp
  )) * ((tmp = -2239117284
  tmp
  ) >> (655036983))))) - x))
  assertEquals 134217727, x %= (tmp = 2452642261.038778
  tmp
  )
  assertEquals -569504740360507, x *= ((tmp = -1086243941
  tmp
  ) >> (tmp = 1850668904.4885683
  tmp
  ))
  assertEquals 113378806, x >>>= (tmp = -2558233435
  tmp
  )
  assertEquals 979264375, x -= (((x >> (1950008052)) % ((2917183569.0209) * (tmp = 1184250640.446752
  tmp
  ))) | ((((tmp = -691875212
  tmp
  ) - (-2872881803)) >> (tmp = 44162204.97461021
  tmp
  )) ^ (tmp = 865885647
  tmp
  )))
  assertEquals -1127813632, x <<= ((((tmp = -2210499281
  tmp
  ) >>> x) - (tmp = 2359697240
  tmp
  )) - x)
  assertEquals -1707799657, x ^= (653518231.3995534)
  assertEquals 2916579668449318000, x *= x
  assertEquals 2916579669254640600, x += (x & (tmp = 2986558026.399422
  tmp
  ))
  assertEquals 870995175, x ^= (2598813927.8991632)
  assertEquals 870995175, x %= (-2857038782)
  assertEquals 1869503575895591000, x *= (x | (x | (((tmp = 2478650307.4118147
  tmp
  ) * ((tmp = 2576240847.476932
  tmp
  ) >>> x)) << x)))
  assertEquals -134947790, x |= ((tmp = 1150911808
  tmp
  ) * ((2847735464) / (-2603172652.929262)))
  assertEquals -137053182, x -= ((tmp = 2155921819.0929346
  tmp
  ) >>> (x - (((-1960937402) - (-1907735074.2875962)) % ((1827808310) ^ (tmp = -2788307127
  tmp
  )))))
  assertEquals -134824702, x |= (((2912578752.2395406) ^ (x % (((-2585660111.0638976) << (((((tmp = 747742706
  tmp
  ) % (-1630261205)) & ((((x | (x | (-2619903144.278758))) | ((2785710568.8651934) >> ((-968301967.5982246) << (x & x)))) >> ((x >>> ((x >>> (tmp = -1402085797.0310762
  tmp
  )) * ((tmp = -323729645.2250068
  tmp
  ) << (tmp = 2234667799
  tmp
  )))) >>> (-167003745))) >> ((924665972.4681011) << x))) >>> x) << ((((x + x) + x) - (((tmp = 2399203431.0526247
  tmp
  ) - (-2872533271)) - (((tmp = 914778794.2087344
  tmp
  ) - (tmp = 806353942.9502392
  tmp
  )) | (((tmp = 262924334.99231672
  tmp
  ) & x) | (tmp = -460248836.5602243
  tmp
  ))))) / x))) % ((-1681000689) / (tmp = -2805054623.654228
  tmp
  ))))) * (tmp = 957346233.9619625
  tmp
  ))
  assertEquals -3274838, x %= ((((tmp = 3155450543.3524327
  tmp
  ) >>> x) << (tmp = 2103079652.3410985
  tmp
  )) >> x)
  assertEquals -3274838, x |= ((((tmp = 2148004645.639173
  tmp
  ) >>> (tmp = -1285119223
  tmp
  )) << (((((-711596054) >>> (tmp = -2779776371.3473206
  tmp
  )) ^ (((((tmp = -1338880329.383915
  tmp
  ) << ((-1245247254.477341) >> x)) * (tmp = -2649052844.20065
  tmp
  )) >> ((1734345880.4600453) % (x / (2723093117.118899)))) * (1252918475.3285656))) << (2911356885)) ^ x)) << (-1019761103))
  assertEquals 1703281954, x &= (((tmp = 1036570471.7412028
  tmp
  ) + ((tmp = 3043119517
  tmp
  ) % (2374310816.8346715))) % (tmp = -2979155076
  tmp
  ))
  assertEquals 1741588391, x |= ((tmp = 1230009575.6003838
  tmp
  ) >>> (-1247515003.8152597))
  assertEquals 72869474.64782429, x %= (tmp = 1668718916.3521757
  tmp
  )
  assertEquals 770936242.104203, x += (698066767.4563787)
  assertEquals -0.2820604726420833, x /= (tmp = -2733230342
  tmp
  )
  assertEquals 403480578, x |= ((969730374) & (tmp = 1577889835
  tmp
  ))
  assertEquals -1669557233, x ^= ((-1616812135) + (tmp = -456209292
  tmp
  ))
  assertEquals -1630427, x >>= ((2327783031.1175823) / (226947662.4579488))
  assertEquals 131022, x >>>= ((tmp = -1325018897.2482083
  tmp
  ) >> (x & ((((((-1588579772.9240348) << (tmp = -1775580288.356329
  tmp
  )) << (tmp = -1021528325.2075481
  tmp
  )) >> ((tmp = 2373033451.079956
  tmp
  ) * (tmp = 810304612
  tmp
  ))) - ((tmp = -639152097
  tmp
  ) << (tmp = 513879484
  tmp
  ))) & (2593958513))))
  assertEquals 1, x >>= ((3033200222) - x)
  assertEquals -561146816.4851823, x += (tmp = -561146817.4851823
  tmp
  )
  assertEquals -4.347990105831158, x /= ((((-1270435902) * x) % ((tmp = 637328492.7386824
  tmp
  ) - (x >> (-749100689)))) % (x + x))
  assertEquals -1, x >>= x
  assertEquals 1, x *= x
  assertEquals 111316849706694460, x += ((966274056) * (x | (115202150)))
  assertEquals -1001883840, x >>= x
  assertEquals -1001883840, x &= x
  assertEquals -3006880758, x += ((((-2275110637.4054556) / ((x + (tmp = -1390035090.4324536
  tmp
  )) >> (-5910593))) & (tmp = 378982420
  tmp
  )) | (tmp = 2289970378.568629
  tmp
  ))
  assertEquals 314474, x >>>= (x >> ((tmp = -228007336.31281257
  tmp
  ) % (tmp = 1127648013
  tmp
  )))
  assertEquals -17694827, x ^= ((tmp = 2095133598.1849852
  tmp
  ) | (-1978322311))
  assertEquals 1, x /= x
  assertEquals 1, x %= (-2323617209.7531185)
  assertEquals 0, x >>>= (x * (tmp = -1574455400.489434
  tmp
  ))
  assertEquals 0, x >>= (3131854684)
  assertEquals 2853609824, x += ((-231012098) - (tmp = -3084621922
  tmp
  ))
  assertEquals 8143089027629311000, x *= x
  assertEquals 313052685, x ^= (tmp = 2962303501
  tmp
  )
  assertEquals 4776, x >>= (tmp = 2271457232
  tmp
  )
  assertEquals 0.000002812258572702285, x /= (tmp = 1698279115
  tmp
  )
  assertEquals 0, x >>>= (tmp = 1698465782.0927145
  tmp
  )
  assertEquals 0, x <<= x
  assertEquals 0, x |= ((x << ((-1824760240.3040407) << (2798263764.39145))) & (tmp = 1795988253.0493627
  tmp
  ))
  assertEquals 1782206945, x ^= (-2512760351.7881565)
  assertEquals 7610569113843172000, x *= (((tmp = -44415823.92972565
  tmp
  ) & (tmp = 1402483498.9421625
  tmp
  )) + (tmp = 2909778666
  tmp
  ))
  assertEquals 15221138227873292000, x += (x - (tmp = -186948658.394145
  tmp
  ))
  assertEquals 0, x -= x
  assertEquals -2238823252, x -= ((tmp = 2238823252
  tmp
  ) + x)
  assertEquals 0, x -= x
  assertEquals 0, x >>= (2976069570)
  assertEquals 0, x >>= ((tmp = -2358157433
  tmp
  ) / x)
  assertEquals -949967713, x ^= (tmp = -949967713
  tmp
  )
  assertEquals -1, x >>= x
  assertEquals -1522291702.1977966, x *= (1522291702.1977966)
  assertEquals -1522291702, x >>= ((((2290279800) | x) | (1793154434.6798015)) & ((-1161390929.0766077) >>> x))
  assertEquals 83894274, x &= (tmp = 1571058486
  tmp
  )
  assertEquals 43186847.90522933, x += ((tmp = -1131332988.0947707
  tmp
  ) % x)
  assertEquals 0, x >>= (tmp = -1968312707.269359
  tmp
  )
  assertEquals 0, x &= (2507747643.26175)
  assertEquals 0, x %= (tmp = 3190525303.366887
  tmp
  )
  assertEquals -1968984602, x ^= (((x / (x | (-1607062026.5338054))) << (tmp = 2207669861.8770065
  tmp
  )) + (tmp = 2325982694.956348
  tmp
  ))
  assertEquals 554, x >>>= (((tmp = -2302283871.993821
  tmp
  ) >>> (-3151835112)) | (((((x % (-1534374264)) / ((731246012) << (((883830997.1194847) << (((-1337895080.1937215) / (tmp = 3166402571.8157315
  tmp
  )) ^ (tmp = -1563897595.5799441
  tmp
  ))) >> (tmp = -556816951.0537591
  tmp
  )))) >> (-2682203577)) << (x / ((1654294674.865079) + x))) / ((x ^ (-2189474695.4259806)) / (-475915245.7363057))))
  assertEquals 1372586111, x ^= (1372586581)
  assertEquals 1166831229, x -= ((-834168138) & (762573579))
  assertEquals 2333662456, x -= ((x >> x) - x)
  assertEquals -1961304840, x &= x
  assertEquals -2130143128, x &= (2982852718.0711775)
  assertEquals 1073741824, x <<= (-1446978661.6426942)
  assertEquals 2097152, x >>>= ((-1424728215) - (((127872198) % (tmp = -2596923298
  tmp
  )) & x))
  assertEquals 2097152, x >>>= x
  assertEquals 0, x &= (x / (tmp = -518419194.42994523
  tmp
  ))
  assertEquals 0, x >>= ((x / (-1865078245)) % (tmp = 2959239210
  tmp
  ))
  assertEquals -0, x *= ((x | (-1721307400)) | (-3206147171.9491577))
  assertEquals 0, x >>>= ((-694741143) & (tmp = -2196513947.699142
  tmp
  ))
  assertEquals 0, x <<= x
  assertEquals 0, x &= ((tmp = 2037824385.8836646
  tmp
  ) + ((tmp = 1203034986.4647732
  tmp
  ) / (x >>> (((-1374881234) / (899771270.3237157)) + ((-2296524362.8020077) | (-1529870870))))))
  assertEquals 0, x >>= (tmp = 2770637816
  tmp
  )
  assertEquals 0, x ^= x
  assertEquals -1861843456, x |= ((632402668) * ((x | (tmp = -1032952662.8269436
  tmp
  )) | (tmp = 2671272511
  tmp
  )))
  assertEquals -1861843456, x >>= (((x >>> x) + x) << (-1600908842))
  assertEquals -58182608, x >>= (x - (tmp = -2496617861
  tmp
  ))
  assertEquals -3636413, x >>= (tmp = -400700028
  tmp
  )
  assertEquals -7272826, x += x
  assertEquals -1, x >>= ((tmp = -3184897005.3614545
  tmp
  ) - ((-1799843014) | (tmp = 2832132915
  tmp
  )))
  assertEquals -121800925.94209385, x *= (121800925.94209385)
  assertEquals -30450232, x >>= (-979274206.6261561)
  assertEquals -30450232, x >>= (tmp = -1028204832.5078967
  tmp
  )
  assertEquals -30450232, x |= x
  assertEquals 965888871, x ^= (((((-2157753481.3375635) * ((tmp = -1810667184.8165767
  tmp
  ) & ((tmp = 2503908344.422232
  tmp
  ) | x))) >> (x >> (1601560785))) << x) ^ (tmp = 943867311.6380403
  tmp
  ))
  assertEquals 7546006, x >>>= x
  assertEquals 7546006, x <<= ((tmp = 1388931761.780241
  tmp
  ) * (x - (tmp = -1245147647.0070577
  tmp
  )))
  assertEquals 12985628, x += (x & (-1520746354))
  assertEquals 12985628, x &= x
  assertEquals 12985628, x %= (tmp = 308641965
  tmp
  )
  assertEquals 685733278, x |= ((tmp = -1275653544
  tmp
  ) - ((tmp = -1956798010.3773859
  tmp
  ) % (tmp = 2086889575.643448
  tmp
  )))
  assertEquals 679679376, x &= (2860752368)
  assertEquals 1770773904, x |= (x << (3200659207))
  assertEquals 1224886544, x &= (-585733767.6876519)
  assertEquals 1224886544, x %= ((tmp = -114218494
  tmp
  ) - x)
  assertEquals 1208109328, x &= (tmp = 1854361593
  tmp
  )
  assertEquals 18434, x >>>= x
  assertEquals -349394636955256100, x *= (x * (-1028198742))
  assertEquals -519536600.7713163, x %= (-1054085356.9120367)
  assertEquals -1610612736, x ^= ((tmp = -3126078854
  tmp
  ) & x)
  assertEquals -2637321565906333700, x *= (1637464740.5658746)
  assertEquals -2637321568051070500, x -= ((tmp = -1006718806
  tmp
  ) << (3005848133.106345))
  assertEquals 368168695, x ^= (x ^ (tmp = 368168695.6881037
  tmp
  ))
  assertEquals 43, x >>>= x
  assertEquals -2081297089, x |= ((167169305.77248895) + (-2248466405.3199244))
  assertEquals -2474622167, x -= (tmp = 393325078
  tmp
  )
  assertEquals -135109701, x %= (-1169756233)
  assertEquals 0, x ^= x
  assertEquals 0, x >>= (((((tmp = -164768854
  tmp
  ) / (tmp = -1774989993.1909926
  tmp
  )) + x) - ((-921438912) >> (tmp = -191772028.69249105
  tmp
  ))) - (tmp = 558728578.22033
  tmp
  ))
  assertEquals 0, x %= (tmp = 2188003745
  tmp
  )
  assertEquals 0, x <<= (((tmp = -999335540
  tmp
  ) >> ((((325101977) / (tmp = -3036991542
  tmp
  )) << (tmp = -213302488
  tmp
  )) + x)) | (tmp = -1054204587
  tmp
  ))
  assertEquals 0, x &= ((2844053429.4720345) >>> x)
  assertEquals NaN, x %= x
  assertEquals NaN, x -= (-1481729275.9118822)
  assertEquals NaN, x *= (tmp = 1098314618.2397528
  tmp
  )
  assertEquals -1073741824, x ^= ((tmp = 1718545772
  tmp
  ) << (((tmp = -81058910
  tmp
  ) - (2831123087.424368)) + (tmp = 576710057.2361784
  tmp
  )))
  assertEquals -2921155898.4793186, x -= (1847414074.4793184)
  assertEquals -1295646720, x <<= (2178621744)
  assertEquals -0.8906779709597907, x /= ((tmp = -2840292585.6837263
  tmp
  ) << (x & ((tmp = 892527695.6172305
  tmp
  ) >>> x)))
  assertEquals 0, x <<= (((tmp = 3149667213.298993
  tmp
  ) >> (tmp = 1679370761.7226725
  tmp
  )) ^ (115417747.21537328))
  assertEquals 0, x |= x
  assertEquals 0, x %= ((-1112849427) >> (-1245508870.7514496))
  assertEquals 0, x &= x
  assertEquals 0, x |= x
  assertEquals 0, x >>>= ((3144100694.930459) >>> (tmp = 2408610503
  tmp
  ))
  assertEquals 0, x <<= ((tmp = 2671709754.0318713
  tmp
  ) % x)
  assertEquals 0, x >>>= (x | ((tmp = -3048578701
  tmp
  ) - (674147224)))
  assertEquals NaN, x %= x
  assertEquals 0, x &= ((tmp = -2084883715
  tmp
  ) | (((((-3008427069) + (875536047.4283574)) >>> x) % (tmp = -450003426.1091652
  tmp
  )) % (((-2956878433.269356) | (x / ((((x % ((((((x << (((tmp = -1581063482.510351
  tmp
  ) ^ x) - (tmp = 1364458217
  tmp
  ))) ^ ((tmp = 1661446342
  tmp
  ) + (1307091014))) / (342270750.9901335)) >>> (x & ((1760980812.898993) & ((tmp = 2878165745.6401143
  tmp
  ) / (((tmp = -981178013
  tmp
  ) / (-2338761668.29912)) >> (-958462630)))))) * ((1807522840) ^ ((tmp = 1885835034
  tmp
  ) ^ (-2538647938)))) * (1673607540.0854697))) % x) >> x) << x))) << (853348877.2407281))))
  assertEquals 0, x >>>= x
  assertEquals -1162790279, x -= (1162790279)
  assertEquals -1162790279, x >>= (((-490178658) * x) / ((((((tmp = -1883861998.6699312
  tmp
  ) / (tmp = -2369967345.240594
  tmp
  )) + (3142759868.266447)) & (508784917.8158537)) & x) >> (-2129532322)))
  assertEquals -1360849740.9829152, x -= (x + (1360849740.9829152))
  assertEquals 1928392181, x ^= (-602670783)
  assertEquals 19478708.898989897, x /= (((-2617861994) >> (tmp = 797256920
  tmp
  )) % (-1784987906))
  assertEquals -8648903.575540157, x *= (((tmp = 673979276
  tmp
  ) / (-1517908716)) % (x / x))
  assertEquals -8648903.575540157, x %= ((((643195610.4221292) >>> (tmp = 2342669302
  tmp
  )) >>> (tmp = -1682965878
  tmp
  )) ^ ((tmp = -208158937.63443017
  tmp
  ) >> ((907286989) & (x << (448634893)))))
  assertEquals 1399288769, x ^= (tmp = -1407486728
  tmp
  )
  assertEquals 0, x &= (((1999255838.815517) / (tmp = 564646001
  tmp
  )) / (-3075888101.3274765))
  assertEquals 0, x ^= ((-78451711.59404826) % x)
  assertEquals -1351557131, x |= (2943410165)
  assertEquals 1715626371, x -= (-3067183502)
  assertEquals 71434240, x &= ((-1800066426) << (((((x << (-324796375)) + x) << (tmp = 2696824955.735132
  tmp
  )) ^ x) % (tmp = 444916469
  tmp
  )))
  assertEquals 71434240, x >>>= (((x & ((x % x) | x)) + (tmp = 2226992348.3050146
  tmp
  )) << (-305526260))
  assertEquals 0, x -= (x % (tmp = 582790928.5832802
  tmp
  ))
  assertEquals 0, x *= ((x % (1865155340)) >>> ((x << (2600488191)) ^ (-308995123)))
  assertEquals 0, x >>= (x & (-3120043868.8531103))
  assertEquals 0, x |= x
  assertEquals -0, x *= (tmp = -172569944
  tmp
  )
  assertEquals 0, x <<= (-1664372874)
  assertEquals 1377713344.6784928, x += (tmp = 1377713344.6784928
  tmp
  )
  assertEquals 1377713344, x |= x
  assertEquals -232833282, x |= (tmp = 2685870654
  tmp
  )
  assertEquals 84639, x -= (((((2778531079.998492) % (2029165314)) >>> (tmp = -468881172.3729558
  tmp
  )) ^ x) | ((x >>> ((((x % (3044318992.943596)) & (1996754328.2214756)) ^ (1985227172.7485228)) % (tmp = -1984848676.1347625
  tmp
  ))) | ((tmp = 2637662639
  tmp
  ) << x)))
  assertEquals 0, x ^= x
  assertEquals 1237720303, x -= (-1237720303)
  assertEquals 2, x >>= (-2148785379.428976)
  assertEquals 2, x &= (tmp = -3087007874
  tmp
  )
  assertEquals 0, x %= x
  assertEquals 0, x >>>= x
  assertEquals 0, x >>>= x
  assertEquals 0, x += x
  assertEquals 0, x &= (2055693082)
  assertEquals -1349456492, x += (x ^ (-1349456492.315998))
  assertEquals 671088640, x <<= (x >> (-2030805724.5472062))
  assertEquals -417654580004782100, x *= (tmp = -622353822
  tmp
  )
  assertEquals 1538160360, x |= (195983080.56698656)
  assertEquals 733, x >>>= (tmp = 661085269
  tmp
  )
  assertEquals 657, x &= (-1611460943.993404)
  assertEquals 431649, x *= x
  assertEquals 863298, x += x
  assertEquals 0, x &= ((1899423003) / ((472439729) >> ((tmp = 2903738952
  tmp
  ) + (tmp = 2164601630.3456993
  tmp
  ))))
  assertEquals 0, x &= (x >>> (tmp = 1939167951.2828958
  tmp
  ))
  assertEquals 1557813284, x |= (x - (-1557813284))
  assertEquals 72876068, x &= (662438974.2372154)
  assertEquals 0.6695448637501589, x /= (tmp = 108844189.45702457
  tmp
  )
  assertEquals 0, x -= x
  assertEquals 2944889412, x += (2944889412)
  assertEquals 3787980288, x -= ((((tmp = -2003814373.2301111
  tmp
  ) << x) >>> (tmp = -3088357284.4405823
  tmp
  )) - (843090884))
  assertEquals 1, x >>>= (729274079)
  assertEquals 1, x %= (-148002187.33869123)
  assertEquals 3073988415.673201, x *= (tmp = 3073988415.673201
  tmp
  )
  assertEquals 4839166225.673201, x += (tmp = 1765177810
  tmp
  )
  assertEquals 4529373898.673201, x += (-309792327)
  assertEquals 3097903.090496063, x %= (-150875866.51942348)
  assertEquals 1270874112, x <<= ((((((tmp = -960966763.1418135
  tmp
  ) >> ((((-3208596981.613482) >>> (tmp = 746403937.6913509
  tmp
  )) >>> (-2190042854.066803)) / (2449323432))) * (-1272232665.791577)) << (-99306767.7209444)) ^ ((-1942103828) / ((1570981655) / (tmp = 2381666337
  tmp
  )))) + (tmp = -1946759395.1558368
  tmp
  ))
  assertEquals 1273845956, x |= (tmp = -3197282108.6120167
  tmp
  )
  assertEquals 159230744, x >>= (((tmp = -1036031403.8108604
  tmp
  ) >>> (((3084964493) >> ((x * x) ^ x)) + (((2980108409.352001) ^ x) - (tmp = -2501685423.513927
  tmp
  )))) & (326263839))
  assertEquals -370091747145550100, x *= (tmp = -2324248055.674161
  tmp
  )
  assertEquals 143384219.54999557, x /= (tmp = -2581119096
  tmp
  )
  assertEquals 1843396287, x |= (tmp = 1842718767
  tmp
  )
  assertEquals 2.4895593465813803, x /= (740450831)
  assertEquals 2.4895593465813803, x %= ((((((((-3175333618) >>> ((tmp = -1403880166
  tmp
  ) << (tmp = -134875360
  tmp
  ))) >>> (2721317334.998084)) << (x & (tmp = 2924634208.1484184
  tmp
  ))) * ((((x >> (tmp = -200319931.15328693
  tmp
  )) - (tmp = -495128933
  tmp
  )) + ((-788052518.6610589) * ((((tmp = 107902557
  tmp
  ) & (1221562660)) % (x << (((3155498059) * (((tmp = -1354381139.4897022
  tmp
  ) ^ (tmp = 3084557138.332852
  tmp
  )) * ((((tmp = 1855251464.8464525
  tmp
  ) / ((-1857403525.2008865) >> x)) | x) - (-2061968455.0023944)))) * (1917481864.84619)))) ^ (x - (-508176709.52712965))))) + ((((x % (-1942063404)) + (x % (tmp = 855152281.180481
  tmp
  ))) | (-522863804)) >> x))) >>> ((tmp = -2515550553
  tmp
  ) & (((((-801095375) - (tmp = -2298729336.9792976
  tmp
  )) ^ x) / (tmp = 2370468053
  tmp
  )) >> (x | (tmp = -900008879
  tmp
  ))))) >>> (((tmp = -810295719.9509168
  tmp
  ) * ((tmp = -1306212963.6226444
  tmp
  ) / (((tmp = 3175881540.9514832
  tmp
  ) | (-1439142297.819246)) + ((tmp = -134415617
  tmp
  ) | ((-245801870) + x))))) >> (tmp = 1889815478
  tmp
  ))) - (((tmp = 597031177
  tmp
  ) % (858071823.7655672)) + ((tmp = 2320838665.8243756
  tmp
  ) | ((938555608) << (2351739219.6461897)))))
  assertEquals 6.197905740150709, x *= x
  assertEquals 1, x /= x
  assertEquals 0, x >>= (-1639664165.9076233)
  assertEquals 0, x >>= (-3135317748.801177)
  assertEquals 0, x &= (3185479232.5325994)
  assertEquals -0, x *= ((-119759439.19668174) / (tmp = 2123964608
  tmp
  ))
  assertEquals 0, x /= (-1183061929.2827876)
  assertEquals 0, x <<= (-1981831198)
  assertEquals 0, x >>= ((((x << (((((((-2133752838) & ((tmp = -3045157736.9331336
  tmp
  ) >>> (x % x))) >> x) % (tmp = 3082217039
  tmp
  )) & (tmp = 270770770.97558427
  tmp
  )) | ((-2212037556) ^ ((((((2089224421) | (tmp = 360979560
  tmp
  )) << x) % ((tmp = -1679487690.6940534
  tmp
  ) + ((173021423) | ((tmp = 560900612
  tmp
  ) + ((244376267.58977115) ^ x))))) << (tmp = 2534513699
  tmp
  )) ^ x))) >>> (2915907189.4873834))) + (x * x)) % (1637581117)) % (tmp = 2363861105.3786244
  tmp
  ))
  assertEquals 0, x &= ((-2765495757.873004) & (1727406493))
  assertEquals NaN, x -= (((((-1419667515.2616255) | x) - (150530256.48022234)) % ((((x | x) << x) >>> (x ^ x)) + x)) - ((-1216384577.3749187) * (495244398)))
  assertEquals NaN, x += (x ^ ((tmp = 2472035493
  tmp
  ) + x))
  assertEquals NaN, x %= ((tmp = -1753037412.885754
  tmp
  ) | ((tmp = 2507058310
  tmp
  ) << (1475945705)))
  assertEquals -1008981005, x |= ((tmp = -1140889842.6099494
  tmp
  ) - (tmp = -131908837
  tmp
  ))
  assertEquals 999230327.5872104, x -= (tmp = -2008211332.5872104
  tmp
  )
  assertEquals 975810, x >>= (((-1211913874) * x) >>> ((-2842129009) >> (x & (tmp = -1410865834
  tmp
  ))))
  assertEquals 7623, x >>= ((tmp = -1051327071
  tmp
  ) - (((tmp = -237716102.8005445
  tmp
  ) | ((2938903833.416546) & x)) | (((-1831064579) ^ x) / ((tmp = 2999232092
  tmp
  ) - (981996301.2875179)))))
  assertEquals 0, x -= x
  assertEquals 0, x %= (x | (tmp = -666201160.5810485
  tmp
  ))
  assertEquals -1347124100, x |= (-1347124100)
  assertEquals -0, x %= (x & x)
  assertEquals -661607963, x ^= (tmp = -661607963.3794863
  tmp
  )
  assertEquals 3465, x >>>= (-828119020.8056595)
  assertEquals -268431991, x -= (((tmp = -1386256352
  tmp
  ) ^ ((tmp = 743629575
  tmp
  ) % ((x * ((tmp = -1719517658
  tmp
  ) >> (2019516558))) << ((2637317661) | x)))) << (tmp = -51637065
  tmp
  ))
  assertEquals 1578876380, x += ((tmp = 1847308371
  tmp
  ) & (((((((tmp = 1487934776.1893163
  tmp
  ) % (tmp = 1423264469.3137975
  tmp
  )) | (((2653260792.5668964) / (-2417905016.043802)) >>> (2097411118.4501896))) ^ x) ^ (((tmp = -71334226
  tmp
  ) | x) >>> (tmp = -2771758874.7696714
  tmp
  ))) ^ ((tmp = -1464849031.3240793
  tmp
  ) % (tmp = 2349739690.6430283
  tmp
  ))) / x))
  assertEquals 3269293934, x += (1690417554)
  assertEquals 4025392608.031957, x -= (((tmp = 268501120.7225704
  tmp
  ) << (tmp = 2841620654.8903794
  tmp
  )) + ((tmp = 1606704462.8455591
  tmp
  ) / ((-2601879963) / (tmp = 2966620168.989736
  tmp
  ))))
  assertEquals 7, x >>>= (x ^ (-1913800035))
  assertEquals 1.4326776816275493e-8, x /= ((((tmp = -2703417892
  tmp
  ) / x) ^ ((-2693772270.396241) >>> ((x - (tmp = 615999818.5666655
  tmp
  )) >> ((((2308121439.3702726) << ((-1794701502) >> (x + (tmp = -2253406035.972883
  tmp
  )))) << ((tmp = -197103799.0624652
  tmp
  ) | (629975898))) >>> x)))) >>> ((tmp = 2833656803
  tmp
  ) ^ (x ^ (tmp = -1580436025
  tmp
  ))))
  assertEquals 0, x >>>= (tmp = 1525372830.2126007
  tmp
  )
  assertEquals 0, x %= ((2354010949.24469) >>> (x << x))
  assertEquals 0, x ^= (((1112335059.6922574) * (tmp = -1874363935
  tmp
  )) & (((((2154894295.8360596) << x) & (tmp = -270736315.13505507
  tmp
  )) & x) >>> (-2205692260.552064)))
  assertEquals 0, x >>>= (x << ((1488533932) * (tmp = 1707754286
  tmp
  )))
  assertEquals 0, x >>= (((tmp = 1232547376.463387
  tmp
  ) % ((x >> (711691823.1608362)) >>> x)) >> (((895039781.7478573) * (((((-334946524) & x) * (tmp = -1214529640
  tmp
  )) ^ (tmp = -1586820245
  tmp
  )) * (1062595445))) + x))
  assertEquals 0, x *= (1863299863.2631998)
  assertEquals 0, x /= (tmp = 1858428705.1330547
  tmp
  )
  assertEquals 0, x &= x
  assertEquals 611788028, x += (x ^ (611788028.1510412))
  assertEquals 1, x /= x
  assertEquals 0, x >>= ((tmp = -1617320707.1784317
  tmp
  ) - ((-2139400380) - (-1402777976)))
  assertEquals 0, x >>= (415866827.34665)
  assertEquals -1990811897, x -= (tmp = 1990811897
  tmp
  )
  assertEquals -1990811895, x += ((x >>> (tmp = -2175453282.769696
  tmp
  )) & (tmp = -1459450498.7327478
  tmp
  ))
  assertEquals -2377017935.149517, x += (-386206040.1495173)
  assertEquals 1946129845, x |= (tmp = -2890956796.936539
  tmp
  )
  assertEquals 0, x %= x
  assertEquals 0, x <<= (1616188263)
  assertEquals -1081213596, x ^= (tmp = 3213753700
  tmp
  )
  assertEquals 3213753700, x >>>= (tmp = -3211181312
  tmp
  )
  assertEquals -1081213596, x &= x
  assertEquals -1081213583, x ^= (((tmp = 1599988273.4926577
  tmp
  ) >> ((((-1061394954.6331315) ^ x) + ((-1835761078) * x)) + (x % (tmp = -696221869
  tmp
  )))) / ((tmp = -1156966790.3436491
  tmp
  ) ^ x))
  assertEquals 0, x ^= x
  assertEquals NaN, x /= x
  assertEquals NaN, x += (-1257400530.9263027)
  assertEquals NaN, x /= (753062089)
  assertEquals NaN, x *= ((tmp = 305418865.57012296
  tmp
  ) ^ (((-2797769706) + ((((tmp = -33288276.988654375
  tmp
  ) % (tmp = 1242979846
  tmp
  )) | (-316574800)) - ((tmp = -1766083579.4203427
  tmp
  ) * (((x * (tmp = -2400342309.2349987
  tmp
  )) >> (tmp = 2632061795
  tmp
  )) ^ (tmp = -1001440809
  tmp
  ))))) ^ ((((x - (tmp = -1469542637.6925495
  tmp
  )) - x) - (3184196890)) % (((((((633226688) * ((tmp = -2692547856
  tmp
  ) >> (((tmp = -1244311756
  tmp
  ) >>> x) + ((1746013631.405202) >>> (941829464.1962085))))) % (x - x)) + (995681795)) - (tmp = -3047070551.3642616
  tmp
  )) / (1968259705)) - ((-2853237880) ^ (tmp = -2746628223.4540343
  tmp
  ))))))
  assertEquals 0, x >>= x
  assertEquals 0.5713172378854926, x += (((x + (((x + x) / (tmp = 2642822318
  tmp
  )) * (-2590095885.4280834))) | (tmp = -1769210836
  tmp
  )) / (tmp = -3096722308.8665104
  tmp
  ))
  assertEquals -0.000002311097780334994, x /= ((2269858877.9010344) >> (-2992512915.984787))
  assertEquals -0.000002311097780334994, x %= (-1139222821)
  assertEquals -0.000004622195560669988, x += x
  assertEquals 1, x /= x
  assertEquals 1, x >>>= (((3002169429.6061807) / (-3068577366)) >>> ((tmp = -1844537620
  tmp
  ) % ((((tmp = 2087505119
  tmp
  ) >>> x) + x) & (2179989542))))
  assertEquals -534213071, x *= (-534213071)
  assertEquals -534213077.3716287, x -= (((tmp = -2390432951.154034
  tmp
  ) ^ x) / (-290501980))
  assertEquals 1836305, x >>>= (x & x)
  assertEquals 1836305, x %= ((x | ((3070123855) ^ (49986396))) + ((-1863644960.4202995) >>> ((tmp = 1886126804.6019692
  tmp
  ) ^ x)))
  assertEquals 28692, x >>>= ((2561362139.491764) >> (((((tmp = -1347469854.7413375
  tmp
  ) / (((x | (x + x)) ^ ((x ^ (tmp = -2737413775.4595394
  tmp
  )) ^ x)) << (((tmp = 225344844.07128417
  tmp
  ) & x) & (tmp = 145794498
  tmp
  )))) * x) << (1424529187)) / ((-2924344715) / (tmp = -2125770148
  tmp
  ))))
  assertEquals -2089419535.2717648, x += (-2089448227.2717648)
  assertEquals 18957929, x ^= (tmp = 2186590872
  tmp
  )
  assertEquals -708972800, x -= (727930729)
  assertEquals -4198593, x |= (799483455.1885371)
  assertEquals -1, x >>= (-2330654693.6413193)
  assertEquals -1, x |= (((tmp = -116877155
  tmp
  ) >>> ((((tmp = -1677422314.1333556
  tmp
  ) / (tmp = -3108738499.0798397
  tmp
  )) % ((x & (x / x)) % ((tmp = -695607185.1561592
  tmp
  ) - (tmp = 2302449181.622259
  tmp
  )))) ^ (((-1482743646.5604773) ^ ((897705064) >>> x)) - (tmp = -2933836669
  tmp
  )))) % (((tmp = -2991584625
  tmp
  ) | (((x >> x) + (-1101066835)) - x)) >> (-33192973.819939613)))
  assertEquals -1, x &= x
  assertEquals -524288, x <<= (-1177513101.3087924)
  assertEquals 1978770334.9189441, x += (tmp = 1979294622.9189441
  tmp
  )
  assertEquals 901783582, x &= ((-368584615) ^ (((((-478030699.2647903) << x) << x) + (tmp = 708725752
  tmp
  )) ^ ((tmp = -3081556856
  tmp
  ) / (tmp = 1149958711.0676727
  tmp
  ))))
  assertEquals -1480333211.8654308, x += (tmp = -2382116793.865431
  tmp
  )
  assertEquals 956930239.6783283, x *= ((tmp = 956930239.6783283
  tmp
  ) / x)
  assertEquals 1277610.4668602513, x /= ((tmp = 1571029828
  tmp
  ) >> (tmp = 2417481141
  tmp
  ))
  assertEquals -1077333228, x ^= (tmp = 3218755006
  tmp
  )
  assertEquals -50218, x |= (tmp = -1044436526.6435988
  tmp
  )
  assertEquals -1, x >>= (-154655245.18921852)
  assertEquals 0.00006276207290978003, x *= (((tmp = 2234286992.9800305
  tmp
  ) >> (tmp = 2132564046.0696363
  tmp
  )) / ((((tmp = -2565534644.3428087
  tmp
  ) >>> (tmp = 2622809851.043325
  tmp
  )) >>> ((tmp = 311277386
  tmp
  ) & x)) - (tmp = -2003980974
  tmp
  )))
  assertEquals 0, x %= x
  assertEquals 1282114076, x += ((((422838227) >>> ((tmp = 1024613366.1899053
  tmp
  ) - ((368275340) << (((tmp = -3066121318
  tmp
  ) + (-2319101378)) & x)))) ^ (x >> (tmp = 1920136319.803412
  tmp
  ))) ^ (1282264803.3968434))
  assertEquals -277097604, x |= (-283585688.9123297)
  assertEquals 553816692, x &= (x & (tmp = 554082036.676608
  tmp
  ))
  assertEquals 658505728, x <<= x
  assertEquals 658505728, x &= (x % (2846071230))
  assertEquals 39, x >>= (334728536.5172192)
  assertEquals 0, x -= x
  assertEquals 0, x += x
  assertEquals 0, x &= (tmp = -335285336
  tmp
  )
  assertEquals 0, x <<= (tmp = 1255594828.3430014
  tmp
  )
  assertEquals 0, x %= (-630772751.1248167)
  assertEquals NaN, x /= ((((x & (tmp = -1576090612
  tmp
  )) % x) >>> x) * ((-1038073094.2787619) >>> x))
  assertEquals NaN, x += x
  assertEquals NaN, x -= (((tmp = -2663887803
  tmp
  ) & ((x + (-1402421046)) / x)) / (-2675654483))
  assertEquals NaN, x %= (x & (tmp = 672002093
  tmp
  ))
  assertEquals 0, x |= x
  assertEquals -2698925754, x += (tmp = -2698925754
  tmp
  )
  assertEquals -2057748993, x += ((tmp = -2263466497
  tmp
  ) ^ x)
  assertEquals 1, x /= x
  assertEquals -2769559719.4045835, x -= (2769559720.4045835)
  assertEquals -1.3964174646069973, x /= (tmp = 1983332198
  tmp
  )
  assertEquals -2140716624.3964174, x += (tmp = -2140716623
  tmp
  )
  assertEquals 0, x <<= ((2589073007) - (-816764911.8571186))
  assertEquals -2837097288.161354, x -= (tmp = 2837097288.161354
  tmp
  )
  assertEquals -1445059927.161354, x += (tmp = 1392037361
  tmp
  )
  assertEquals 155197984, x &= (tmp = -2694712730.924674
  tmp
  )
  assertEquals 155197984, x |= (x >>> (tmp = 69118015.20305443
  tmp
  ))
  assertEquals 155197984, x >>>= (((x ^ (-1353660241)) * x) << (((((x % (tmp = -1905584634
  tmp
  )) >>> (tmp = -860171244.5963638
  tmp
  )) & (-1084415001.7039547)) + (x - (((tmp = 298064661
  tmp
  ) >> x) >> ((tmp = 378629912.383446
  tmp
  ) - (x % x))))) + (((3212580683) / (((((x ^ x) >> (tmp = -1502887218
  tmp
  )) << x) % (-142779025)) | (((tmp = 1361745708
  tmp
  ) * (((((tmp = 1797072528.0673332
  tmp
  ) + x) % (tmp = 167297609
  tmp
  )) % (-287345856.1791787)) ^ (((((((x * (tmp = -640510459.1514752
  tmp
  )) << (x ^ (tmp = 1387982082.5646644
  tmp
  ))) >> (tmp = 2473373497.467914
  tmp
  )) ^ ((234025940) * x)) + (tmp = 520098202.9546956
  tmp
  )) * (x * (tmp = -362929250.1775775
  tmp
  ))) ^ (-2379972900)))) * (tmp = -1385817972
  tmp
  )))) + (-1788631834))))
  assertEquals 0, x >>= ((tmp = -18671049
  tmp
  ) / ((tmp = 651261550.6716013
  tmp
  ) >> (-58105114.70740628)))
  assertEquals 0, x *= ((((x >> (tmp = 2256492150.737681
  tmp
  )) << (x << (((-2738910707) & x) << (1892428322)))) * (tmp = 1547934638
  tmp
  )) >> ((((319464033.7888391) | (((((tmp = 2705641070
  tmp
  ) << ((tmp = 1566904759.36666
  tmp
  ) * ((-682175559.7540412) & (-691692016.3021002)))) % (tmp = 1118101737
  tmp
  )) | (902774462)) << x)) ^ ((tmp = -388997180
  tmp
  ) << (x << ((((((-88462733) + (x >>> x)) % x) * (tmp = -20297481.556210756
  tmp
  )) >>> (1927423855.1719701)) - ((2047811185.6278129) - (tmp = 2952219346.72126
  tmp
  )))))) | (-1685518403.7513878)))
  assertEquals 0, x /= (tmp = 1858074757.563318
  tmp
  )
  assertEquals -1351623058, x ^= (-1351623058.4756806)
  assertEquals 1, x /= x
  assertEquals 0, x ^= x
  assertEquals 0, x -= (x & (997878144.9798675))
  assertEquals -0, x /= (-2769731277)
  assertEquals 0, x >>>= ((-2598508325) >> (-1355571351))
  assertEquals 0, x >>>= x
  assertEquals 0, x -= (x & (tmp = 1672810223
  tmp
  ))
  assertEquals -924449908.1999881, x -= (924449908.1999881)
  assertEquals -0, x %= x
  assertEquals -0, x /= (tmp = 2007131382.059545
  tmp
  )
  assertEquals -0, x += x
  assertEquals 225132064, x += ((((tmp = -2422670578.1260514
  tmp
  ) | x) + x) ^ (1660142894.7066057))
  assertEquals Infinity, x /= (x - x)
  assertEquals 0, x ^= x
  assertEquals 0, x <<= x
  assertEquals -2455424946.732606, x -= (2455424946.732606)
  assertEquals 1208029258, x &= ((tmp = 1823728509
  tmp
  ) + x)
  assertEquals 1.3682499724725645, x /= ((((tmp = 1267938464.3854322
  tmp
  ) % ((tmp = 2510853574
  tmp
  ) + (((2979355693.866435) - (tmp = 1989726095.7746763
  tmp
  )) << x))) % ((-1382092141.1627176) + (((-901799353) + ((-2936414080.8254457) >>> (2515004943.0865674))) - (2532799222.353197)))) << (tmp = -2168058960.2694826
  tmp
  ))
  assertEquals 0.13799826710735907, x %= ((-1090423235) / (tmp = 2659024727
  tmp
  ))
  assertEquals 0, x >>= (1688542889.082693)
  assertEquals 0, x <<= x
  assertEquals NaN, x %= ((((tmp = 1461037539
  tmp
  ) << ((x << (tmp = 2101282906.5302017
  tmp
  )) >> (-2792197742))) % (((x % x) ^ (((tmp = 1399565526
  tmp
  ) ^ (tmp = 643902
  tmp
  )) - ((tmp = -1449543738
  tmp
  ) | x))) / x)) * (x << (471967867)))
  assertEquals 0, x &= ((tmp = -2121748100.6824129
  tmp
  ) >> (tmp = -2817271480.6497793
  tmp
  ))
  assertEquals 0, x &= (3169130964.6291866)
  assertEquals -0, x /= (-2303316806)
  assertEquals 0, x <<= (tmp = 120185946.51617038
  tmp
  )
  assertEquals 449448375, x ^= ((((tmp = -836410266.014014
  tmp
  ) / x) & ((x >>> (tmp = -2602671283
  tmp
  )) + x)) + (tmp = 449448375
  tmp
  ))
  assertEquals 202003841790140640, x *= x
  assertEquals 202003840800829020, x += (((tmp = -1339865843
  tmp
  ) + (tmp = 350554234.15375435
  tmp
  )) << ((((((tmp = -1798499687.8208885
  tmp
  ) >> (((x - (x ^ x)) | ((tmp = 463627396.23932934
  tmp
  ) / (2714928060))) & (tmp = 3048222568.1103754
  tmp
  ))) & (-3127578553)) << (tmp = -2569797028.8299003
  tmp
  )) & x) << ((tmp = 2104393646
  tmp
  ) / ((tmp = 2314471015.742891
  tmp
  ) << ((2704090554.1746845) >> (((tmp = 1935999696
  tmp
  ) * (((1348554815) >>> x) >>> (146665093.82445252))) % x))))))
  assertEquals 202003841764125400, x -= (tmp = -963296372.2846234
  tmp
  )
  assertEquals -413485056, x <<= (tmp = -2474480506.6054573
  tmp
  )
  assertEquals -3171894580.186845, x += ((tmp = -1261111102
  tmp
  ) + (tmp = -1497298422.1868448
  tmp
  ))
  assertEquals 17136, x >>= (tmp = 3055058160
  tmp
  )
  assertEquals 17136, x %= (tmp = 1706784063.3577294
  tmp
  )
  assertEquals 17136, x >>= ((tmp = 2161213808
  tmp
  ) * x)
  assertEquals -17136, x /= ((((tmp = -1492618154
  tmp
  ) >> x) | (1381949066)) >> (tmp = 2014457960
  tmp
  ))
  assertEquals -34272, x += x
  assertEquals -1498690902, x += (-1498656630)
  assertEquals -1168674482, x ^= (486325220)
  assertEquals -1168674482, x <<= ((x ^ x) * x)
  assertEquals 794521557347068000, x *= (-679848469)
  assertEquals 1.3330392590424505e+26, x *= (tmp = 167778866
  tmp
  )
  assertEquals 0, x <<= (tmp = -2501540637.3664584
  tmp
  )
  assertEquals 0, x >>>= (x - (x * (-890638026.1825848)))
  assertEquals 0, x %= ((-285010538.2813468) & (1314684460.7634423))
  assertEquals 0, x -= x
  assertEquals 0, x *= x
  assertEquals NaN, x %= (x * (x << x))
  assertEquals NaN, x %= (x << (((tmp = -1763171810.601149
  tmp
  ) & (-138151449.18303752)) ^ (x | x)))
  assertEquals 0, x |= (x >> x)
  assertEquals 0, x &= (tmp = 1107152048
  tmp
  )
  assertEquals 0, x >>= (1489117056.8200984)
  assertEquals 518749976, x ^= (518749976.20107937)
  assertEquals 356718654, x += (tmp = -162031322
  tmp
  )
  assertEquals 356718654, x %= (((x >>> ((tmp = -373747439.09634733
  tmp
  ) * (tmp = 563665566
  tmp
  ))) * (tmp = 2853322586.588251
  tmp
  )) * ((1303537213) % (-2995314284)))
  assertEquals 5573728, x >>= (tmp = -2095997978
  tmp
  )
  assertEquals 5573728, x <<= x
  assertEquals 5573728, x >>= (((((tmp = 1745399178.334154
  tmp
  ) << (tmp = 2647999783.8219824
  tmp
  )) ^ (tmp = 1571286759
  tmp
  )) % x) / (2166250345.181711))
  assertEquals 10886, x >>>= ((682837289) + (x * x))
  assertEquals 170, x >>>= x
  assertEquals 169.95167497151652, x -= (((tmp = 527356024.19706845
  tmp
  ) + ((tmp = 1263164619.2954736
  tmp
  ) | (tmp = 2942471886
  tmp
  ))) / ((3017909419.131321) + (tmp = 2137746252.8006272
  tmp
  )))
  assertEquals -1915170061, x ^= (tmp = -1915170214
  tmp
  )
  assertEquals 206045792, x &= (((tmp = 887031922
  tmp
  ) >>> x) - ((-1861922770) | (9633541)))
  assertEquals -1940321674, x |= (tmp = -2012149162.1817405
  tmp
  )
  assertEquals -1940321674, x &= x
  assertEquals 1128412272.160699, x += (tmp = 3068733946.160699
  tmp
  )
  assertEquals 0.47486363523180236, x /= (tmp = 2376286976.807289
  tmp
  )
  assertEquals -1.4931079540252477e-10, x /= (tmp = -3180370407.5892467
  tmp
  )
  assertEquals 0, x |= (((1220765170.5933602) * (884017786)) * ((x % (tmp = -2538196897.226384
  tmp
  )) << (x ^ x)))
  assertEquals -525529894, x += (tmp = -525529894
  tmp
  )
  assertEquals 1621426184, x &= ((3046517714) * (((((-162481040.8033898) + (x / ((x & (1489724492)) / ((x | (tmp = 943542303
  tmp
  )) >>> ((-1840491388.1365871) << (2338177232)))))) + (((-2268887573.2430763) >>> (((tmp = 2919141667
  tmp
  ) + ((tmp = 1326295559.692003
  tmp
  ) << (-2256653815))) >>> (((((tmp = 1602731976.7514615
  tmp
  ) * (856036244.3730336)) ^ x) >>> ((((2846316421.252943) & (915324162)) % (tmp = 1144577211.0221815
  tmp
  )) % x)) * (x * x)))) % (tmp = -2641416560
  tmp
  ))) * (x + (x >>> x))) >> x))
  assertEquals 1621426184, x %= (tmp = 1898223948
  tmp
  )
  assertEquals -3.383396676504762, x /= ((tmp = 2211088034.5234556
  tmp
  ) ^ x)
  assertEquals 7120923705.122882, x *= (((((tmp = 2632382342.914504
  tmp
  ) / (-615440284.1762738)) & (2162453853.6658797)) << (-849038082.5298986)) | (tmp = -2104667110.5603983
  tmp
  ))
  assertEquals -1469010887, x &= x
  assertEquals 850767635866964700, x *= (tmp = -579143179.5338116
  tmp
  )
  assertEquals 0, x %= x
  assertEquals -571457, x |= ((2849326490.8464212) | (tmp = 1450592063
  tmp
  ))
  assertEquals -571457, x &= x
  assertEquals -0.00018638416434019244, x /= (3066016912.021368)
  assertEquals 0, x <<= (2058262829)
  assertEquals NaN, x %= ((x | ((x % x) >>> x)) % ((tmp = -2970314895.6974382
  tmp
  ) + x))
  assertEquals NaN, x *= (-698693934.9483855)
  assertEquals NaN, x += (-100150720.64391875)
  assertEquals NaN, x %= x
  assertEquals NaN, x -= (-530301478)
  assertEquals NaN, x /= (1507673244)
  assertEquals 0, x <<= (x % (tmp = 2977838420.857235
  tmp
  ))
  assertEquals 0, x <<= (tmp = 3200877763
  tmp
  )
  assertEquals 0, x <<= (tmp = -2592127060
  tmp
  )
  assertEquals NaN, x -= (((((((1930632619) * (3018666359)) << ((tmp = 2676511886
  tmp
  ) & (-2786714482.25468))) % x) - (-633193192)) << ((tmp = 403293598
  tmp
  ) * (-2765170226))) % x)
  assertEquals 530062092, x |= (tmp = 530062092
  tmp
  )
  assertEquals 129409, x >>>= x
  assertEquals -152430382316341.78, x *= (-1177896300.229055)
  assertEquals -304860764632683.56, x += x
  assertEquals 0, x ^= x
  assertEquals 0, x %= (tmp = -63071565.367660046
  tmp
  )
  assertEquals 0, x &= ((((tmp = -1007464338
  tmp
  ) << (x << ((x ^ (tmp = -726826835
  tmp
  )) | x))) >>> x) * (((tmp = 469293335.9161849
  tmp
  ) << (((((tmp = 1035077379
  tmp
  ) * (tmp = -555174353.7567515
  tmp
  )) & (3109222796.8286266)) - (((((x - (tmp = 1128900353.6650414
  tmp
  )) | (tmp = 3119921303
  tmp
  )) & ((-1353827690) & (x % ((-924615958) & x)))) >>> x) + (tmp = 1167787910
  tmp
  ))) + x)) % ((605363594) >> (1784370958.269381))))
  assertEquals 0, x %= (2953812835.9781704)
  assertEquals 0, x -= x
  assertEquals 0, x <<= x
  assertEquals -901209266, x += (-901209266)
  assertEquals -901209266, x &= x
  assertEquals 404, x >>>= (-3195686249)
  assertEquals 824237108, x ^= (824237472)
  assertEquals 497790936.1853996, x /= ((tmp = 1253776028
  tmp
  ) / (757207285))
  assertEquals 497790936, x >>>= ((tmp = -2212598336
  tmp
  ) << (x ^ (1335355792.9363852)))
  assertEquals 0, x %= x
  assertEquals -2659887352.6415873, x += (tmp = -2659887352.6415873
  tmp
  )
  assertEquals 1635079945, x |= ((x & (1234659380)) >> ((((tmp = 2694276886.979136
  tmp
  ) | x) ^ ((tmp = 132795582
  tmp
  ) << ((-1089828902) >>> x))) << ((((tmp = -2098728613.0310376
  tmp
  ) << (x / (tmp = -2253865599
  tmp
  ))) * ((x + (x >>> ((48633053.82579231) - (385301592)))) * (tmp = -1847454853.333535
  tmp
  ))) / ((-540428068.8583717) + x))))
  assertEquals 1, x /= x
  assertEquals 33554432, x <<= ((((2803140769) << x) | (tmp = -1965793804
  tmp
  )) >>> (tmp = -2273336965.575082
  tmp
  ))
  assertEquals 67108864, x += x
  assertEquals 9007199254740992, x *= (x + ((x >> x) % (2674760854)))
  assertEquals 55369784, x %= (x | (-170725544.20038843))
  assertEquals 55369784, x %= (-1186186787)
  assertEquals 0, x ^= x
  assertEquals 0, x <<= x
  assertEquals NaN, x /= ((-2968110098) - ((x / (x | (((((x | ((x & ((-130329882) >>> (((-135670650) | (x << (tmp = 1280371822
  tmp
  ))) ^ x))) - (-1183024707.2230911))) & (-1072829280)) >>> (-340696948.41492534)) >>> (tmp = 436308526.4938295
  tmp
  )) << (((tmp = 3113787500
  tmp
  ) * ((2038309320) >>> (-1818917055))) & ((2808000707) / (774731251)))))) % x))
  assertEquals 0, x |= (x * (tmp = -843074864
  tmp
  ))
  assertEquals 0, x &= (tmp = -752261173.8090212
  tmp
  )
  assertEquals 0, x >>>= (tmp = 1532349931.7517128
  tmp
  )
  assertEquals 0, x <<= ((tmp = -8628768
  tmp
  ) - ((((tmp = 225928543
  tmp
  ) % (x >>> (x + x))) ^ ((tmp = -2051536806.5249376
  tmp
  ) - x)) - ((tmp = -2274310376.9964137
  tmp
  ) % (tmp = 2251342739
  tmp
  ))))
  assertEquals 0, x >>= (1011388449)
  assertEquals 0, x += x
  assertEquals 0, x >>>= x
  assertEquals -0, x *= ((-1781234179.8663826) >> (((1514201119.9761915) >> (((((1174857164.90042) ^ (tmp = 1124973934
  tmp
  )) ^ x) + ((-1059246013.8834443) << (2997611138.4876065))) % (((798188010) * (-1428293122)) >>> (tmp = -3087267036.8035297
  tmp
  )))) << x))
  assertEquals 1752554372, x ^= (tmp = -2542412924
  tmp
  )
  assertEquals 1752554372, x %= (tmp = 3037553410.2298307
  tmp
  )
  assertEquals 1859383977, x -= (x ^ (2446603103))
  assertEquals 1183048193, x &= ((tmp = -962336957
  tmp
  ) / (x / x))
  assertEquals 67738157, x %= ((((tmp = -1813911745.5223546
  tmp
  ) + x) << (x - (((-1980179168) ^ x) | x))) | (1913769561.1308007))
  assertEquals 67698724, x &= ((1801574998.3142045) * ((tmp = -2057492249
  tmp
  ) / ((1713854494.72282) >> x)))
  assertEquals 0, x -= x
  assertEquals -25232836, x -= ((tmp = 25232836
  tmp
  ) | x)
  assertEquals -49, x >>= (x + ((tmp = 2201204630.2897243
  tmp
  ) | (-1929326509)))
  assertEquals -1605632, x <<= x
  assertEquals -165965313, x += (tmp = -164359681
  tmp
  )
  assertEquals 9.220413724941365e-10, x /= (((((tmp = 2579760013.0808706
  tmp
  ) * (tmp = -2535370639.9805303
  tmp
  )) >> ((tmp = 2138199747.0301933
  tmp
  ) - (tmp = -2698019325.0972376
  tmp
  ))) * (tmp = -425284716
  tmp
  )) / ((-1951538149.6611228) / (x ^ (2632919130))))
  assertEquals 0, x &= x
  assertEquals 0, x &= ((-645189137) / (tmp = 800952748
  tmp
  ))
  assertEquals 0, x &= (tmp = -1773606925
  tmp
  )
  assertEquals 0, x += x
  assertEquals 0, x >>>= (tmp = 211399355.0741787
  tmp
  )
  assertEquals 0, x <<= ((-1317040231.5737965) / ((((((tmp = 838897586.0147077
  tmp
  ) | ((-1902447594) | (tmp = 404942728.83034873
  tmp
  ))) ^ (2462760692.2907705)) % ((((((x % (tmp = -2888980287
  tmp
  )) << (-368505224.49609876)) - ((x >>> (532513369)) & (((((((tmp = -1298067543
  tmp
  ) ^ (tmp = -3130435881.100909
  tmp
  )) >> x) / (tmp = -3041161992
  tmp
  )) >> (x | (-431685991.95776653))) ^ ((tmp = 1031777777
  tmp
  ) ^ ((-105610810) >>> ((-631433779) >> (tmp = -2577780871.167671
  tmp
  ))))) % (tmp = -3170517650.088039
  tmp
  )))) - (((tmp = 2175146237.968785
  tmp
  ) - ((384631158.50508535) >> ((893912279.4646157) | (tmp = -1478803924.5338967
  tmp
  )))) % (x / (-1089156420)))) << (tmp = -2024709456
  tmp
  )) >> x)) * (tmp = -1423824994.6993582
  tmp
  )) % (tmp = 1739143409
  tmp
  )))
  assertEquals -1799353648, x |= ((-1799353648.3589036) >>> ((((x & (-923571640.1012449)) % x) + ((tmp = 971885508
  tmp
  ) >> ((tmp = -2207464428.2123804
  tmp
  ) + (-3108177894.0459776)))) - (-2048954486.7014258)))
  assertEquals -3666808032.2958965, x -= (tmp = 1867454384.2958965
  tmp
  )
  assertEquals -260069478915415100, x *= (tmp = 70925305.23136711
  tmp
  )
  assertEquals 1142096768, x &= (tmp = 1866401706.9144325
  tmp
  )
  assertEquals 1, x >>>= (tmp = 2701377150.5717473
  tmp
  )
  assertEquals 1865946805, x |= (tmp = -2429020492
  tmp
  )
  assertEquals 1424222287, x ^= ((((tmp = 433781338
  tmp
  ) >> (x >>> ((-2914418422.4829016) / (tmp = 1600920669
  tmp
  )))) | (tmp = 588320482.9566053
  tmp
  )) >>> ((((((x + (tmp = -2556387365.5071325
  tmp
  )) + (tmp = -2381889946.1830974
  tmp
  )) / (3154278191)) >>> (-1069701268.8022757)) >> (((tmp = 182049089.28866422
  tmp
  ) >> x) >>> (tmp = -447146173
  tmp
  ))) / (x - (2103883357.0929923))))
  assertEquals 0, x ^= x
  assertEquals 0, x -= (x % (3036884806))
  assertEquals 0, x >>>= (tmp = -652793480.3870945
  tmp
  )
  assertEquals 0, x += x
  assertEquals 304031003, x ^= ((tmp = -900156495
  tmp
  ) ^ (-666397014.0711515))
  assertEquals 1, x /= x
  assertEquals -1974501681, x |= (x ^ (-1974501681.4628205))
  assertEquals -1.3089278317616264, x /= (((-1723703186.962839) >>> x) | ((2061022161.6239533) << x))
  assertEquals -1, x |= (tmp = -1987006457
  tmp
  )
  assertEquals -0.14285714285714285, x /= ((((((x | (-1767793799.7595732)) - (-1391656680)) << x) | (x >> (tmp = -2301588485.2811003
  tmp
  ))) >>> (((tmp = 1812723993
  tmp
  ) >>> ((x ^ (((tmp = -3154100157.951021
  tmp
  ) % ((tmp = -1254955564.4553523
  tmp
  ) - (((x >>> (((-1762886343) * x) * x)) * (x ^ (x * (-750918563.4387553)))) * x))) | ((x >> x) >> (x << ((((-1766797454.5634143) ^ (tmp = -2251474340
  tmp
  )) - (-787637516.5276759)) << ((1390653368) ^ (-1937605249.245374))))))) | (((tmp = 1156611894
  tmp
  ) << x) << (x >> ((((x + (tmp = 2170166060.881797
  tmp
  )) & (x >>> (tmp = -1749295923.1498983
  tmp
  ))) >> (((-1014973878) | x) & (1302866805.684057))) * (tmp = 560439074.4002491
  tmp
  )))))) | (-2758270803.4510045))) & x)
  assertEquals 0, x |= x
  assertEquals 0, x += ((x >> ((x + (tmp = -2776680860.870219
  tmp
  )) - (((688502468) << (((tmp = 475364260.57888806
  tmp
  ) << x) + (329071671))) / (-1097134948)))) * (tmp = -1281834214.3416953
  tmp
  ))
  assertEquals 0, x *= ((((1159762330) << (tmp = -1892429200
  tmp
  )) % x) << x)
  assertEquals 0, x >>>= (-770595225)
  assertEquals NaN, x += (((x >> x) / (tmp = 281621135
  tmp
  )) / x)
  assertEquals 0, x >>= (1363890241)
  assertEquals 1639023942.9945002, x += (1639023942.9945002)
  assertEquals -2568590958567747000, x *= (-1567146697)
  assertEquals 1793554700, x ^= (tmp = 3215813388.405799
  tmp
  )
  assertEquals 437879, x >>= x
  assertEquals 1339485943, x |= (1339220210)
  assertEquals 1, x /= x
  assertEquals 512, x <<= (2509226729.1477118)
  assertEquals 512, x <<= ((x >> (1326274040.7181284)) << (tmp = -760670199
  tmp
  ))
  assertEquals 1, x /= (x << (x ^ x))
  assertEquals 0, x >>>= (((((1382512625.8298302) & (x >>> x)) * (tmp = -815316595
  tmp
  )) >>> x) - (-95538051))
  assertEquals -544344229.3548596, x -= (tmp = 544344229.3548596
  tmp
  )
  assertEquals -1088688458.7097192, x += x
  assertEquals -1022850479579041900, x *= (939525418.3104812)
  assertEquals 2069622661, x |= (-2632744187.7721186)
  assertEquals -1353480538017756400, x -= ((tmp = 1308085980
  tmp
  ) * ((x >>> (-629663391.5165792)) & (tmp = 3182319856.674114
  tmp
  )))
  assertEquals 1.3702811563654176e+27, x *= ((((3061414617.6321163) / (tmp = 2628865442
  tmp
  )) + (-1549548261)) + (x & ((tmp = 809684398
  tmp
  ) | (x ^ (tmp = 801765002
  tmp
  )))))
  assertEquals 0, x >>>= ((-2988504159) & ((tmp = -260444190.02252054
  tmp
  ) ^ (2178729442.260293)))
  assertEquals -1518607002, x -= (tmp = 1518607002
  tmp
  )
  assertEquals 724566016, x <<= (tmp = 1042915731.7055794
  tmp
  )
  assertEquals 707584, x >>>= (-208959862.93305588)
  assertEquals 0, x >>>= (((tmp = 877181764
  tmp
  ) >> (-970697753.3318911)) % x)
  assertEquals 0, x ^= x
  assertEquals 0, x += x
  assertEquals 0, x <<= x
  assertEquals 0, x /= (x ^ ((x / (-2903618412.4936123)) + (tmp = 1169288899
  tmp
  )))
  assertEquals 0, x >>>= x
  assertEquals -1302645245, x ^= ((1855892732.3544865) + (tmp = 1136429319.5633948
  tmp
  ))
  assertEquals 0, x ^= x
  assertEquals 0, x &= (-1384534597.409375)
  assertEquals -0, x /= (tmp = -680466419.8289509
  tmp
  )
  assertEquals -0, x *= (318728599.95017374)
  assertEquals NaN, x %= (x >> (2019695267))
  assertEquals 0, x >>= (tmp = 1280789995
  tmp
  )
  assertEquals 0, x *= (tmp = 2336951458
  tmp
  )
  assertEquals 0, x >>= ((2981466013.758637) % (731947033))
  assertEquals 0, x -= x
  assertEquals 0, x ^= x
  assertEquals 0, x /= ((((3068070149.1452317) >> x) % (((1448965452) * ((tmp = -2961594129
  tmp
  ) + (1829082104.0681171))) >> (-2331499703))) >>> (tmp = -3206314941.2626476
  tmp
  ))
  assertEquals 0, x >>= (x % (1869217101.9823673))
  assertEquals 0, x <<= (x + x)
  assertEquals 0, x >>>= ((1202130282) >>> x)
  assertEquals 0, x += x
  assertEquals 2603245248.6273212, x += (tmp = 2603245248.6273212
  tmp
  )
  assertEquals -1691864471, x ^= (x >>> (2504513614.117516))
  assertEquals 136835305, x -= ((-1618979896) & (-746953306))
  assertEquals -2568499564.1261334, x += (tmp = -2705334869.1261334
  tmp
  )
  assertEquals 1038075700, x ^= (1530399136)
  assertEquals 2076151400, x += x
  assertEquals -524018410.1751909, x -= ((2398973627.175191) - (-201196183))
  assertEquals 0.327110599608614, x /= ((3181340288.602796) & x)
  assertEquals 0.327110599608614, x %= (tmp = -2284484060
  tmp
  )
  assertEquals 0, x |= x
  assertEquals 403217947.5779772, x += (tmp = 403217947.5779772
  tmp
  )
  assertEquals 403217947, x |= x
  assertEquals -Infinity, x *= ((58693583.845808744) + (((tmp = -1527787016
  tmp
  ) * x) / ((((2532689893.3191843) / (tmp = 2781746479.850424
  tmp
  )) | (((((460850355.9211761) / ((((tmp = 626683450
  tmp
  ) << ((tmp = 1349974710
  tmp
  ) - ((tmp = -1349602292
  tmp
  ) / (-2199808871.1229663)))) >> ((x / (-3092436372.3078623)) & (tmp = -1190631012.0323825
  tmp
  ))) ^ ((-2907082828.4552956) - (tmp = 1858683340.1157017
  tmp
  )))) ^ (-1513755598.5398848)) % x) / x)) & (1147739260.136806))))
  assertEquals 0, x &= (tmp = -3047356844.109563
  tmp
  )
  assertEquals 637934616, x -= (tmp = -637934616
  tmp
  )
  assertEquals -1553350083, x ^= (-2056266203.094929)
  assertEquals -0.13467351026547192, x %= ((tmp = 824736251
  tmp
  ) / (2544186314))
  assertEquals 1, x /= x
  assertEquals 1, x |= x
  assertEquals 0, x >>>= (2166609431.9515543)
  assertEquals 0, x <<= (x | (tmp = 121899222.14603412
  tmp
  ))
  assertEquals 0, x *= (1300447849.6595674)
  assertEquals 0, x %= (tmp = -2360500865.3944597
  tmp
  )
  assertEquals 0, x %= (tmp = -1693401247
  tmp
  )
  assertEquals 0, x >>= x
  assertEquals 0, x /= (471265307)
  assertEquals 257349748, x ^= (257349748.689448)
  assertEquals 257349748, x &= x
  assertEquals 981, x >>>= (tmp = -1959001422
  tmp
  )
  assertEquals 0, x >>= ((-79932778.18114972) / x)
  assertEquals 0, x <<= (((-2599621472) ^ (tmp = 662071103
  tmp
  )) % (tmp = -2675822640.7641535
  tmp
  ))
  assertEquals 0, x &= (tmp = 2582354953.878623
  tmp
  )
  assertEquals 0, x /= ((-953254484) / ((-2571632163.376176) - (tmp = -342034471
  tmp
  )))
  assertEquals 0, x <<= ((x - (tmp = -3013057672
  tmp
  )) & (tmp = -3204761036
  tmp
  ))
  assertEquals 0, x ^= ((x & ((515934453) >>> x)) / x)
  assertEquals 1, x |= ((-1914707646.2075093) >>> (tmp = -1918045025
  tmp
  ))
  assertEquals -2002844120.8792589, x += (tmp = -2002844121.8792589
  tmp
  )
  assertEquals 573030794, x >>>= (tmp = 1707788162
  tmp
  )
  assertEquals 1.917619109627369, x /= ((1909436830.484202) % ((123114323) << (tmp = -1288988388.6444468
  tmp
  )))
  assertEquals -1400358045, x |= (-1400358046)
  assertEquals -2043022529.4273133, x += (tmp = -642664484.4273133
  tmp
  )
  assertEquals -81408068.86728716, x %= (tmp = -980807230.2800131
  tmp
  )
  assertEquals 0.1436896445024992, x /= (((tmp = 3201789924.913518
  tmp
  ) % (tmp = -962242528.6008646
  tmp
  )) ^ ((tmp = -338830119.55884504
  tmp
  ) * (tmp = -916120166
  tmp
  )))
  assertEquals 0.1436896445024992, x %= (tmp = 2598469263
  tmp
  )
  assertEquals 0, x *= (x - x)
  assertEquals -1409286144, x += (((-111514798.64745283) | (2372059654)) << (tmp = 175644313
  tmp
  ))
  assertEquals -2393905467.0073113, x += (-984619323.0073113)
  assertEquals -835111172.0073113, x %= (x ^ (-765900532.5585573))
  assertEquals -835111172.0073113, x %= (tmp = -946478116
  tmp
  )
  assertEquals -100, x >>= ((-1020515908) >> (((x & ((x ^ (169474253.53811646)) >> (-221739002))) + x) * ((201939882.92880356) / (tmp = -50402570
  tmp
  ))))
  assertEquals 2131506964, x &= (tmp = -2163460268
  tmp
  )
  assertEquals 1074275840, x &= ((-1561930379.8719592) * (tmp = -2871750052.876917
  tmp
  ))
  assertEquals -954232605.5377102, x -= (tmp = 2028508445.5377102
  tmp
  )
  assertEquals -29, x >>= (-279577351.87217045)
  assertEquals -232, x <<= x
  assertEquals -70, x |= (215185578)
  assertEquals -1, x >>= (x >> (-1691303095))
  assertEquals 1, x /= x
  assertEquals 3149465364.2236686, x *= (3149465364.2236686)
  assertEquals 3304787832.3790073, x += (tmp = 155322468.15533853
  tmp
  )
  assertEquals 100068712.23500109, x %= (tmp = 3204719120.1440063
  tmp
  )
  assertEquals 91628864, x &= (tmp = 629090241
  tmp
  )
  assertEquals -113202292046379710, x *= (-1235443583)
  assertEquals 122, x >>>= (tmp = 3196555256
  tmp
  )
  assertEquals 122, x >>>= (((2226535734) - x) ^ (2248399036.393125))
  assertEquals 6.904199169070746e-8, x /= (tmp = 1767040564.9149356
  tmp
  )
  assertEquals -212687449.99999994, x += ((((2244322375) * (((2515994102) ^ x) >> x)) << (x - (-832407685.3251972))) ^ (2266670502))
  assertEquals 366515938514778750, x *= (tmp = -1723260768.3940866
  tmp
  )
  assertEquals 366515938514778750, x += ((-1643386193.9159095) / (tmp = 425161225.95316494
  tmp
  ))
  assertEquals 654872716.4123061, x /= ((-1377382984) - (tmp = -1937058061.811642
  tmp
  ))
  assertEquals 654872716, x &= x
  assertEquals -86260926.17813063, x -= (tmp = 741133642.1781306
  tmp
  )
  assertEquals 1052176592, x >>>= x
  assertEquals 2020882856, x ^= (-3107796616)
  assertEquals 0, x <<= ((606939871.9812952) | (tmp = -3127138319.1557302
  tmp
  ))
  assertEquals NaN, x -= ((x % ((1120711400.2242608) % x)) * (tmp = -930171286.7999947
  tmp
  ))
  assertEquals NaN, x %= (3215044180)
  assertEquals NaN, x %= (tmp = 2882893804.20102
  tmp
  )
  assertEquals NaN, x %= ((217170359.5778643) ^ x)
  assertEquals 0, x &= ((-1095125960.9903677) >> (x ^ (-2227981276)))
  assertEquals -748549860, x += (-748549860)
  assertEquals 1816208256, x <<= (-610872411.3826082)
  assertEquals 201400576, x &= (((tmp = 1910394603.4836266
  tmp
  ) << x) ^ x)
  assertEquals 0, x %= x
  assertEquals NaN, x %= x
  assertEquals 0, x <<= (((((2670901339.6696005) % (2180020861)) * ((2134469504) / (2237096063.0680027))) * ((tmp = 1203829756
  tmp
  ) >> ((765467065) + (x | (2673651811.9494815))))) << ((-1463378514) | (((x / (tmp = -1075050081
  tmp
  )) - ((-879974865) + x)) >>> (tmp = 2172883926
  tmp
  ))))
  assertEquals 433013198, x ^= (433013198.2833413)
  assertEquals 0, x >>= ((((-2404431196) % (x % (tmp = 1443152875.8809233
  tmp
  ))) & (x | ((1414364997.0517852) / ((tmp = -435854369
  tmp
  ) + (tmp = 2737625141
  tmp
  ))))) | (((tmp = 2241746562.2197237
  tmp
  ) ^ (tmp = -1606928010.1992552
  tmp
  )) | ((tmp = -3083227418.686173
  tmp
  ) >> (tmp = -2717460410
  tmp
  ))))
  assertEquals 0, x >>= x
  assertEquals 0, x *= ((tmp = 2302521322
  tmp
  ) >>> (((((((tmp = 344089066.9725498
  tmp
  ) % (tmp = 1765830559
  tmp
  )) - x) | x) ^ (((-2450263325) / (tmp = 371928405.17475057
  tmp
  )) >>> (1330100413.7731652))) ^ (((173024329) % (tmp = -2927276187
  tmp
  )) + (x >>> (-1042229940.308507)))) | (((((tmp = 379074096
  tmp
  ) + ((142762508) - ((-2773070834.526266) - (x & ((tmp = 57957493
  tmp
  ) << (2189553500)))))) + ((36991093) + (tmp = 339487168.58069587
  tmp
  ))) * (-1257565451)) & (tmp = 645233114
  tmp
  ))))
  assertEquals -2644503151.1185284, x += (-2644503151.1185284)
  assertEquals -5289006302.237057, x += x
  assertEquals -4008773824.2370567, x -= (tmp = -1280232478
  tmp
  )
  assertEquals 1975449413, x |= ((tmp = 1957832005.4285066
  tmp
  ) >> ((1681236712.9715524) & (-675823978)))
  assertEquals -146472960, x <<= (-648510672.5644083)
  assertEquals -3, x |= (((((x >>> (tmp = 2271744104
  tmp
  )) + (tmp = -210058133.30147195
  tmp
  )) + (tmp = -2827493425
  tmp
  )) / (tmp = 765962538
  tmp
  )) % (tmp = 1048631551
  tmp
  ))
  assertEquals 1, x /= x
  assertEquals 0, x >>= (1070524782.5154183)
  assertEquals 0, x <<= (462502504)
  assertEquals 0, x %= (540589670.0730014)
  assertEquals NaN, x %= x
  assertEquals NaN, x /= ((-1268640098) % x)
  assertEquals NaN, x %= (1741157613.744652)
  assertEquals NaN, x += x
  assertEquals NaN, x %= ((x | (tmp = 1992323492.7000637
  tmp
  )) * x)
  assertEquals NaN, x /= ((tmp = -2271503368.0341196
  tmp
  ) >> ((tmp = 1224449194
  tmp
  ) >>> (tmp = 2976803997
  tmp
  )))
  assertEquals NaN, x += (tmp = -1078313742.1633894
  tmp
  )
  assertEquals NaN, x += (-787923311)
  assertEquals NaN, x %= x
  assertEquals -1299878219, x ^= (2995089077)
  assertEquals 536887953, x &= ((625660571.2651105) & (x ^ (((tmp = 950150725.2319129
  tmp
  ) + (-2122154205.466675)) / (tmp = 1754964696.974752
  tmp
  ))))
  assertEquals 4096, x >>>= x
  assertEquals 1, x /= x
  assertEquals -82508517, x ^= (((-930231800) % (tmp = -423861640.4356506
  tmp
  )) + x)
  assertEquals -82508517, x &= (x & x)
  assertEquals -479519, x %= ((tmp = 1861364600.595756
  tmp
  ) | x)
  assertEquals 479518, x ^= (((x >> (-1539139751.6860313)) >> (tmp = -456165734
  tmp
  )) | (-2786433531))
  assertEquals 959036, x += x
  assertEquals 29, x >>>= ((tmp = -1049329009.7632706
  tmp
  ) ^ (((((((1117739997) / (((-841179741.4939663) * (-1211599672)) >>> ((-413696355) % (tmp = -1753423217.2170188
  tmp
  )))) << (tmp = 1599076219.09274
  tmp
  )) >>> (-1382960317)) ^ (((x ^ (tmp = 515115394
  tmp
  )) >>> (tmp = -388476217
  tmp
  )) >>> (x / x))) ^ x) << (136327532.213817)))
  assertEquals 24, x &= (2388755418)
  assertEquals 0, x >>>= (tmp = -405535917
  tmp
  )
  assertEquals 0, x &= (tmp = -1427139674
  tmp
  )
  assertEquals NaN, x /= (x ^ ((1530470340) % x))
  assertEquals 0, x |= ((x >> (-1429690909.8472774)) * ((((tmp = 2033516515
  tmp
  ) / (1314782862)) >>> x) >> (tmp = 1737186497.6441216
  tmp
  )))
  assertEquals 0, x -= x
  assertEquals 0, x %= (3115422786)
  assertEquals -0, x *= (x + (tmp = -2558930842.267017
  tmp
  ))
  assertEquals NaN, x %= x
  assertEquals 0, x &= (2695531252.254449)
  assertEquals -613178182, x ^= (-613178182)
  assertEquals 54, x >>>= (x % (((tmp = 2277868389
  tmp
  ) ^ ((((tmp = -1143932265.3616111
  tmp
  ) ^ ((x & ((x - ((-2100384445.7850044) | (tmp = 908075129.3456883
  tmp
  ))) * x)) + (((tmp = 1031013284.0275401
  tmp
  ) * ((((tmp = -233393205
  tmp
  ) >>> (tmp = -111859419
  tmp
  )) * (-1199307178)) | (tmp = -1998399599
  tmp
  ))) >>> ((((-731759641.9036775) >>> (tmp = 2147849691
  tmp
  )) >>> (tmp = -2121899736
  tmp
  )) >>> (x >>> x))))) >> ((1900348757.360562) ^ (tmp = 2726336203.6149445
  tmp
  ))) >>> ((x * ((tmp = -2697628471.0234947
  tmp
  ) % ((x ^ (tmp = -2751379613.9474974
  tmp
  )) * x))) + (x >> (tmp = 42868998.384643435
  tmp
  ))))) + (598988941)))
  assertEquals 34, x &= ((tmp = 2736218794.4991407
  tmp
  ) % (2169273288.1339874))
  assertEquals 2.086197133417468, x /= ((tmp = 2176358852.297597
  tmp
  ) % x)
  assertEquals 2, x <<= (((tmp = -1767330075
  tmp
  ) | (-3107230779.8512735)) & x)
  assertEquals 4194304, x <<= (tmp = 1061841749.105744
  tmp
  )
  assertEquals 48609515, x ^= (44415211.320786595)
  assertEquals 48609515, x %= (1308576139)
  assertEquals 23735, x >>>= ((-324667786) - x)
  assertEquals 23735, x <<= ((-1270911229) << (((((tmp = -882992909.2692418
  tmp
  ) + (tmp = 394833767.947718
  tmp
  )) - x) << (702856751)) / x))
  assertEquals -31080872939240, x *= (tmp = -1309495384
  tmp
  )
  assertEquals -14625.31935626114, x /= ((668084131) + (1457057357))
  assertEquals -14625.31935626114, x %= (266351304.6585492)
  assertEquals -12577, x |= (-945583977.619837)
  assertEquals -4097, x |= ((tmp = -2621808583.2322493
  tmp
  ) - (tmp = -2219802863.9072213
  tmp
  ))
  assertEquals -1004843865, x &= ((-1004839768) + ((tmp = 2094772311
  tmp
  ) / (-1340720370.275643)))
  assertEquals -31401371, x >>= ((2035921047) >>> ((tmp = -1756995278
  tmp
  ) >>> (-537713689)))
  assertEquals 1791746374.016472, x -= ((tmp = -1823147745
  tmp
  ) - (x / (tmp = -1906333520
  tmp
  )))
  assertEquals 3.7289343120517406, x /= (tmp = 480498240
  tmp
  )
  assertEquals 7.457868624103481, x += x
  assertEquals 234881024, x <<= (-781128807.2532628)
  assertEquals 67108864, x &= (tmp = -2060391332
  tmp
  )
  assertEquals -605958718, x -= (673067582)
  assertEquals -605958718, x <<= ((x % x) & ((tmp = 1350579401.0801518
  tmp
  ) | x))
  assertEquals -109268090.4715271, x %= (tmp = -496690627.5284729
  tmp
  )
  assertEquals -109268090, x <<= (((-2004197436.8023896) % ((x | ((tmp = 271117765.61283946
  tmp
  ) - ((1595775845.0754795) * (555248692.2512416)))) / x)) << x)
  assertEquals -652725370, x &= (-543590449)
  assertEquals 0.321858133298825, x /= (tmp = -2027990914.2267523
  tmp
  )
  assertEquals 1959498446, x ^= (1959498446)
  assertEquals 1959498446, x &= (x % (tmp = 3155552362.973523
  tmp
  ))
  assertEquals 14949, x >>>= ((tmp = 586618136
  tmp
  ) >>> (tmp = 699144121.9458897
  tmp
  ))
  assertEquals -28611391568319.285, x *= (tmp = -1913933478.3811147
  tmp
  )
  assertEquals 1680557633, x &= (((tmp = 2606436319.199714
  tmp
  ) << (1575299025.6917372)) | ((-1092689109) / (735420388)))
  assertEquals 1680361024, x &= ((tmp = 1860756552.2186172
  tmp
  ) | (-360434860.1699109))
  assertEquals 820488, x >>>= (1788658731)
  assertEquals 820488, x >>= (-1555444352)
  assertEquals 2104296413, x ^= (2103543509)
  assertEquals 16843328, x &= ((x << ((-2920883149) / (1299091676))) - (((((tmp = 3199460211
  tmp
  ) + (-237287821.61504316)) & (tmp = -1524515028.3596857
  tmp
  )) - (tmp = -700644414.6785603
  tmp
  )) + (-180715428.86124516)))
  assertEquals 1326969834, x |= (tmp = -2968063574.793867
  tmp
  )
  assertEquals 0, x %= (x >>> (tmp = 1350490461.0012388
  tmp
  ))
  assertEquals 0, x &= ((-2620439260.902854) + x)
  assertEquals -1775533561, x |= ((-1775533561) | (((x >>> ((861896808.2264911) >>> (970216466.6532537))) % x) % (tmp = 2007357223.8893046
  tmp
  )))
  assertEquals -1775533561, x &= x
  assertEquals -23058877.415584415, x /= ((tmp = -3002439857
  tmp
  ) >> ((((x - (tmp = 1583620685.137125
  tmp
  )) | x) % (-2568798248.6863875)) ^ x))
  assertEquals -577.4155844151974, x %= (((-1440361053.047877) + ((tmp = 821546785.0910633
  tmp
  ) - (((tmp = 1023830881.1444875
  tmp
  ) / (-754884477)) + (tmp = 651938896.6258571
  tmp
  )))) >> (tmp = 346467413.8959185
  tmp
  ))
  assertEquals -1, x >>= (tmp = 2993867511
  tmp
  )
  assertEquals -1, x |= (tmp = 823150253.4916545
  tmp
  )
  assertEquals -0, x %= x
  assertEquals -0, x /= ((tmp = 997969036
  tmp
  ) & ((((tmp = 928480121
  tmp
  ) >> (((-2610875857.086055) >>> (tmp = -2251704283
  tmp
  )) | x)) + (10781750)) >> x))
  assertEquals 0, x >>>= ((tmp = -1872319523
  tmp
  ) >>> (-278173884))
  assertEquals 0, x |= (x / (x * x))
  assertEquals 0, x %= ((77912826.10575807) ^ (tmp = 2770214585.3019757
  tmp
  ))
  assertEquals 0, x &= (tmp = 722275824
  tmp
  )
  assertEquals -1417226266, x |= (tmp = 2877741030.1195555
  tmp
  )
  assertEquals 0, x ^= x
  assertEquals 0, x %= (tmp = -1740126105
  tmp
  )
  assertEquals 910709964, x |= (tmp = 910709964
  tmp
  )
  assertEquals -1744830464, x <<= (tmp = -2445932551.1762686
  tmp
  )
  assertEquals 318767104, x >>>= (tmp = -2465332061.628887
  tmp
  )
  assertEquals 301989888, x &= (-2771167302.022801)
  assertEquals 301989888, x |= x
  assertEquals 37748736, x >>= (tmp = -835820125
  tmp
  )
  assertEquals 1474977371, x ^= (tmp = -2857738661.6610327
  tmp
  )
  assertEquals 470467500, x += (-1004509871)
  assertEquals 0.30466562575942585, x /= (((tmp = 1515955042
  tmp
  ) << (x + ((1607647367) - (tmp = 1427642709.697169
  tmp
  )))) ^ x)
  assertEquals 1.0348231148499734e-10, x /= (tmp = 2944132397
  tmp
  )
  assertEquals 0, x >>= (x >>> (tmp = -2847037519.569043
  tmp
  ))
  assertEquals NaN, x /= x
  assertEquals 0, x >>>= (-1817784819.9058492)
  assertEquals 0, x >>= x
  assertEquals -0, x *= ((tmp = -1387748473
  tmp
  ) | (x + (352432111)))
  assertEquals -0, x *= (((-2591789329) / (tmp = -2144460203
  tmp
  )) >> (tmp = -568837912.5033123
  tmp
  ))
  assertEquals 0, x <<= (-2963600437.305708)
  assertEquals 0, x &= ((588720662) >>> x)
  assertEquals 1561910729, x += (1561910729)
  assertEquals 0, x ^= x
  assertEquals -0, x *= (-2722445702)
  assertEquals 0, x &= (tmp = -2738643199.732308
  tmp
  )
  assertEquals 0, x /= (((1859901899.227291) >>> ((tmp = -1067365693
  tmp
  ) + ((-1975435278) | x))) | ((1844023313.3719304) & (tmp = -624215417.0227654
  tmp
  )))
  assertEquals NaN, x %= x
  assertEquals NaN, x %= (-2852766277)
  assertEquals 0, x <<= (-1482859558)
  assertEquals 0, x >>= x
  assertEquals -1196775786, x += (tmp = -1196775786
  tmp
  )
  assertEquals -68176201, x |= ((tmp = 2336517643
  tmp
  ) + x)
  assertEquals 0, x ^= x
  assertEquals 0, x <<= x
  assertEquals 0, x >>= (2969141362.868086)
  assertEquals NaN, x %= x
  assertEquals 0, x >>= ((x - ((((tmp = -905994835
  tmp
  ) | (tmp = 2850569869.33876
  tmp
  )) << ((-2405056608.27147) >> (tmp = 1280271785
  tmp
  ))) & (-1942926558))) * (tmp = 707499803.177796
  tmp
  ))
  assertEquals 0, x &= ((-697565829.8780258) + ((2978584888.549406) % x))
  assertEquals 0, x >>= (748642824.4181392)
  assertEquals 0, x += x
  assertEquals 0, x >>>= (-1701028721)
  assertEquals 92042539, x -= ((-92042539) | (x * (x % (-293705541.00228095))))
  assertEquals 0, x %= x
  assertEquals 0, x >>= x
  assertEquals 0, x %= (-2278672472.458228)
  assertEquals 0, x %= (((-2374117528.0359464) / ((tmp = -2809986062
  tmp
  ) | (tmp = 895734980
  tmp
  ))) & (tmp = 1564711307.41494
  tmp
  ))
  assertEquals 0, x >>>= x
  assertEquals 0, x += x
  assertEquals -0, x /= ((tmp = -2749286790.3666043
  tmp
  ) << (x ^ (-2966741582.324482)))
  assertEquals 0, x *= x
  assertEquals 0, x >>>= x
  assertEquals -1882562314, x ^= (2412404982.782115)
  assertEquals -806620, x %= (((tmp = 1527219936.5232096
  tmp
  ) * (-1139841417)) >>> (tmp = 201632907.3236668
  tmp
  ))
  assertEquals -1613240, x += x
  assertEquals -1664766177387640, x *= (1031939561)
  assertEquals -9.478083550117849e+23, x *= (tmp = 569334221.1571662
  tmp
  )
  assertEquals -8.462574598319509e+21, x /= ((x - (tmp = -2985531211.114498
  tmp
  )) >> (tmp = 174615992.91117632
  tmp
  ))
  assertEquals 1638924288, x <<= (((((x >> ((-1823401733.4788911) + ((tmp = 1362371590
  tmp
  ) >>> x))) ^ (tmp = -56634380
  tmp
  )) / (tmp = 2387980757.1540084
  tmp
  )) % ((((tmp = -3175469977
  tmp
  ) ^ (tmp = -1816794042
  tmp
  )) + (232726694)) * (tmp = 822706176
  tmp
  ))) / (tmp = 1466729893.836311
  tmp
  ))
  assertEquals 2686072821796307000, x *= x
  assertEquals -1007977445.9812208, x /= (-2664814408.800125)
  assertEquals -1007977445, x &= x
  assertEquals 322314656346249100, x *= (tmp = -319763758.54942775
  tmp
  )
  assertEquals 197436885.26815608, x /= (tmp = 1632494637
  tmp
  )
  assertEquals -67191339, x |= ((-399580815.1746769) / ((1335558363) / (tmp = 224694526
  tmp
  )))
  assertEquals 1229588737, x &= (tmp = 1296763683.5732255
  tmp
  )
  assertEquals 1229588737, x -= ((((1171546503) | ((tmp = -2701891308
  tmp
  ) % (-2155432197.022206))) / (-306122816.85682726)) >> x)
  assertEquals 4162606632, x -= (tmp = -2933017895
  tmp
  )
  assertEquals 1.6487311395551163, x /= (2524733434.1748486)
  assertEquals -1929308648.9913044, x += (-1929308650.6400356)
  assertEquals -3858617297.982609, x += x
  assertEquals 788529152, x <<= (x ^ (1401824663))
  assertEquals 6160384, x >>>= ((((((x >>> x) >> ((((x * (tmp = -1958877151
  tmp
  )) >>> (1310891043)) - (tmp = 564909413.9962088
  tmp
  )) % (-175978438))) % x) | ((tmp = -1193552419.7837512
  tmp
  ) * (tmp = 1508330424.9068346
  tmp
  ))) | (1428324616.3303494)) - ((1828673751) / (tmp = 1281364779
  tmp
  )))
  assertEquals 6160384, x |= x
  assertEquals 1, x /= x
  assertEquals 1, x &= (tmp = -855689741
  tmp
  )
  assertEquals 0, x >>>= x
  assertEquals -1088569655.3528988, x -= (tmp = 1088569655.3528988
  tmp
  )
  assertEquals -1088569655, x >>= ((tmp = 2429646226.626727
  tmp
  ) << ((-1539293782.4487276) >> (x ^ ((tmp = 1140855945.537702
  tmp
  ) + x))))
  assertEquals -311, x %= ((x / x) << x)
  assertEquals 1.2007722007722008, x /= (x | (tmp = 448796341.87655175
  tmp
  ))
  assertEquals 3, x |= (x + x)
  assertEquals -9.32416092168023e-10, x /= (-3217447688)
  assertEquals 0, x >>= (615837464.0921166)
  assertEquals 0, x >>>= (tmp = -2993750670.683118
  tmp
  )
  assertEquals 0, x >>>= (x % x)
  assertEquals 1610612736, x ^= ((-1322905256.6770213) << (-2567950598))
  assertEquals 1693676493, x ^= (83063757.63660407)
  assertEquals -758030371, x ^= (tmp = -1239274480
  tmp
  )
  assertEquals -758030371, x %= (tmp = 1961339006
  tmp
  )
  assertEquals -1509754528, x ^= (tmp = 1960027837
  tmp
  )
  assertEquals -1509754528, x <<= x
  assertEquals -1509754528, x -= (((tmp = -50690205.33559728
  tmp
  ) / ((tmp = -1364565380
  tmp
  ) << (tmp = 2585052504
  tmp
  ))) << (tmp = -2356889596
  tmp
  ))
  assertEquals 1, x >>>= (-3204164321)
  assertEquals 1, x *= x
  assertEquals 1114370230.591965, x *= ((tmp = 1114370229.591965
  tmp
  ) + x)
  assertEquals -4.886305275432552, x /= ((-228059887.33344483) % (2841553631.3685856))
  assertEquals 2.358309397373389e-9, x /= (((x * (tmp = 203428818.08174622
  tmp
  )) & (x - (((510438355) * x) + x))) + x)
  assertEquals 0, x >>>= ((tmp = 1444810010
  tmp
  ) & (tmp = -3135701995.2235208
  tmp
  ))
  assertEquals 0, x /= (1865982928.6819582)
  assertEquals 0, x *= x
  assertEquals 2078726016.3772051, x -= (tmp = -2078726016.3772051
  tmp
  )
  assertEquals 1580337898, x ^= ((tmp = -2714629398.447015
  tmp
  ) ^ x)
  assertEquals 1268363034, x -= ((x + ((tmp = 1144068248.3834887
  tmp
  ) & (-954104940.155973))) << (tmp = 1270573731.7828264
  tmp
  ))
  assertEquals 1744830464, x <<= (((1444869551.7830744) >>> ((((x + (tmp = -904688528
  tmp
  )) << x) - ((tmp = 121151912.85873199
  tmp
  ) / (tmp = -2414150217.66479
  tmp
  ))) | (((-472906698) | (3215236833.8417764)) + (907737193.9056952)))) - ((x & (-732223723)) | (-221800427.7392578)))
  assertEquals 717338523283226600, x *= (x ^ (tmp = -2407450097.0604715
  tmp
  ))
  assertEquals 402653184, x >>= ((-3191405201.168252) * ((tmp = -1941299639.695196
  tmp
  ) | (((x >> (((3215741220) >>> x) / (x + x))) ^ (((tmp = -2144862025.9842231
  tmp
  ) | ((tmp = -1966913385
  tmp
  ) & x)) % x)) * ((tmp = -1124749626.6112225
  tmp
  ) / (tmp = 837842574
  tmp
  )))))
  assertEquals 402653184, x &= ((x | x) >> x)
  assertEquals 134217728, x &= ((2720231644.3849487) * x)
  assertEquals 134217726.75839183, x -= ((2438054684.738043) / (((((-984359711) * (x | ((tmp = 177559682
  tmp
  ) ^ x))) / (-1253443505)) / ((2727868438.416792) * (x + ((x << (((tmp = 3023774345
  tmp
  ) & (-705699616.0846889)) / x)) << x)))) ^ (1963626488.548761)))
  assertEquals 1, x /= x
  assertEquals 245781494, x += ((tmp = 2551445099
  tmp
  ) ^ (2528486814))
  assertEquals -1474427807, x ^= (-1497868393.342241)
  assertEquals -1057271682, x += ((((((x >> x) % (-1556081693)) | (x / (((1166243186.6325684) - (((tmp = 2870118257.1019487
  tmp
  ) / (x + (-69909960))) ^ (2270610694.671496))) / ((1463187204.5849519) - x)))) - x) - (x << (-3077313003))) % x)
  assertEquals -1065725846, x &= ((tmp = -1808223767
  tmp
  ) | (-481628214.3871765))
  assertEquals -1065725846, x ^= (x & (((tmp = -1785170598
  tmp
  ) - (tmp = -2525350446.346484
  tmp
  )) / ((((((-1783948056) ^ (tmp = 3027265884.41588
  tmp
  )) | ((((tmp = 2195362566.2237773
  tmp
  ) << (-2919444619)) << ((tmp = -2507253075.2897573
  tmp
  ) ^ (x ^ ((tmp = 1067516137
  tmp
  ) + ((667737752) ^ (x * (tmp = -1187604212.7293758
  tmp
  ))))))) % (-617406719.5140038))) * (tmp = 511060465.6632478
  tmp
  )) * ((tmp = 2580189800.752836
  tmp
  ) | ((((tmp = 2357895660
  tmp
  ) % ((-814381220) * (x - ((x >>> (((x << x) << (tmp = 1919573020
  tmp
  )) - x)) >>> ((-2756011312.136148) >> (tmp = -1603458856
  tmp
  )))))) / ((tmp = -1609199312
  tmp
  ) & (-3127643445))) % x))) << (-2261731798))))
  assertEquals 1.6020307924030301, x /= (tmp = -665234308.2628405
  tmp
  )
  assertEquals -1120020556.697667, x *= (tmp = -699125486.2321637
  tmp
  )
  assertEquals -215875188, x -= (((((tmp = -1307845034
  tmp
  ) >>> ((((-2820720421) ^ x) - (((x << x) | (tmp = -3042092997.57406
  tmp
  )) + (((-1294857544) + ((tmp = -668029108.1487186
  tmp
  ) >> (x << x))) ^ (912144065.5274727)))) ^ (389671596.2983854))) | (-2774264897.146559)) % (x - ((tmp = 1378085269
  tmp
  ) ^ x))) + ((-1659377450.5247462) & (((1613063452.834885) >>> ((-344896580.0694165) >>> ((-13450558) + x))) ^ x)))
  assertEquals 1, x /= x
  assertEquals 0, x >>>= (2355750790)
  assertEquals 1969435421.4409347, x += (1969435421.4409347)
  assertEquals 0, x -= x
  assertEquals 0, x >>>= (((x * ((-1022802960.6953495) << (tmp = -2848428731.8339424
  tmp
  ))) ^ (-1630921485)) % (1532937011))
  assertEquals 0, x <<= ((x + ((x ^ (x ^ (tmp = 2017651860
  tmp
  ))) & (((x << (((tmp = -1913317290.8189478
  tmp
  ) | (x - ((((x % ((tmp = -3035245210
  tmp
  ) + (-2270863807))) >>> ((-2351852712) * (x ^ (-2422943296.0239563)))) & ((((-1578312517) % x) * x) * (-65592270.28452802))) >>> (tmp = 1104329727.2094703
  tmp
  )))) - (tmp = -1431159990.3340137
  tmp
  ))) & x) | ((tmp = -2589292678.801344
  tmp
  ) & (x + ((((tmp = -2557773457.456996
  tmp
  ) >> (451910805.309445)) - x) >> (((tmp = -1937832765.7654495
  tmp
  ) ^ x) % x))))))) % x)
  assertEquals 0, x %= (tmp = -626944459
  tmp
  )
  assertEquals -732310021, x |= (tmp = -732310021
  tmp
  )
  assertEquals -732310021, x |= x
  assertEquals 671352839, x ^= (x - ((-3087309090.7153115) | x))
  assertEquals 134479872, x &= (tmp = 2357183984
  tmp
  )
  assertEquals 18084835973136384, x *= x
  assertEquals 0, x <<= ((1040482277) - (tmp = -357113781.82650447
  tmp
  ))
  assertEquals 74957, x |= ((((tmp = -70789345.7489841
  tmp
  ) % (tmp = 1415750131
  tmp
  )) & x) | ((307027314) >> (2284275468)))
  assertEquals 9, x >>>= x
  assertEquals 0, x &= (x & ((x * ((x * (x % x)) % (x >> x))) / x))
  assertEquals -1872875060, x |= (2422092236.6850452)
  assertEquals 9, x >>>= (-382763684)
  assertEquals 4608, x <<= x
  assertEquals 40.480234260614935, x /= (((((((tmp = 814638767.5666755
  tmp
  ) & ((tmp = 2081507162
  tmp
  ) ^ (x >>> (1460148331.2229118)))) & (tmp = 1187669197.7318723
  tmp
  )) << (412000677.93339765)) ^ ((tmp = 556111951
  tmp
  ) >> (tmp = -2232569601.292395
  tmp
  ))) & (-3006386864)) / x)
  assertEquals 32, x &= (-3053435209.383913)
  assertEquals 418357217, x ^= (418357185)
  assertEquals 204275, x >>= ((-1188650337.9010527) ^ ((51494580) % (-2544545273)))
  assertEquals 982392804, x += (((x + (((tmp = -982596937.9757051
  tmp
  ) + x) % (-2298479347))) ^ ((((tmp = 1610297674.0732534
  tmp
  ) >>> x) * (((x >> (-2746780903.08599)) & (-2376190704.247188)) ^ (((20545353) / (tmp = 1468302977
  tmp
  )) - (x << x)))) >> (((-1434332028.0447056) / ((tmp = 1983686888
  tmp
  ) & ((tmp = 2324500847
  tmp
  ) % (394330230.6163173)))) % (((-1129687479.2158055) + ((-3127595161) * ((-3066570223) & ((tmp = 3192134577.4963055
  tmp
  ) / (-2697915283.3233275))))) + (-1112243977.5306559))))) | (x & (-2622725228)))
  assertEquals -2735750653096133600, x *= (-2784782870.9218984)
  assertEquals -1876329472, x |= ((((((2752866171) << (-1681590319)) / x) >> ((tmp = 1451415208
  tmp
  ) >>> (1126858636.6634417))) + (((tmp = 2165569430.4844217
  tmp
  ) / x) ^ (((tmp = -1675421843.4364457
  tmp
  ) - (-2187743422.2866993)) | x))) * x)
  assertEquals 3520612287495799000, x *= x
  assertEquals -200278016, x |= ((((-2379590931) % ((((-1558827450.833285) & x) >> (-665140792)) - ((tmp = -445783631.05567217
  tmp
  ) + (tmp = 93938389.53113222
  tmp
  )))) / (3103476273.734701)) ^ x)
  assertEquals -9178285062592.75, x *= ((2042671875.7211144) % (((tmp = 589269308.0452716
  tmp
  ) / x) << (-130695915.9934752)))
  assertEquals 60048960, x |= (x << x)
  assertEquals 60048960, x <<= ((((((tmp = -2793966650
  tmp
  ) / (-2882180652)) & (((x << ((tmp = -384468710
  tmp
  ) + (2236162820.9930468))) >>> ((((969371919) >> ((tmp = -3153268403.2565875
  tmp
  ) - ((((573811084) / x) ^ (tmp = -968372697.4844134
  tmp
  )) >>> (((-3096129189) >> x) / (tmp = 830228804.6249363
  tmp
  ))))) << (((1243972633.3592157) | x) & ((-1687610429) & (tmp = -1945063977.458529
  tmp
  )))) << (((tmp = -217456781.37068868
  tmp
  ) - (400259171.68077815)) ^ x))) >>> x)) % (((2728450651.300167) / (((-2713666705.089135) % (tmp = 740472459
  tmp
  )) ^ x)) | x)) ^ x) * (-2463032364))
  assertEquals 60048960, x %= (tmp = -442107222.9513445
  tmp
  )
  assertEquals -1573781504, x <<= (960581227)
  assertEquals 1297, x >>>= (tmp = -1692919563
  tmp
  )
  assertEquals 1297, x &= x
  assertEquals -3113308397155.233, x *= (tmp = -2400391979.3024154
  tmp
  )
  assertEquals -3115513013486.233, x -= (2204616331)
  assertEquals -3113809649082.233, x -= (-1703364404)
  assertEquals 0, x >>>= (((-1181206665) - (550946816.586771)) | (tmp = -2346300456
  tmp
  ))
  assertEquals 0, x %= (tmp = 1649529739.2785435
  tmp
  )
  assertEquals 0, x ^= ((tmp = -2452761827.2870226
  tmp
  ) % (((1090281070.5550141) / (tmp = 992149154.6500508
  tmp
  )) * (x << ((((((x >>> x) | ((tmp = -2410892363
  tmp
  ) % (tmp = 2585150431.0231533
  tmp
  ))) / x) * (tmp = 1541294271
  tmp
  )) + x) & ((97566561.77126992) & ((((-640933510.1287451) & (((((x >>> ((-1821077041) << ((tmp = -1138504062.093695
  tmp
  ) - (tmp = -181292160
  tmp
  )))) % x) - (x >> ((x & (((tmp = 1067551355
  tmp
  ) / (x | (1004837864.8550552))) & (x - (-103229639.25084043)))) & ((tmp = 2064184671.210937
  tmp
  ) + ((((tmp = -2245728052
  tmp
  ) | (1538407002.8365717)) + (x << ((x >> ((76549490) / (tmp = 628901902.6084052
  tmp
  ))) << ((x << x) ^ (-1907669184))))) + (-1409123688)))))) >>> ((((-1911547456.933543) - ((-512313175) + ((tmp = -2620903017
  tmp
  ) ^ (tmp = 2148757592.244808
  tmp
  )))) << ((-1740876865) >>> x)) + ((tmp = 691314720.9488736
  tmp
  ) << (614057604.4104803)))) | (x ^ ((tmp = -3040687.291528702
  tmp
  ) / (x ^ (((x + (-2899641915)) ^ ((tmp = -1220211746
  tmp
  ) / x)) % x)))))) ^ (tmp = 119850608
  tmp
  )) % (2091975696)))))))
  assertEquals 291273239, x -= (tmp = -291273239
  tmp
  )
  assertEquals 2206394018, x += (1915120779)
  assertEquals 235641480, x <<= (x & (x & (-1810963865.1415658)))
  assertEquals 28764, x >>= ((tmp = -1927011875
  tmp
  ) ^ ((tmp = -1986461808
  tmp
  ) | ((-868139264.8399222) * ((421956566) % (3068424525)))))
  assertEquals -99780626900900, x *= ((tmp = -1512869526.3223472
  tmp
  ) + (tmp = -1956071751
  tmp
  ))
  assertEquals 51218520, x &= (((-2353401311) >>> x) - (2216842509))
  assertEquals 51218520, x >>>= ((tmp = -1534539302.6990812
  tmp
  ) << x)
  assertEquals -2147483648, x <<= (-292608644)
  assertEquals -2147483648, x |= ((((((x << ((-2981292735) - x)) >> ((tmp = 2540545320.96558
  tmp
  ) & (tmp = -2343790880
  tmp
  ))) >>> ((((((x ^ ((-172697043.94487858) / ((2627260337) >> (2879112814.1247935)))) & (tmp = 3000943191
  tmp
  )) << (tmp = 1094830905
  tmp
  )) - x) >>> x) >> ((((tmp = 3095796200
  tmp
  ) ^ (x | (tmp = 1460377694
  tmp
  ))) << (x ^ (tmp = -357546193
  tmp
  ))) / ((2729539495) >> x)))) % (tmp = 268894171.74961245
  tmp
  )) | (x >> (tmp = 2735650924
  tmp
  ))) / (-2197885357.09768))
  assertEquals -2147483648, x |= x
  assertEquals -1967162776824578000, x *= (tmp = 916031551
  tmp
  )
  assertEquals -2147483648, x &= x
  assertEquals -457743917756973060, x *= (tmp = 213153622
  tmp
  )
  assertEquals 0, x >>>= ((((tmp = 2930076928.480559
  tmp
  ) + (x ^ x)) << (tmp = -1349755597.1280541
  tmp
  )) | (x + (2865632849)))
  assertEquals 0, x <<= ((x >> x) - (x >> (-2629977861)))
  assertEquals 0, x <<= x
  assertEquals NaN, x /= x
  assertEquals 0, x |= x
  assertEquals 0, x >>>= x
  assertEquals 749327478, x |= ((tmp = 749327478
  tmp
  ) ^ (x >> (tmp = 881107862
  tmp
  )))
  assertEquals 1897869364, x += (1148541886)
  assertEquals 463347, x >>>= (tmp = -726431220
  tmp
  )
  assertEquals -395990542, x += (-396453889)
  assertEquals -2824792585.1675367, x -= (2428802043.1675367)
  assertEquals -2147483648, x <<= (tmp = -1420072385.9175675
  tmp
  )
  assertEquals 8388608, x >>>= (-2211390680.488455)
  assertEquals 8388608, x >>= (((x / (x | (((x ^ (((tmp = -2175960170.8055067
  tmp
  ) | ((tmp = -1964957385.9669886
  tmp
  ) / (tmp = -475033330
  tmp
  ))) & ((x | ((tmp = 1386597019.2014387
  tmp
  ) >> ((tmp = -2406589229.8801174
  tmp
  ) + x))) << (tmp = -844032843.8415492
  tmp
  )))) >> (x ^ x)) | x))) - ((x & ((tmp = 1858138856
  tmp
  ) * (-3156357504))) % x)) << (((2046448340) + x) / (-2645926916)))
  assertEquals 8359470765396279, x *= ((tmp = 871437183.7888144
  tmp
  ) - (-125089387.17460155))
  assertEquals 0, x ^= x
  assertEquals -303039014, x += ((tmp = -2475713214
  tmp
  ) | (-372871718.2343409))
  assertEquals 2655126577, x -= (-2958165591)
  assertEquals 1830332793, x ^= (tmp = -212161208
  tmp
  )
  assertEquals 1830332793, x ^= (((2352454407.0126333) << ((((tmp = 3083552367
  tmp
  ) / x) - (-1243111279)) - ((tmp = -1669093976
  tmp
  ) % (((-757485455) - (tmp = -116051602
  tmp
  )) << x)))) >> (((((-2235071915.9536905) >> (tmp = -1284656185
  tmp
  )) - x) >> ((-1807028069.7202528) >>> ((x % ((tmp = -3070857953.311804
  tmp
  ) + ((tmp = 2759633693.441942
  tmp
  ) % ((169489938) * (-1582267384))))) << (x ^ ((tmp = -787578860
  tmp
  ) << x))))) >> ((x / (x | (409464362))) - (tmp = -64033017
  tmp
  ))))
  assertEquals 397605933.90319204, x %= (tmp = 716363429.548404
  tmp
  )
  assertEquals 186400, x &= (((x % (-1745754586)) >>> x) << (x & (x & ((-2163627752) - ((1784050895) + (((-2864781121.899456) >>> x) & x))))))
  assertEquals 186400, x %= (tmp = -423209729
  tmp
  )
  assertEquals 186400, x <<= ((x << (x + (1232575114.4447284))) * x)
  assertEquals 1386299, x ^= ((tmp = -1074209615
  tmp
  ) >>> (x >>> ((tmp = -1456741008.2654872
  tmp
  ) >> ((1724761067) >> (-2016103779.9084842)))))
  assertEquals 347302967.20758367, x -= (-345916668.20758367)
  assertEquals 1.9325619389304094, x /= (179711170.03359854)
  assertEquals -3703324711.628227, x *= (tmp = -1916277371
  tmp
  )
  assertEquals -920980517031624800, x *= (tmp = 248690187.53332615
  tmp
  )
  assertEquals 0, x &= (((tmp = -2753945953.082594
  tmp
  ) * x) - (172907186))
  assertEquals -0, x /= (((((-2744323543.187253) >> ((tmp = 2663112845
  tmp
  ) >> (((-121791600) + (x ^ x)) * (2758944252.4214177)))) | x) / (tmp = -2746716631.6805267
  tmp
  )) - x)
  assertEquals 0, x ^= ((tmp = 983113117
  tmp
  ) & ((2638307333) + ((((tmp = 3076361304.56189
  tmp
  ) << (-2663410588.5895214)) % ((-1109962112) - (tmp = -2381021732
  tmp
  ))) % ((tmp = 410559095
  tmp
  ) & x))))
  assertEquals 0, x <<= (tmp = 1510895336.5111506
  tmp
  )
  assertEquals 0, x <<= (tmp = -1688348296.2730422
  tmp
  )
  assertEquals 2269471424, x -= (-2269471424)
  assertEquals -2022580224, x ^= (x % ((tmp = 160999480.21415842
  tmp
  ) & x))
  assertEquals -2077171712, x &= (tmp = 3032415014.3817654
  tmp
  )
  assertEquals 270727, x >>>= (2973489165.1553965)
  assertEquals 270727, x |= x
  assertEquals -1895894537, x |= ((tmp = -1895903118.129186
  tmp
  ) | x)
  assertEquals -1895894537, x -= ((((((((3143124509) >>> (-2866190144.8724117)) * ((x >> ((961021882) * (tmp = 2363055833.8634424
  tmp
  ))) / ((2032785518) + ((2713643671.3420825) >> ((-447782997.0173557) * ((tmp = 1174918125.3178625
  tmp
  ) * ((((tmp = -541539365.548115
  tmp
  ) % (-359633101)) | (1765169562.2880063)) + (tmp = -2512371966.374508
  tmp
  )))))))) / x) >> (x * ((((-847238927.6399388) & (857288850)) % (-2427015402)) ^ ((2221426567) % (x + x))))) >>> x) << ((tmp = 2009453564.2808268
  tmp
  ) >> ((2924411494) << (x >> (tmp = -1240031020.8711805
  tmp
  ))))) % (tmp = 3118159353
  tmp
  ))
  assertEquals 0, x ^= x
  assertEquals 0, x %= (-30151583)
  assertEquals -1035186736, x ^= ((tmp = -517593368
  tmp
  ) << (tmp = 3216155585
  tmp
  ))
  assertEquals 49740, x >>>= x
  assertEquals 49740, x %= (640223506)
  assertEquals 388, x >>>= ((x >> (tmp = 3161620923.50496
  tmp
  )) + (2605183207))
  assertEquals 776, x += x
  assertEquals -97905, x ^= ((((((tmp = 145447047.8783008
  tmp
  ) ^ (((x >>> (tmp = 3014858214.2409887
  tmp
  )) >>> (629911626.132971)) >> (((x + ((369309637.229408) - x)) << (-2661038814.9204755)) * (x + (x % (3025191323.4780884)))))) + x) * (-482550691)) | (-632782135)) / x)
  assertEquals -97905, x %= ((((-492914681) - ((-2508632959.269368) & (tmp = 1209318291
  tmp
  ))) >> (-723512989.459533)) >>> (((-528429623.985692) & (x ^ (tmp = -925044503
  tmp
  ))) - (-1696531234)))
  assertEquals 9585389025, x *= x
  assertEquals -715425728, x <<= ((583763091) << (-1223615295))
  assertEquals -520093696, x <<= ((tmp = -1891357699.671592
  tmp
  ) * (((tmp = 3206095739.5163193
  tmp
  ) + (-2908596651.798733)) >>> ((tmp = -2820415686
  tmp
  ) >> (x | ((((tmp = -566367675.6250327
  tmp
  ) * (-959117054)) >> ((((-187457085.89686918) * x) * (tmp = -2394776877.5373516
  tmp
  )) >>> x)) | (((tmp = 80478970.46290505
  tmp
  ) << (tmp = 2173570349.493097
  tmp
  )) - (x / ((-2896765964) - ((x / ((tmp = 198741535.7034216
  tmp
  ) % (436741457))) % (tmp = 2936044280.0587225
  tmp
  ))))))))))
  assertEquals -2520.5909527086624, x /= ((211290893.06029093) >> (663265322))
  assertEquals -2520.5909527086624, x %= (x ^ ((1057915688) << (tmp = 1914820571.1142511
  tmp
  )))
  assertEquals 1, x >>>= (((894963408.7746166) + (tmp = -2888351666
  tmp
  )) | x)
  assertEquals -1989841636629996300, x += ((1424670316.224575) * ((-2144149843.0876865) | ((((421479301.0983993) | ((3082651798) ^ (tmp = -271906497
  tmp
  ))) >> x) + ((tmp = -178372083
  tmp
  ) % x))))
  assertEquals 17935384255.088326, x /= (((((((tmp = 1168194849.2361898
  tmp
  ) >>> (-107316520.53815603)) >>> (x ^ (((x % ((x >>> (((-2456622387) / x) & ((2124689803) | (((-1130151701) ^ (2796315158)) >> x)))) - ((-884686033.5491502) >>> ((-2371185318.5358763) & x)))) + (tmp = 558422989
  tmp
  )) | ((tmp = -420359120.0596726
  tmp
  ) / ((-1820568437.0587764) & (2298602280.266465)))))) >> (x - ((tmp = -1164568978
  tmp
  ) ^ x))) ^ x) - x) + x)
  assertEquals 134233150, x &= ((x >> (((tmp = 98498118.13041973
  tmp
  ) - (804574397)) / (tmp = -1564490985.7904541
  tmp
  ))) + x)
  assertEquals 4, x >>= (449610809)
  assertEquals 1912543790, x |= (1912543790)
  assertEquals 2487274263, x += (tmp = 574730473
  tmp
  )
  assertEquals -2140759118, x ^= (tmp = 338055333.9701035
  tmp
  )
  assertEquals 311607367, x += (2452366485)
  assertEquals 9509, x >>= (372113647.84365284)
  assertEquals -2001075684.1562128, x += (-2001085193.1562128)
  assertEquals -638703280, x ^= (((tmp = 1096152237
  tmp
  ) & x) | ((2707404245.0966487) - (((tmp = 1550233654.9691348
  tmp
  ) + (tmp = 2008619647
  tmp
  )) & ((tmp = -2653266325
  tmp
  ) + (tmp = -280936332
  tmp
  )))))
  assertEquals -101811850, x |= (-2250090202)
  assertEquals -13, x >>= ((-561312810.0218933) | (tmp = 79838949.86521482
  tmp
  ))
  assertEquals -13, x >>= ((tmp = -936543584
  tmp
  ) / (1180727664.1746705))
  assertEquals -1547, x *= (((tmp = 1005197689
  tmp
  ) >>> x) >>> (tmp = 34607588
  tmp
  ))
  assertEquals 2393209, x *= x
  assertEquals 2393209, x |= x
  assertEquals 0, x >>= (-2691279235.1215696)
  assertEquals 0, x *= (((896175510.4920144) * ((((tmp = 1770236555.7788959
  tmp
  ) % (537168585.7310632)) / x) & (tmp = 1094337576
  tmp
  ))) & (((x - x) - x) >> x))
  assertEquals -1922620126, x ^= (-1922620126)
  assertEquals 3.43481396325761, x /= (tmp = -559745053.6088333
  tmp
  )
  assertEquals 0, x >>= x
  assertEquals 0, x >>>= (tmp = 2106956255.6602135
  tmp
  )
  assertEquals -1339003770, x ^= ((tmp = 2955963526.960022
  tmp
  ) + x)
  assertEquals -0, x *= ((((tmp = 368669994
  tmp
  ) >>> (x * x)) << (tmp = 2355889375
  tmp
  )) & (tmp = -2267550563.9174895
  tmp
  ))
  assertEquals 0, x >>= (753848520.8946902)
  assertEquals 0, x >>>= x
  assertEquals 0, x %= ((tmp = -2872753234.2257266
  tmp
  ) | x)
  assertEquals NaN, x %= (x >>> (tmp = 890474186.0898918
  tmp
  ))
  assertEquals NaN, x %= ((tmp = 1341133992.284471
  tmp
  ) & (tmp = -2979219283.794898
  tmp
  ))
  assertEquals NaN, x += (-2865467651.1743298)
  assertEquals NaN, x += ((-1424445677) % (x ^ (tmp = 1150366884
  tmp
  )))
  assertEquals 0, x &= (x + ((tmp = 1499426534
  tmp
  ) + x))
  assertEquals 0, x |= (((((tmp = -2413914642
  tmp
  ) << ((x >>> x) ^ (1218748804))) + ((((-1085643932.2642736) - (-1199134221.533854)) >> (tmp = 2148778719
  tmp
  )) - ((tmp = 1589158782.0040946
  tmp
  ) / (tmp = -2485474016.1575155
  tmp
  )))) >>> (x >> x)) / (2230919719))
  assertEquals 0, x %= ((tmp = -2576387170.517563
  tmp
  ) >>> ((tmp = -2362334915.919525
  tmp
  ) >>> (((3096453582) - (700067891.4834484)) ^ (2396394772.9253683))))
  assertEquals -1798103432, x ^= (((((tmp = 2396144191
  tmp
  ) * (x >>> (1512158325))) & (((-1256228298.5444434) & (((-2963136043.434966) & ((tmp = 2472984854
  tmp
  ) + (tmp = -454900927
  tmp
  ))) % (tmp = 484255852.65332687
  tmp
  ))) >> ((x % x) - x))) & (tmp = 929723984
  tmp
  )) ^ (tmp = -1798103432.5838807
  tmp
  ))
  assertEquals -2137913344, x &= ((((x | (-2970116473)) & (((x / x) / ((tmp = 2853070005
  tmp
  ) >>> x)) % (((tmp = -3123344846
  tmp
  ) / ((2224296621.6742916) - (tmp = -2246403296.455411
  tmp
  ))) + ((x & (((x ^ (x * (2829687641))) + x) & (tmp = 988992521
  tmp
  ))) ^ x)))) << ((((-820608336) ^ (tmp = 2851897085
  tmp
  )) >> (tmp = -402427624
  tmp
  )) >>> x)) - (((x * (((-2287402266.4821453) % (tmp = -520664172.1831205
  tmp
  )) ^ (x / (1875488837)))) << (tmp = 402393637
  tmp
  )) & (tmp = 1576638746.3047547
  tmp
  )))
  assertEquals -2827557853031924000, x *= (tmp = 1322578326.6507945
  tmp
  )
  assertEquals 6.424459501778244e+27, x *= (tmp = -2272087729.3065624
  tmp
  )
  assertEquals -1586887483, x |= (-1586887483)
  assertEquals -567868980691736100, x *= (tmp = 357850816
  tmp
  )
  assertEquals 1489101591, x ^= (x % (x | (421921075)))
  assertEquals -801213804822328000, x *= (x | (-672326904.6888077))
  assertEquals 612257233.6612054, x /= (((tmp = -350127617
  tmp
  ) >>> (-1140467595.9752212)) << ((x ^ x) + (-3117914887)))
  assertEquals 19097.231243331422, x /= ((x ^ (tmp = -570012517
  tmp
  )) >>> x)
  assertEquals 0, x >>= ((x % (((-2347648358) % ((x - (tmp = -456496327
  tmp
  )) | (x ^ (-1977407615.4582832)))) << (x / (tmp = -2021394626.214082
  tmp
  )))) % (tmp = -949323000.2442119
  tmp
  ))
  assertEquals 0, x <<= x
  assertEquals NaN, x %= (x ^ (x >> (((tmp = 597147546.7701412
  tmp
  ) & (((((-972400689.6267757) | (tmp = -2390675341.6367044
  tmp
  )) | (tmp = 1890069123.9831812
  tmp
  )) << (((1606974563) - (tmp = -2211617255.8450356
  tmp
  )) & ((((x + ((2433096953) & (-2527357746.681596))) * (tmp = -313956807.55609417
  tmp
  )) | ((tmp = -2146031047.968496
  tmp
  ) / (tmp = 2851650714.68952
  tmp
  ))) >> (((tmp = 2630692376.6265225
  tmp
  ) - (tmp = -3162222598
  tmp
  )) >> ((tmp = 1915552466
  tmp
  ) * (x >>> (-2413248225.7536864))))))) & (x % ((((1218471556) | x) + (tmp = -849693122.6355379
  tmp
  )) + x)))) >>> (x / ((tmp = 689889363
  tmp
  ) / x)))))
  assertEquals 0, x >>>= (45649573.23297)
  assertEquals 0, x >>>= (tmp = 1084439432.771266
  tmp
  )
  assertEquals NaN, x /= x
  assertEquals NaN, x *= (tmp = 1642750077
  tmp
  )
  assertEquals 0, x >>>= (tmp = -1944001182.0778434
  tmp
  )
  assertEquals 1682573000, x |= (tmp = -2612394296.2858696
  tmp
  )
  assertEquals 3041823595, x -= (((tmp = 720576773
  tmp
  ) | (x ^ (-1068335724.2253149))) >> (x * (-2501017061)))
  assertEquals 6083647190, x += x
  assertEquals -6536258988089986000, x *= ((tmp = 632312939.6147232
  tmp
  ) | ((-1621821634) + (((tmp = -2281369913.562131
  tmp
  ) & ((tmp = -381226774
  tmp
  ) | x)) & (664399051))))
  assertEquals 4.272268155938712e+37, x *= x
  assertEquals 733271152, x %= (-1345127171)
  assertEquals 847089925, x ^= (tmp = 432620917.57699084
  tmp
  )
  assertEquals 1337073824, x <<= x
  assertEquals -25810602, x ^= (tmp = 2982414838
  tmp
  )
  assertEquals -25282209, x |= ((tmp = -2927596922
  tmp
  ) >>> (-2404046645.01413))
  assertEquals 639190091919681, x *= x
  assertEquals 173568320, x &= ((((tmp = -718515534.4119437
  tmp
  ) & (tmp = 2989263401
  tmp
  )) << x) | ((tmp = 537073030.5331153
  tmp
  ) - (tmp = 883595389.314624
  tmp
  )))
  assertEquals 0, x -= x
  assertEquals 0, x >>>= (tmp = -1844717424.917882
  tmp
  )
  assertEquals 0, x >>= (tmp = -462881544.2225325
  tmp
  )
  assertEquals 0, x >>= x
  assertEquals -1868450038, x ^= (2426517258.6111603)
  assertEquals 1, x /= x
  assertEquals 1175936039.4202638, x += (tmp = 1175936038.4202638
  tmp
  )
  assertEquals -127916015, x ^= ((x / (1841969600.3012052)) - (tmp = 1099467723
  tmp
  ))
  assertEquals 395713785658171900, x *= (-3093543726)
  assertEquals 395713787128560900, x += (((((-717204758) * (tmp = -588182129.6898501
  tmp
  )) - x) + (tmp = 20638023
  tmp
  )) ^ x)
  assertEquals -962609355, x |= ((x ^ (-3118556619.912983)) << ((tmp = 876126864
  tmp
  ) & x))
  assertEquals -962609355, x %= (tmp = -2079049990
  tmp
  )
  return
f()
