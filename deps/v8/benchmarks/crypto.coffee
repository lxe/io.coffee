#
# * Copyright (c) 2003-2005  Tom Wu
# * All Rights Reserved.
# *
# * Permission is hereby granted, free of charge, to any person obtaining
# * a copy of this software and associated documentation files (the
# * "Software"), to deal in the Software without restriction, including
# * without limitation the rights to use, copy, modify, merge, publish,
# * distribute, sublicense, and/or sell copies of the Software, and to
# * permit persons to whom the Software is furnished to do so, subject to
# * the following conditions:
# *
# * The above copyright notice and this permission notice shall be
# * included in all copies or substantial portions of the Software.
# *
# * THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND,
# * EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY
# * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
# *
# * IN NO EVENT SHALL TOM WU BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
# * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER
# * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT ADVISED OF
# * THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF LIABILITY, ARISING OUT
# * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# *
# * In addition, the following condition applies:
# *
# * All redistributions must retain an intact copy of this copyright notice
# * and disclaimer.
# 

# The code has been adapted for use as a benchmark by Google.

# Basic JavaScript BN library - subset useful for RSA encryption.

# Bits per digit

# JavaScript engine analysis

# (public) Constructor
BigInteger = (a, b, c) ->
  @array = new Array()
  if a?
    if "number" is typeof a
      @fromNumber a, b, c
    else if not b? and "string" isnt typeof a
      @fromString a, 256
    else
      @fromString a, b
  return

# return new, unset BigInteger
nbi = ->
  new BigInteger(null)

# am: Compute w_j += (x*this_i), propagate carries,
# c is initial carry, returns final carry.
# c < 3*dvalue, x < 2*dvalue, this_i < dvalue
# We need to select the fastest one that works in this environment.

# am1: use a single mult and divide to get the high bits,
# max digit bits should be 26 because
# max internal value = 2*dvalue^2-2*dvalue (< 2^53)
am1 = (i, x, w, j, c, n) ->
  this_array = @array
  w_array = w.array
  while --n >= 0
    v = x * this_array[i++] + w_array[j] + c
    c = Math.floor(v / 0x4000000)
    w_array[j++] = v & 0x3ffffff
  c

# am2 avoids a big mult-and-extract completely.
# Max digit bits should be <= 30 because we do bitwise ops
# on values up to 2*hdvalue^2-hdvalue-1 (< 2^31)
am2 = (i, x, w, j, c, n) ->
  this_array = @array
  w_array = w.array
  xl = x & 0x7fff
  xh = x >> 15
  while --n >= 0
    l = this_array[i] & 0x7fff
    h = this_array[i++] >> 15
    m = xh * l + h * xl
    l = xl * l + ((m & 0x7fff) << 15) + w_array[j] + (c & 0x3fffffff)
    c = (l >>> 30) + (m >>> 15) + xh * h + (c >>> 30)
    w_array[j++] = l & 0x3fffffff
  c

# Alternately, set max digit bits to 28 since some
# browsers slow down when dealing with 32-bit numbers.
am3 = (i, x, w, j, c, n) ->
  this_array = @array
  w_array = w.array
  xl = x & 0x3fff
  xh = x >> 14
  while --n >= 0
    l = this_array[i] & 0x3fff
    h = this_array[i++] >> 14
    m = xh * l + h * xl
    l = xl * l + ((m & 0x3fff) << 14) + w_array[j] + c
    c = (l >> 28) + (m >> 14) + xh * h
    w_array[j++] = l & 0xfffffff
  c

# This is tailored to VMs with 2-bit tagging. It makes sure
# that all the computations stay within the 29 bits available.
am4 = (i, x, w, j, c, n) ->
  this_array = @array
  w_array = w.array
  xl = x & 0x1fff
  xh = x >> 13
  while --n >= 0
    l = this_array[i] & 0x1fff
    h = this_array[i++] >> 13
    m = xh * l + h * xl
    l = xl * l + ((m & 0x1fff) << 13) + w_array[j] + c
    c = (l >> 26) + (m >> 13) + xh * h
    w_array[j++] = l & 0x3ffffff
  c

# am3/28 is best for SM, Rhino, but am4/26 is best for v8.
# Kestrel (Opera 9.5) gets its best result with am4/26.
# IE7 does 9% better with am3/28 than with am4/26.
# Firefox (SM) gets 10% faster with am3/28 than with am4/26.

# Digit conversions
int2char = (n) ->
  BI_RM.charAt n
intAt = (s, i) ->
  c = BI_RC[s.charCodeAt(i)]
  (if (not (c?)) then -1 else c)

# (protected) copy this to r
bnpCopyTo = (r) ->
  this_array = @array
  r_array = r.array
  i = @t - 1

  while i >= 0
    r_array[i] = this_array[i]
    --i
  r.t = @t
  r.s = @s
  return

# (protected) set from integer value x, -DV <= x < DV
bnpFromInt = (x) ->
  this_array = @array
  @t = 1
  @s = (if (x < 0) then -1 else 0)
  if x > 0
    this_array[0] = x
  else if x < -1
    this_array[0] = x + DV
  else
    @t = 0
  return

# return bigint initialized to value
nbv = (i) ->
  r = nbi()
  r.fromInt i
  r

# (protected) set from string and radix
bnpFromString = (s, b) ->
  this_array = @array
  k = undefined
  if b is 16
    k = 4
  else if b is 8
    k = 3
  else if b is 256 # byte array
    k = 8
  else if b is 2
    k = 1
  else if b is 32
    k = 5
  else if b is 4
    k = 2
  else
    @fromRadix s, b
    return
  @t = 0
  @s = 0
  i = s.length
  mi = false
  sh = 0
  while --i >= 0
    x = (if (k is 8) then s[i] & 0xff else intAt(s, i))
    if x < 0
      mi = true  if s.charAt(i) is "-"
      continue
    mi = false
    if sh is 0
      this_array[@t++] = x
    else if sh + k > BI_DB
      this_array[@t - 1] |= (x & ((1 << (BI_DB - sh)) - 1)) << sh
      this_array[@t++] = (x >> (BI_DB - sh))
    else
      this_array[@t - 1] |= x << sh
    sh += k
    sh -= BI_DB  if sh >= BI_DB
  if k is 8 and (s[0] & 0x80) isnt 0
    @s = -1
    this_array[@t - 1] |= ((1 << (BI_DB - sh)) - 1) << sh  if sh > 0
  @clamp()
  BigInteger.ZERO.subTo this, this  if mi
  return

# (protected) clamp off excess high words
bnpClamp = ->
  this_array = @array
  c = @s & BI_DM
  --@t  while @t > 0 and this_array[@t - 1] is c
  return

# (public) return string representation in given radix
bnToString = (b) ->
  this_array = @array
  return "-" + @negate().toString(b)  if @s < 0
  k = undefined
  if b is 16
    k = 4
  else if b is 8
    k = 3
  else if b is 2
    k = 1
  else if b is 32
    k = 5
  else if b is 4
    k = 2
  else
    return @toRadix(b)
  km = (1 << k) - 1
  d = undefined
  m = false
  r = ""
  i = @t
  p = BI_DB - (i * BI_DB) % k
  if i-- > 0
    if p < BI_DB and (d = this_array[i] >> p) > 0
      m = true
      r = int2char(d)
    while i >= 0
      if p < k
        d = (this_array[i] & ((1 << p) - 1)) << (k - p)
        d |= this_array[--i] >> (p += BI_DB - k)
      else
        d = (this_array[i] >> (p -= k)) & km
        if p <= 0
          p += BI_DB
          --i
      m = true  if d > 0
      r += int2char(d)  if m
  (if m then r else "0")

# (public) -this
bnNegate = ->
  r = nbi()
  BigInteger.ZERO.subTo this, r
  r

# (public) |this|
bnAbs = ->
  (if (@s < 0) then @negate() else this)

# (public) return + if this > a, - if this < a, 0 if equal
bnCompareTo = (a) ->
  this_array = @array
  a_array = a.array
  r = @s - a.s
  return r  unless r is 0
  i = @t
  r = i - a.t
  return r  unless r is 0
  return r  unless (r = this_array[i] - a_array[i]) is 0  while --i >= 0
  0

# returns bit length of the integer x
nbits = (x) ->
  r = 1
  t = undefined
  unless (t = x >>> 16) is 0
    x = t
    r += 16
  unless (t = x >> 8) is 0
    x = t
    r += 8
  unless (t = x >> 4) is 0
    x = t
    r += 4
  unless (t = x >> 2) is 0
    x = t
    r += 2
  unless (t = x >> 1) is 0
    x = t
    r += 1
  r

# (public) return the number of bits in "this"
bnBitLength = ->
  this_array = @array
  return 0  if @t <= 0
  BI_DB * (@t - 1) + nbits(this_array[@t - 1] ^ (@s & BI_DM))

# (protected) r = this << n*DB
bnpDLShiftTo = (n, r) ->
  this_array = @array
  r_array = r.array
  i = undefined
  i = @t - 1
  while i >= 0
    r_array[i + n] = this_array[i]
    --i
  i = n - 1
  while i >= 0
    r_array[i] = 0
    --i
  r.t = @t + n
  r.s = @s
  return

# (protected) r = this >> n*DB
bnpDRShiftTo = (n, r) ->
  this_array = @array
  r_array = r.array
  i = n

  while i < @t
    r_array[i - n] = this_array[i]
    ++i
  r.t = Math.max(@t - n, 0)
  r.s = @s
  return

# (protected) r = this << n
bnpLShiftTo = (n, r) ->
  this_array = @array
  r_array = r.array
  bs = n % BI_DB
  cbs = BI_DB - bs
  bm = (1 << cbs) - 1
  ds = Math.floor(n / BI_DB)
  c = (@s << bs) & BI_DM
  i = undefined
  i = @t - 1
  while i >= 0
    r_array[i + ds + 1] = (this_array[i] >> cbs) | c
    c = (this_array[i] & bm) << bs
    --i
  i = ds - 1
  while i >= 0
    r_array[i] = 0
    --i
  r_array[ds] = c
  r.t = @t + ds + 1
  r.s = @s
  r.clamp()
  return

# (protected) r = this >> n
bnpRShiftTo = (n, r) ->
  this_array = @array
  r_array = r.array
  r.s = @s
  ds = Math.floor(n / BI_DB)
  if ds >= @t
    r.t = 0
    return
  bs = n % BI_DB
  cbs = BI_DB - bs
  bm = (1 << bs) - 1
  r_array[0] = this_array[ds] >> bs
  i = ds + 1

  while i < @t
    r_array[i - ds - 1] |= (this_array[i] & bm) << cbs
    r_array[i - ds] = this_array[i] >> bs
    ++i
  r_array[@t - ds - 1] |= (@s & bm) << cbs  if bs > 0
  r.t = @t - ds
  r.clamp()
  return

# (protected) r = this - a
bnpSubTo = (a, r) ->
  this_array = @array
  r_array = r.array
  a_array = a.array
  i = 0
  c = 0
  m = Math.min(a.t, @t)
  while i < m
    c += this_array[i] - a_array[i]
    r_array[i++] = c & BI_DM
    c >>= BI_DB
  if a.t < @t
    c -= a.s
    while i < @t
      c += this_array[i]
      r_array[i++] = c & BI_DM
      c >>= BI_DB
    c += @s
  else
    c += @s
    while i < a.t
      c -= a_array[i]
      r_array[i++] = c & BI_DM
      c >>= BI_DB
    c -= a.s
  r.s = (if (c < 0) then -1 else 0)
  if c < -1
    r_array[i++] = BI_DV + c
  else r_array[i++] = c  if c > 0
  r.t = i
  r.clamp()
  return

# (protected) r = this * a, r != this,a (HAC 14.12)
# "this" should be the larger one if appropriate.
bnpMultiplyTo = (a, r) ->
  this_array = @array
  r_array = r.array
  x = @abs()
  y = a.abs()
  y_array = y.array
  i = x.t
  r.t = i + y.t
  r_array[i] = 0  while --i >= 0
  i = 0
  while i < y.t
    r_array[i + x.t] = x.am(0, y_array[i], r, i, 0, x.t)
    ++i
  r.s = 0
  r.clamp()
  BigInteger.ZERO.subTo r, r  unless @s is a.s
  return

# (protected) r = this^2, r != this (HAC 14.16)
bnpSquareTo = (r) ->
  x = @abs()
  x_array = x.array
  r_array = r.array
  i = r.t = 2 * x.t
  r_array[i] = 0  while --i >= 0
  i = 0
  while i < x.t - 1
    c = x.am(i, x_array[i], r, 2 * i, 0, 1)
    if (r_array[i + x.t] += x.am(i + 1, 2 * x_array[i], r, 2 * i + 1, c, x.t - i - 1)) >= BI_DV
      r_array[i + x.t] -= BI_DV
      r_array[i + x.t + 1] = 1
    ++i
  r_array[r.t - 1] += x.am(i, x_array[i], r, 2 * i, 0, 1)  if r.t > 0
  r.s = 0
  r.clamp()
  return

# (protected) divide this by m, quotient and remainder to q, r (HAC 14.20)
# r != q, this != m.  q or r may be null.
bnpDivRemTo = (m, q, r) ->
  pm = m.abs()
  return  if pm.t <= 0
  pt = @abs()
  if pt.t < pm.t
    q.fromInt 0  if q?
    @copyTo r  if r?
    return
  r = nbi()  unless r?
  y = nbi()
  ts = @s
  ms = m.s
  pm_array = pm.array
  nsh = BI_DB - nbits(pm_array[pm.t - 1]) # normalize modulus
  if nsh > 0
    pm.lShiftTo nsh, y
    pt.lShiftTo nsh, r
  else
    pm.copyTo y
    pt.copyTo r
  ys = y.t
  y_array = y.array
  y0 = y_array[ys - 1]
  return  if y0 is 0
  yt = y0 * (1 << BI_F1) + ((if (ys > 1) then y_array[ys - 2] >> BI_F2 else 0))
  d1 = BI_FV / yt
  d2 = (1 << BI_F1) / yt
  e = 1 << BI_F2
  i = r.t
  j = i - ys
  t = (if (not (q?)) then nbi() else q)
  y.dlShiftTo j, t
  r_array = r.array
  if r.compareTo(t) >= 0
    r_array[r.t++] = 1
    r.subTo t, r
  BigInteger.ONE.dlShiftTo ys, t
  t.subTo y, y # "negative" y so we can replace sub with am later
  y_array[y.t++] = 0  while y.t < ys
  while --j >= 0
    
    # Estimate quotient digit
    qd = (if (r_array[--i] is y0) then BI_DM else Math.floor(r_array[i] * d1 + (r_array[i - 1] + e) * d2))
    if (r_array[i] += y.am(0, qd, r, j, 0, ys)) < qd # Try it out
      y.dlShiftTo j, t
      r.subTo t, r
      r.subTo t, r  while r_array[i] < --qd
  if q?
    r.drShiftTo ys, q
    BigInteger.ZERO.subTo q, q  unless ts is ms
  r.t = ys
  r.clamp()
  r.rShiftTo nsh, r  if nsh > 0 # Denormalize remainder
  BigInteger.ZERO.subTo r, r  if ts < 0
  return

# (public) this mod a
bnMod = (a) ->
  r = nbi()
  @abs().divRemTo a, null, r
  a.subTo r, r  if @s < 0 and r.compareTo(BigInteger.ZERO) > 0
  r

# Modular reduction using "classic" algorithm
Classic = (m) ->
  @m = m
  return
cConvert = (x) ->
  if x.s < 0 or x.compareTo(@m) >= 0
    x.mod @m
  else
    x
cRevert = (x) ->
  x
cReduce = (x) ->
  x.divRemTo @m, null, x
  return
cMulTo = (x, y, r) ->
  x.multiplyTo y, r
  @reduce r
  return
cSqrTo = (x, r) ->
  x.squareTo r
  @reduce r
  return

# (protected) return "-1/this % 2^DB"; useful for Mont. reduction
# justification:
#         xy == 1 (mod m)
#         xy =  1+km
#   xy(2-xy) = (1+km)(1-km)
# x[y(2-xy)] = 1-k^2m^2
# x[y(2-xy)] == 1 (mod m^2)
# if y is 1/x mod m, then y(2-xy) is 1/x mod m^2
# should reduce x and y(2-xy) by m^2 at each step to keep size bounded.
# JS multiply "overflows" differently from C/C++, so care is needed here.
bnpInvDigit = ->
  this_array = @array
  return 0  if @t < 1
  x = this_array[0]
  return 0  if (x & 1) is 0
  y = x & 3 # y == 1/x mod 2^2
  y = (y * (2 - (x & 0xf) * y)) & 0xf # y == 1/x mod 2^4
  y = (y * (2 - (x & 0xff) * y)) & 0xff # y == 1/x mod 2^8
  y = (y * (2 - (((x & 0xffff) * y) & 0xffff))) & 0xffff # y == 1/x mod 2^16
  # last step - calculate inverse mod DV directly;
  # assumes 16 < DB <= 32 and assumes ability to handle 48-bit ints
  y = (y * (2 - x * y % BI_DV)) % BI_DV # y == 1/x mod 2^dbits
  # we really want the negative inverse, and -DV < y < DV
  (if (y > 0) then BI_DV - y else -y)

# Montgomery reduction
Montgomery = (m) ->
  @m = m
  @mp = m.invDigit()
  @mpl = @mp & 0x7fff
  @mph = @mp >> 15
  @um = (1 << (BI_DB - 15)) - 1
  @mt2 = 2 * m.t
  return

# xR mod m
montConvert = (x) ->
  r = nbi()
  x.abs().dlShiftTo @m.t, r
  r.divRemTo @m, null, r
  @m.subTo r, r  if x.s < 0 and r.compareTo(BigInteger.ZERO) > 0
  r

# x/R mod m
montRevert = (x) ->
  r = nbi()
  x.copyTo r
  @reduce r
  r

# x = x/R mod m (HAC 14.32)
montReduce = (x) ->
  x_array = x.array
  # pad x so am has enough room later
  x_array[x.t++] = 0  while x.t <= @mt2
  i = 0

  while i < @m.t
    
    # faster way of calculating u0 = x[i]*mp mod DV
    j = x_array[i] & 0x7fff
    u0 = (j * @mpl + (((j * @mph + (x_array[i] >> 15) * @mpl) & @um) << 15)) & BI_DM
    
    # use am to combine the multiply-shift-add into one call
    j = i + @m.t
    x_array[j] += @m.am(0, u0, x, i, 0, @m.t)
    
    # propagate carry
    while x_array[j] >= BI_DV
      x_array[j] -= BI_DV
      x_array[++j]++
    ++i
  x.clamp()
  x.drShiftTo @m.t, x
  x.subTo @m, x  if x.compareTo(@m) >= 0
  return

# r = "x^2/R mod m"; x != r
montSqrTo = (x, r) ->
  x.squareTo r
  @reduce r
  return

# r = "xy/R mod m"; x,y != r
montMulTo = (x, y, r) ->
  x.multiplyTo y, r
  @reduce r
  return

# (protected) true iff this is even
bnpIsEven = ->
  this_array = @array
  ((if (@t > 0) then (this_array[0] & 1) else @s)) is 0

# (protected) this^e, e < 2^32, doing sqr and mul with "r" (HAC 14.79)
bnpExp = (e, z) ->
  return BigInteger.ONE  if e > 0xffffffff or e < 1
  r = nbi()
  r2 = nbi()
  g = z.convert(this)
  i = nbits(e) - 1
  g.copyTo r
  while --i >= 0
    z.sqrTo r, r2
    if (e & (1 << i)) > 0
      z.mulTo r2, g, r
    else
      t = r
      r = r2
      r2 = t
  z.revert r

# (public) this^e % m, 0 <= e < 2^32
bnModPowInt = (e, m) ->
  z = undefined
  if e < 256 or m.isEven()
    z = new Classic(m)
  else
    z = new Montgomery(m)
  @exp e, z

# protected

# public

# "constants"

# Copyright (c) 2005  Tom Wu
# All Rights Reserved.
# See "LICENSE" for details.

# Extended JavaScript BN functions, required for RSA private ops.

# (public)
bnClone = ->
  r = nbi()
  @copyTo r
  r

# (public) return value as integer
bnIntValue = ->
  this_array = @array
  if @s < 0
    if @t is 1
      return this_array[0] - BI_DV
    else return -1  if @t is 0
  else if @t is 1
    return this_array[0]
  else return 0  if @t is 0
  
  # assumes 16 < DB < 32
  ((this_array[1] & ((1 << (32 - BI_DB)) - 1)) << BI_DB) | this_array[0]

# (public) return value as byte
bnByteValue = ->
  this_array = @array
  (if (@t is 0) then @s else (this_array[0] << 24) >> 24)

# (public) return value as short (assumes DB>=16)
bnShortValue = ->
  this_array = @array
  (if (@t is 0) then @s else (this_array[0] << 16) >> 16)

# (protected) return x s.t. r^x < DV
bnpChunkSize = (r) ->
  Math.floor Math.LN2 * BI_DB / Math.log(r)

# (public) 0 if this == 0, 1 if this > 0
bnSigNum = ->
  this_array = @array
  if @s < 0
    -1
  else if @t <= 0 or (@t is 1 and this_array[0] <= 0)
    0
  else
    1

# (protected) convert to radix string
bnpToRadix = (b) ->
  b = 10  unless b?
  return "0"  if @signum() is 0 or b < 2 or b > 36
  cs = @chunkSize(b)
  a = Math.pow(b, cs)
  d = nbv(a)
  y = nbi()
  z = nbi()
  r = ""
  @divRemTo d, y, z
  while y.signum() > 0
    r = (a + z.intValue()).toString(b).substr(1) + r
    y.divRemTo d, y, z
  z.intValue().toString(b) + r

# (protected) convert from radix string
bnpFromRadix = (s, b) ->
  @fromInt 0
  b = 10  unless b?
  cs = @chunkSize(b)
  d = Math.pow(b, cs)
  mi = false
  j = 0
  w = 0
  i = 0

  while i < s.length
    x = intAt(s, i)
    if x < 0
      mi = true  if s.charAt(i) is "-" and @signum() is 0
      continue
    w = b * w + x
    if ++j >= cs
      @dMultiply d
      @dAddOffset w, 0
      j = 0
      w = 0
    ++i
  if j > 0
    @dMultiply Math.pow(b, j)
    @dAddOffset w, 0
  BigInteger.ZERO.subTo this, this  if mi
  return

# (protected) alternate constructor
bnpFromNumber = (a, b, c) ->
  if "number" is typeof b
    
    # new BigInteger(int,int,RNG)
    if a < 2
      @fromInt 1
    else
      @fromNumber a, c
      # force MSB set
      @bitwiseTo BigInteger.ONE.shiftLeft(a - 1), op_or, this  unless @testBit(a - 1)
      @dAddOffset 1, 0  if @isEven() # force odd
      until @isProbablePrime(b)
        @dAddOffset 2, 0
        @subTo BigInteger.ONE.shiftLeft(a - 1), this  if @bitLength() > a
  else
    
    # new BigInteger(int,RNG)
    x = new Array()
    t = a & 7
    x.length = (a >> 3) + 1
    b.nextBytes x
    if t > 0
      x[0] &= ((1 << t) - 1)
    else
      x[0] = 0
    @fromString x, 256
  return

# (public) convert to bigendian byte array
bnToByteArray = ->
  this_array = @array
  i = @t
  r = new Array()
  r[0] = @s
  p = BI_DB - (i * BI_DB) % 8
  d = undefined
  k = 0
  if i-- > 0
    r[k++] = d | (@s << (BI_DB - p))  if p < BI_DB and (d = this_array[i] >> p) isnt (@s & BI_DM) >> p
    while i >= 0
      if p < 8
        d = (this_array[i] & ((1 << p) - 1)) << (8 - p)
        d |= this_array[--i] >> (p += BI_DB - 8)
      else
        d = (this_array[i] >> (p -= 8)) & 0xff
        if p <= 0
          p += BI_DB
          --i
      d |= -256  unless (d & 0x80) is 0
      ++k  if k is 0 and (@s & 0x80) isnt (d & 0x80)
      r[k++] = d  if k > 0 or d isnt @s
  r
bnEquals = (a) ->
  @compareTo(a) is 0
bnMin = (a) ->
  (if (@compareTo(a) < 0) then this else a)
bnMax = (a) ->
  (if (@compareTo(a) > 0) then this else a)

# (protected) r = this op a (bitwise)
bnpBitwiseTo = (a, op, r) ->
  this_array = @array
  a_array = a.array
  r_array = r.array
  i = undefined
  f = undefined
  m = Math.min(a.t, @t)
  i = 0
  while i < m
    r_array[i] = op(this_array[i], a_array[i])
    ++i
  if a.t < @t
    f = a.s & BI_DM
    i = m
    while i < @t
      r_array[i] = op(this_array[i], f)
      ++i
    r.t = @t
  else
    f = @s & BI_DM
    i = m
    while i < a.t
      r_array[i] = op(f, a_array[i])
      ++i
    r.t = a.t
  r.s = op(@s, a.s)
  r.clamp()
  return

# (public) this & a
op_and = (x, y) ->
  x & y
bnAnd = (a) ->
  r = nbi()
  @bitwiseTo a, op_and, r
  r

# (public) this | a
op_or = (x, y) ->
  x | y
bnOr = (a) ->
  r = nbi()
  @bitwiseTo a, op_or, r
  r

# (public) this ^ a
op_xor = (x, y) ->
  x ^ y
bnXor = (a) ->
  r = nbi()
  @bitwiseTo a, op_xor, r
  r

# (public) this & ~a
op_andnot = (x, y) ->
  x & ~y
bnAndNot = (a) ->
  r = nbi()
  @bitwiseTo a, op_andnot, r
  r

# (public) ~this
bnNot = ->
  this_array = @array
  r = nbi()
  r_array = r.array
  i = 0

  while i < @t
    r_array[i] = BI_DM & ~this_array[i]
    ++i
  r.t = @t
  r.s = ~@s
  r

# (public) this << n
bnShiftLeft = (n) ->
  r = nbi()
  if n < 0
    @rShiftTo -n, r
  else
    @lShiftTo n, r
  r

# (public) this >> n
bnShiftRight = (n) ->
  r = nbi()
  if n < 0
    @lShiftTo -n, r
  else
    @rShiftTo n, r
  r

# return index of lowest 1-bit in x, x < 2^31
lbit = (x) ->
  return -1  if x is 0
  r = 0
  if (x & 0xffff) is 0
    x >>= 16
    r += 16
  if (x & 0xff) is 0
    x >>= 8
    r += 8
  if (x & 0xf) is 0
    x >>= 4
    r += 4
  if (x & 3) is 0
    x >>= 2
    r += 2
  ++r  if (x & 1) is 0
  r

# (public) returns index of lowest 1-bit (or -1 if none)
bnGetLowestSetBit = ->
  this_array = @array
  i = 0

  while i < @t
    return i * BI_DB + lbit(this_array[i])  unless this_array[i] is 0
    ++i
  return @t * BI_DB  if @s < 0
  -1

# return number of 1 bits in x
cbit = (x) ->
  r = 0
  until x is 0
    x &= x - 1
    ++r
  r

# (public) return number of set bits
bnBitCount = ->
  r = 0
  x = @s & BI_DM
  i = 0

  while i < @t
    r += cbit(this_array[i] ^ x)
    ++i
  r

# (public) true iff nth bit is set
bnTestBit = (n) ->
  this_array = @array
  j = Math.floor(n / BI_DB)
  return (@s isnt 0)  if j >= @t
  (this_array[j] & (1 << (n % BI_DB))) isnt 0

# (protected) this op (1<<n)
bnpChangeBit = (n, op) ->
  r = BigInteger.ONE.shiftLeft(n)
  @bitwiseTo r, op, r
  r

# (public) this | (1<<n)
bnSetBit = (n) ->
  @changeBit n, op_or

# (public) this & ~(1<<n)
bnClearBit = (n) ->
  @changeBit n, op_andnot

# (public) this ^ (1<<n)
bnFlipBit = (n) ->
  @changeBit n, op_xor

# (protected) r = this + a
bnpAddTo = (a, r) ->
  this_array = @array
  a_array = a.array
  r_array = r.array
  i = 0
  c = 0
  m = Math.min(a.t, @t)
  while i < m
    c += this_array[i] + a_array[i]
    r_array[i++] = c & BI_DM
    c >>= BI_DB
  if a.t < @t
    c += a.s
    while i < @t
      c += this_array[i]
      r_array[i++] = c & BI_DM
      c >>= BI_DB
    c += @s
  else
    c += @s
    while i < a.t
      c += a_array[i]
      r_array[i++] = c & BI_DM
      c >>= BI_DB
    c += a.s
  r.s = (if (c < 0) then -1 else 0)
  if c > 0
    r_array[i++] = c
  else r_array[i++] = BI_DV + c  if c < -1
  r.t = i
  r.clamp()
  return

# (public) this + a
bnAdd = (a) ->
  r = nbi()
  @addTo a, r
  r

# (public) this - a
bnSubtract = (a) ->
  r = nbi()
  @subTo a, r
  r

# (public) this * a
bnMultiply = (a) ->
  r = nbi()
  @multiplyTo a, r
  r

# (public) this / a
bnDivide = (a) ->
  r = nbi()
  @divRemTo a, r, null
  r

# (public) this % a
bnRemainder = (a) ->
  r = nbi()
  @divRemTo a, null, r
  r

# (public) [this/a,this%a]
bnDivideAndRemainder = (a) ->
  q = nbi()
  r = nbi()
  @divRemTo a, q, r
  new Array(q, r)

# (protected) this *= n, this >= 0, 1 < n < DV
bnpDMultiply = (n) ->
  this_array = @array
  this_array[@t] = @am(0, n - 1, this, 0, 0, @t)
  ++@t
  @clamp()
  return

# (protected) this += n << w words, this >= 0
bnpDAddOffset = (n, w) ->
  this_array = @array
  this_array[@t++] = 0  while @t <= w
  this_array[w] += n
  while this_array[w] >= BI_DV
    this_array[w] -= BI_DV
    this_array[@t++] = 0  if ++w >= @t
    ++this_array[w]
  return

# A "null" reducer
NullExp = ->
nNop = (x) ->
  x
nMulTo = (x, y, r) ->
  x.multiplyTo y, r
  return
nSqrTo = (x, r) ->
  x.squareTo r
  return

# (public) this^e
bnPow = (e) ->
  @exp e, new NullExp()

# (protected) r = lower n words of "this * a", a.t <= n
# "this" should be the larger one if appropriate.
bnpMultiplyLowerTo = (a, n, r) ->
  r_array = r.array
  a_array = a.array
  i = Math.min(@t + a.t, n)
  r.s = 0 # assumes a,this >= 0
  r.t = i
  r_array[--i] = 0  while i > 0
  j = undefined
  j = r.t - @t
  while i < j
    r_array[i + @t] = @am(0, a_array[i], r, i, 0, @t)
    ++i
  j = Math.min(a.t, n)
  while i < j
    @am 0, a_array[i], r, i, 0, n - i
    ++i
  r.clamp()
  return

# (protected) r = "this * a" without lower n words, n > 0
# "this" should be the larger one if appropriate.
bnpMultiplyUpperTo = (a, n, r) ->
  r_array = r.array
  a_array = a.array
  --n
  i = r.t = @t + a.t - n
  r.s = 0 # assumes a,this >= 0
  r_array[i] = 0  while --i >= 0
  i = Math.max(n - @t, 0)
  while i < a.t
    r_array[@t + i - n] = @am(n - i, a_array[i], r, 0, 0, @t + i - n)
    ++i
  r.clamp()
  r.drShiftTo 1, r
  return

# Barrett modular reduction
Barrett = (m) ->
  
  # setup Barrett
  @r2 = nbi()
  @q3 = nbi()
  BigInteger.ONE.dlShiftTo 2 * m.t, @r2
  @mu = @r2.divide(m)
  @m = m
  return
barrettConvert = (x) ->
  if x.s < 0 or x.t > 2 * @m.t
    x.mod @m
  else if x.compareTo(@m) < 0
    x
  else
    r = nbi()
    x.copyTo r
    @reduce r
    r
barrettRevert = (x) ->
  x

# x = x mod m (HAC 14.42)
barrettReduce = (x) ->
  x.drShiftTo @m.t - 1, @r2
  if x.t > @m.t + 1
    x.t = @m.t + 1
    x.clamp()
  @mu.multiplyUpperTo @r2, @m.t + 1, @q3
  @m.multiplyLowerTo @q3, @m.t + 1, @r2
  x.dAddOffset 1, @m.t + 1  while x.compareTo(@r2) < 0
  x.subTo @r2, x
  x.subTo @m, x  while x.compareTo(@m) >= 0
  return

# r = x^2 mod m; x != r
barrettSqrTo = (x, r) ->
  x.squareTo r
  @reduce r
  return

# r = x*y mod m; x,y != r
barrettMulTo = (x, y, r) ->
  x.multiplyTo y, r
  @reduce r
  return

# (public) this^e % m (HAC 14.85)
bnModPow = (e, m) ->
  e_array = e.array
  i = e.bitLength()
  k = undefined
  r = nbv(1)
  z = undefined
  if i <= 0
    return r
  else if i < 18
    k = 1
  else if i < 48
    k = 3
  else if i < 144
    k = 4
  else if i < 768
    k = 5
  else
    k = 6
  if i < 8
    z = new Classic(m)
  else if m.isEven()
    z = new Barrett(m)
  else
    z = new Montgomery(m)
  
  # precomputation
  g = new Array()
  n = 3
  k1 = k - 1
  km = (1 << k) - 1
  g[1] = z.convert(this)
  if k > 1
    g2 = nbi()
    z.sqrTo g[1], g2
    while n <= km
      g[n] = nbi()
      z.mulTo g2, g[n - 2], g[n]
      n += 2
  j = e.t - 1
  w = undefined
  is1 = true
  r2 = nbi()
  t = undefined
  i = nbits(e_array[j]) - 1
  while j >= 0
    if i >= k1
      w = (e_array[j] >> (i - k1)) & km
    else
      w = (e_array[j] & ((1 << (i + 1)) - 1)) << (k1 - i)
      w |= e_array[j - 1] >> (BI_DB + i - k1)  if j > 0
    n = k
    while (w & 1) is 0
      w >>= 1
      --n
    if (i -= n) < 0
      i += BI_DB
      --j
    if is1 # ret == 1, don't bother squaring or multiplying it
      g[w].copyTo r
      is1 = false
    else
      while n > 1
        z.sqrTo r, r2
        z.sqrTo r2, r
        n -= 2
      if n > 0
        z.sqrTo r, r2
      else
        t = r
        r = r2
        r2 = t
      z.mulTo r2, g[w], r
    while j >= 0 and (e_array[j] & (1 << i)) is 0
      z.sqrTo r, r2
      t = r
      r = r2
      r2 = t
      if --i < 0
        i = BI_DB - 1
        --j
  z.revert r

# (public) gcd(this,a) (HAC 14.54)
bnGCD = (a) ->
  x = (if (@s < 0) then @negate() else @clone())
  y = (if (a.s < 0) then a.negate() else a.clone())
  if x.compareTo(y) < 0
    t = x
    x = y
    y = t
  i = x.getLowestSetBit()
  g = y.getLowestSetBit()
  return x  if g < 0
  g = i  if i < g
  if g > 0
    x.rShiftTo g, x
    y.rShiftTo g, y
  while x.signum() > 0
    x.rShiftTo i, x  if (i = x.getLowestSetBit()) > 0
    y.rShiftTo i, y  if (i = y.getLowestSetBit()) > 0
    if x.compareTo(y) >= 0
      x.subTo y, x
      x.rShiftTo 1, x
    else
      y.subTo x, y
      y.rShiftTo 1, y
  y.lShiftTo g, y  if g > 0
  y

# (protected) this % n, n < 2^26
bnpModInt = (n) ->
  this_array = @array
  return 0  if n <= 0
  d = BI_DV % n
  r = (if (@s < 0) then n - 1 else 0)
  if @t > 0
    if d is 0
      r = this_array[0] % n
    else
      i = @t - 1

      while i >= 0
        r = (d * r + this_array[i]) % n
        --i
  r

# (public) 1/this % m (HAC 14.61)
bnModInverse = (m) ->
  ac = m.isEven()
  return BigInteger.ZERO  if (@isEven() and ac) or m.signum() is 0
  u = m.clone()
  v = @clone()
  a = nbv(1)
  b = nbv(0)
  c = nbv(0)
  d = nbv(1)
  until u.signum() is 0
    while u.isEven()
      u.rShiftTo 1, u
      if ac
        if not a.isEven() or not b.isEven()
          a.addTo this, a
          b.subTo m, b
        a.rShiftTo 1, a
      else b.subTo m, b  unless b.isEven()
      b.rShiftTo 1, b
    while v.isEven()
      v.rShiftTo 1, v
      if ac
        if not c.isEven() or not d.isEven()
          c.addTo this, c
          d.subTo m, d
        c.rShiftTo 1, c
      else d.subTo m, d  unless d.isEven()
      d.rShiftTo 1, d
    if u.compareTo(v) >= 0
      u.subTo v, u
      a.subTo c, a  if ac
      b.subTo d, b
    else
      v.subTo u, v
      c.subTo a, c  if ac
      d.subTo b, d
  return BigInteger.ZERO  unless v.compareTo(BigInteger.ONE) is 0
  return d.subtract(m)  if d.compareTo(m) >= 0
  if d.signum() < 0
    d.addTo m, d
  else
    return d
  if d.signum() < 0
    d.add m
  else
    d

# (public) test primality with certainty >= 1-.5^t
bnIsProbablePrime = (t) ->
  i = undefined
  x = @abs()
  x_array = x.array
  if x.t is 1 and x_array[0] <= lowprimes[lowprimes.length - 1]
    i = 0
    while i < lowprimes.length
      return true  if x_array[0] is lowprimes[i]
      ++i
    return false
  return false  if x.isEven()
  i = 1
  while i < lowprimes.length
    m = lowprimes[i]
    j = i + 1
    m *= lowprimes[j++]  while j < lowprimes.length and m < lplim
    m = x.modInt(m)
    return false  if m % lowprimes[i++] is 0  while i < j
  x.millerRabin t

# (protected) true if probably prime (HAC 4.24, Miller-Rabin)
bnpMillerRabin = (t) ->
  n1 = @subtract(BigInteger.ONE)
  k = n1.getLowestSetBit()
  return false  if k <= 0
  r = n1.shiftRight(k)
  t = (t + 1) >> 1
  t = lowprimes.length  if t > lowprimes.length
  a = nbi()
  i = 0

  while i < t
    a.fromInt lowprimes[i]
    y = a.modPow(r, this)
    if y.compareTo(BigInteger.ONE) isnt 0 and y.compareTo(n1) isnt 0
      j = 1
      while j++ < k and y.compareTo(n1) isnt 0
        y = y.modPowInt(2, this)
        return false  if y.compareTo(BigInteger.ONE) is 0
      return false  unless y.compareTo(n1) is 0
    ++i
  true

# protected

# public

# BigInteger interfaces not implemented in jsbn:

# BigInteger(int signum, byte[] magnitude)
# double doubleValue()
# float floatValue()
# int hashCode()
# long longValue()
# static BigInteger valueOf(long val)
# prng4.js - uses Arcfour as a PRNG
Arcfour = ->
  @i = 0
  @j = 0
  @S = new Array()
  return

# Initialize arcfour context from key, an array of ints, each from [0..255]
ARC4init = (key) ->
  i = undefined
  j = undefined
  t = undefined
  i = 0
  while i < 256
    @S[i] = i
    ++i
  j = 0
  i = 0
  while i < 256
    j = (j + @S[i] + key[i % key.length]) & 255
    t = @S[i]
    @S[i] = @S[j]
    @S[j] = t
    ++i
  @i = 0
  @j = 0
  return
ARC4next = ->
  t = undefined
  @i = (@i + 1) & 255
  @j = (@j + @S[@i]) & 255
  t = @S[@i]
  @S[@i] = @S[@j]
  @S[@j] = t
  @S[(t + @S[@i]) & 255]

# Plug in your RNG constructor here
prng_newstate = ->
  new Arcfour()

# Pool size must be a multiple of 4 and greater than 32.
# An array of bytes the size of the pool will be passed to init()

# Random number generator - requires a PRNG backend, e.g. prng4.js

# For best results, put code like
# <body onClick='rng_seed_time();' onKeyPress='rng_seed_time();'>
# in your main HTML document.

# Mix in a 32-bit integer into the pool
rng_seed_int = (x) ->
  rng_pool[rng_pptr++] ^= x & 255
  rng_pool[rng_pptr++] ^= (x >> 8) & 255
  rng_pool[rng_pptr++] ^= (x >> 16) & 255
  rng_pool[rng_pptr++] ^= (x >> 24) & 255
  rng_pptr -= rng_psize  if rng_pptr >= rng_psize
  return

# Mix in the current time (w/milliseconds) into the pool
rng_seed_time = ->
  
  # Use pre-computed date to avoid making the benchmark
  # results dependent on the current date.
  rng_seed_int 1122926989487
  return

# Initialize the pool with junk if needed.
# extract some randomness from Math.random()

#rng_seed_int(window.screenX);
#rng_seed_int(window.screenY);
rng_get_byte = ->
  unless rng_state?
    rng_seed_time()
    rng_state = prng_newstate()
    rng_state.init rng_pool
    rng_pptr = 0
    while rng_pptr < rng_pool.length
      rng_pool[rng_pptr] = 0
      ++rng_pptr
    rng_pptr = 0
  
  #rng_pool = null;
  
  # TODO: allow reseeding after first request
  rng_state.next()
rng_get_bytes = (ba) ->
  i = undefined
  i = 0
  while i < ba.length
    ba[i] = rng_get_byte()
    ++i
  return
SecureRandom = ->

# Depends on jsbn.js and rng.js

# convert a (hex) string to a bignum object
parseBigInt = (str, r) ->
  new BigInteger(str, r)
linebrk = (s, n) ->
  ret = ""
  i = 0
  while i + n < s.length
    ret += s.substring(i, i + n) + "\n"
    i += n
  ret + s.substring(i, s.length)
byte2Hex = (b) ->
  if b < 0x10
    "0" + b.toString(16)
  else
    b.toString 16

# PKCS#1 (type 2, random) pad input string s to n bytes, and return a bigint
pkcs1pad2 = (s, n) ->
  if n < s.length + 11
    alert "Message too long for RSA"
    return null
  ba = new Array()
  i = s.length - 1
  ba[--n] = s.charCodeAt(i--)  while i >= 0 and n > 0
  ba[--n] = 0
  rng = new SecureRandom()
  x = new Array()
  while n > 2 # random non-zero pad
    x[0] = 0
    rng.nextBytes x  while x[0] is 0
    ba[--n] = x[0]
  ba[--n] = 2
  ba[--n] = 0
  new BigInteger(ba)

# "empty" RSA key constructor
RSAKey = ->
  @n = null
  @e = 0
  @d = null
  @p = null
  @q = null
  @dmp1 = null
  @dmq1 = null
  @coeff = null
  return

# Set the public key fields N and e from hex strings
RSASetPublic = (N, E) ->
  if N? and E? and N.length > 0 and E.length > 0
    @n = parseBigInt(N, 16)
    @e = parseInt(E, 16)
  else
    alert "Invalid RSA public key"
  return

# Perform raw public operation on "x": return x^e (mod n)
RSADoPublic = (x) ->
  x.modPowInt @e, @n

# Return the PKCS#1 RSA encryption of "text" as an even-length hex string
RSAEncrypt = (text) ->
  m = pkcs1pad2(text, (@n.bitLength() + 7) >> 3)
  return null  unless m?
  c = @doPublic(m)
  return null  unless c?
  h = c.toString(16)
  if (h.length & 1) is 0
    h
  else
    "0" + h

# Return the PKCS#1 RSA encryption of "text" as a Base64-encoded string
#function RSAEncryptB64(text) {
#  var h = this.encrypt(text);
#  if(h) return hex2b64(h); else return null;
#}

# protected

# public

#RSAKey.prototype.encrypt_b64 = RSAEncryptB64;
# Depends on rsa.js and jsbn2.js

# Undo PKCS#1 (type 2, random) padding and, if valid, return the plaintext
pkcs1unpad2 = (d, n) ->
  b = d.toByteArray()
  i = 0
  ++i  while i < b.length and b[i] is 0
  return null  if b.length - i isnt n - 1 or b[i] isnt 2
  ++i
  return null  if ++i >= b.length  until b[i] is 0
  ret = ""
  ret += String.fromCharCode(b[i])  while ++i < b.length
  ret

# Set the private key fields N, e, and d from hex strings
RSASetPrivate = (N, E, D) ->
  if N? and E? and N.length > 0 and E.length > 0
    @n = parseBigInt(N, 16)
    @e = parseInt(E, 16)
    @d = parseBigInt(D, 16)
  else
    alert "Invalid RSA private key"
  return

# Set the private key fields N, e, d and CRT params from hex strings
RSASetPrivateEx = (N, E, D, P, Q, DP, DQ, C) ->
  if N? and E? and N.length > 0 and E.length > 0
    @n = parseBigInt(N, 16)
    @e = parseInt(E, 16)
    @d = parseBigInt(D, 16)
    @p = parseBigInt(P, 16)
    @q = parseBigInt(Q, 16)
    @dmp1 = parseBigInt(DP, 16)
    @dmq1 = parseBigInt(DQ, 16)
    @coeff = parseBigInt(C, 16)
  else
    alert "Invalid RSA private key"
  return

# Generate a new random private key B bits long, using public expt E
RSAGenerate = (B, E) ->
  rng = new SecureRandom()
  qs = B >> 1
  @e = parseInt(E, 16)
  ee = new BigInteger(E, 16)
  loop
    loop
      @p = new BigInteger(B - qs, 1, rng)
      break  if @p.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) is 0 and @p.isProbablePrime(10)
    loop
      @q = new BigInteger(qs, 1, rng)
      break  if @q.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) is 0 and @q.isProbablePrime(10)
    if @p.compareTo(@q) <= 0
      t = @p
      @p = @q
      @q = t
    p1 = @p.subtract(BigInteger.ONE)
    q1 = @q.subtract(BigInteger.ONE)
    phi = p1.multiply(q1)
    if phi.gcd(ee).compareTo(BigInteger.ONE) is 0
      @n = @p.multiply(@q)
      @d = ee.modInverse(phi)
      @dmp1 = @d.mod(p1)
      @dmq1 = @d.mod(q1)
      @coeff = @q.modInverse(@p)
      break
  return

# Perform raw private operation on "x": return x^d (mod n)
RSADoPrivate = (x) ->
  return x.modPow(@d, @n)  if not @p? or not @q?
  
  # TODO: re-calculate any missing CRT params
  xp = x.mod(@p).modPow(@dmp1, @p)
  xq = x.mod(@q).modPow(@dmq1, @q)
  xp = xp.add(@p)  while xp.compareTo(xq) < 0
  xp.subtract(xq).multiply(@coeff).mod(@p).multiply(@q).add xq

# Return the PKCS#1 RSA decryption of "ctext".
# "ctext" is an even-length hex string and the output is a plain string.
RSADecrypt = (ctext) ->
  c = parseBigInt(ctext, 16)
  m = @doPrivate(c)
  return null  unless m?
  pkcs1unpad2 m, (@n.bitLength() + 7) >> 3

# Return the PKCS#1 RSA decryption of "ctext".
# "ctext" is a Base64-encoded string and the output is a plain string.
#function RSAB64Decrypt(ctext) {
#  var h = b64tohex(ctext);
#  if(h) return this.decrypt(h); else return null;
#}

# protected

# public

#RSAKey.prototype.b64_decrypt = RSAB64Decrypt;
encrypt = ->
  RSA = new RSAKey()
  RSA.setPublic nValue, eValue
  RSA.setPrivateEx nValue, eValue, dValue, pValue, qValue, dmp1Value, dmq1Value, coeffValue
  encrypted = RSA.encrypt(TEXT)
  return
decrypt = ->
  RSA = new RSAKey()
  RSA.setPublic nValue, eValue
  RSA.setPrivateEx nValue, eValue, dValue, pValue, qValue, dmp1Value, dmq1Value, coeffValue
  decrypted = RSA.decrypt(encrypted)
  throw new Error("Crypto operation failed")  unless decrypted is TEXT
  return
Crypto = new BenchmarkSuite("Crypto", 266181, [
  new Benchmark("Encrypt", encrypt)
  new Benchmark("Decrypt", decrypt)
])
dbits = undefined
BI_DB = undefined
BI_DM = undefined
BI_DV = undefined
BI_FP = undefined
BI_FV = undefined
BI_F1 = undefined
BI_F2 = undefined
canary = 0xdeadbeefcafe
j_lm = ((canary & 0xffffff) is 0xefcafe)
setupEngine = (fn, bits) ->
  BigInteger::am = fn
  dbits = bits
  BI_DB = dbits
  BI_DM = ((1 << dbits) - 1)
  BI_DV = (1 << dbits)
  BI_FP = 52
  BI_FV = Math.pow(2, BI_FP)
  BI_F1 = BI_FP - dbits
  BI_F2 = 2 * dbits - BI_FP
  return

BI_RM = "0123456789abcdefghijklmnopqrstuvwxyz"
BI_RC = new Array()
rr = undefined
vv = undefined
rr = "0".charCodeAt(0)
vv = 0
while vv <= 9
  BI_RC[rr++] = vv
  ++vv
rr = "a".charCodeAt(0)
vv = 10
while vv < 36
  BI_RC[rr++] = vv
  ++vv
rr = "A".charCodeAt(0)
vv = 10
while vv < 36
  BI_RC[rr++] = vv
  ++vv
Classic::convert = cConvert
Classic::revert = cRevert
Classic::reduce = cReduce
Classic::mulTo = cMulTo
Classic::sqrTo = cSqrTo
Montgomery::convert = montConvert
Montgomery::revert = montRevert
Montgomery::reduce = montReduce
Montgomery::mulTo = montMulTo
Montgomery::sqrTo = montSqrTo
BigInteger::copyTo = bnpCopyTo
BigInteger::fromInt = bnpFromInt
BigInteger::fromString = bnpFromString
BigInteger::clamp = bnpClamp
BigInteger::dlShiftTo = bnpDLShiftTo
BigInteger::drShiftTo = bnpDRShiftTo
BigInteger::lShiftTo = bnpLShiftTo
BigInteger::rShiftTo = bnpRShiftTo
BigInteger::subTo = bnpSubTo
BigInteger::multiplyTo = bnpMultiplyTo
BigInteger::squareTo = bnpSquareTo
BigInteger::divRemTo = bnpDivRemTo
BigInteger::invDigit = bnpInvDigit
BigInteger::isEven = bnpIsEven
BigInteger::exp = bnpExp
BigInteger::toString = bnToString
BigInteger::negate = bnNegate
BigInteger::abs = bnAbs
BigInteger::compareTo = bnCompareTo
BigInteger::bitLength = bnBitLength
BigInteger::mod = bnMod
BigInteger::modPowInt = bnModPowInt
BigInteger.ZERO = nbv(0)
BigInteger.ONE = nbv(1)
NullExp::convert = nNop
NullExp::revert = nNop
NullExp::mulTo = nMulTo
NullExp::sqrTo = nSqrTo
Barrett::convert = barrettConvert
Barrett::revert = barrettRevert
Barrett::reduce = barrettReduce
Barrett::mulTo = barrettMulTo
Barrett::sqrTo = barrettSqrTo
lowprimes = [
  2
  3
  5
  7
  11
  13
  17
  19
  23
  29
  31
  37
  41
  43
  47
  53
  59
  61
  67
  71
  73
  79
  83
  89
  97
  101
  103
  107
  109
  113
  127
  131
  137
  139
  149
  151
  157
  163
  167
  173
  179
  181
  191
  193
  197
  199
  211
  223
  227
  229
  233
  239
  241
  251
  257
  263
  269
  271
  277
  281
  283
  293
  307
  311
  313
  317
  331
  337
  347
  349
  353
  359
  367
  373
  379
  383
  389
  397
  401
  409
  419
  421
  431
  433
  439
  443
  449
  457
  461
  463
  467
  479
  487
  491
  499
  503
  509
]
lplim = (1 << 26) / lowprimes[lowprimes.length - 1]
BigInteger::chunkSize = bnpChunkSize
BigInteger::toRadix = bnpToRadix
BigInteger::fromRadix = bnpFromRadix
BigInteger::fromNumber = bnpFromNumber
BigInteger::bitwiseTo = bnpBitwiseTo
BigInteger::changeBit = bnpChangeBit
BigInteger::addTo = bnpAddTo
BigInteger::dMultiply = bnpDMultiply
BigInteger::dAddOffset = bnpDAddOffset
BigInteger::multiplyLowerTo = bnpMultiplyLowerTo
BigInteger::multiplyUpperTo = bnpMultiplyUpperTo
BigInteger::modInt = bnpModInt
BigInteger::millerRabin = bnpMillerRabin
BigInteger::clone = bnClone
BigInteger::intValue = bnIntValue
BigInteger::byteValue = bnByteValue
BigInteger::shortValue = bnShortValue
BigInteger::signum = bnSigNum
BigInteger::toByteArray = bnToByteArray
BigInteger::equals = bnEquals
BigInteger::min = bnMin
BigInteger::max = bnMax
BigInteger::and = bnAnd
BigInteger::or = bnOr
BigInteger::xor = bnXor
BigInteger::andNot = bnAndNot
BigInteger::not = bnNot
BigInteger::shiftLeft = bnShiftLeft
BigInteger::shiftRight = bnShiftRight
BigInteger::getLowestSetBit = bnGetLowestSetBit
BigInteger::bitCount = bnBitCount
BigInteger::testBit = bnTestBit
BigInteger::setBit = bnSetBit
BigInteger::clearBit = bnClearBit
BigInteger::flipBit = bnFlipBit
BigInteger::add = bnAdd
BigInteger::subtract = bnSubtract
BigInteger::multiply = bnMultiply
BigInteger::divide = bnDivide
BigInteger::remainder = bnRemainder
BigInteger::divideAndRemainder = bnDivideAndRemainder
BigInteger::modPow = bnModPow
BigInteger::modInverse = bnModInverse
BigInteger::pow = bnPow
BigInteger::gcd = bnGCD
BigInteger::isProbablePrime = bnIsProbablePrime
Arcfour::init = ARC4init
Arcfour::next = ARC4next
rng_psize = 256
rng_state = undefined
rng_pool = undefined
rng_pptr = undefined
unless rng_pool?
  rng_pool = new Array()
  rng_pptr = 0
  t = undefined
  while rng_pptr < rng_psize
    t = Math.floor(65536 * Math.random())
    rng_pool[rng_pptr++] = t >>> 8
    rng_pool[rng_pptr++] = t & 255
  rng_pptr = 0
  rng_seed_time()
SecureRandom::nextBytes = rng_get_bytes
RSAKey::doPublic = RSADoPublic
RSAKey::setPublic = RSASetPublic
RSAKey::encrypt = RSAEncrypt
RSAKey::doPrivate = RSADoPrivate
RSAKey::setPrivate = RSASetPrivate
RSAKey::setPrivateEx = RSASetPrivateEx
RSAKey::generate = RSAGenerate
RSAKey::decrypt = RSADecrypt
nValue = "a5261939975948bb7a58dffe5ff54e65f0498f9175f5a09288810b8975871e99af3b5dd94057b0fc07535f5f97444504fa35169d461d0d30cf0192e307727c065168c788771c561a9400fb49175e9e6aa4e23fe11af69e9412dd23b0cb6684c4c2429bce139e848ab26d0829073351f4acd36074eafd036a5eb83359d2a698d3"
eValue = "10001"
dValue = "8e9912f6d3645894e8d38cb58c0db81ff516cf4c7e5a14c7f1eddb1459d2cded4d8d293fc97aee6aefb861859c8b6a3d1dfe710463e1f9ddc72048c09751971c4a580aa51eb523357a3cc48d31cfad1d4a165066ed92d4748fb6571211da5cb14bc11b6e2df7c1a559e6d5ac1cd5c94703a22891464fba23d0d965086277a161"
pValue = "d090ce58a92c75233a6486cb0a9209bf3583b64f540c76f5294bb97d285eed33aec220bde14b2417951178ac152ceab6da7090905b478195498b352048f15e7d"
qValue = "cab575dc652bb66df15a0359609d51d1db184750c00c6698b90ef3465c99655103edbf0d54c56aec0ce3c4d22592338092a126a0cc49f65a4a30d222b411e58f"
dmp1Value = "1a24bca8e273df2f0e47c199bbf678604e7df7215480c77c8db39f49b000ce2cf7500038acfff5433b7d582a01f1826e6f4d42e1c57f5e1fef7b12aabc59fd25"
dmq1Value = "3d06982efbbe47339e1f6d36b1216b8a741d410b0c662f54f7118b27b9a4ec9d914337eb39841d8666f3034408cf94f5b62f11c402fc994fe15a05493150d9fd"
coeffValue = "3a3e731acd8960b7ff9eb81a7ff93bd1cfa74cbd56987db58b4594fb09c09084db1734c8143f98b602b981aaa9243ca28deb69b5b280ee8dcee0fd2625e53250"
setupEngine am3, 28
TEXT = "The quick brown fox jumped over the extremely lazy frog! " + "Now is the time for all good men to come to the party."
encrypted = undefined
