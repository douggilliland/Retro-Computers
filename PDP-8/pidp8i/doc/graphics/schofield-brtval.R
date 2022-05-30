# schofield-brtval.R: Generate SVG graph of the brightness curves
#    produced by Ian Schofield's ILS patch.
#
# The schofield-brtval.svg file checked into Fossil is modified from the
# version output by this program:
#
# 1. The colors are modified to match the scheme on tangentsoft.com/pidp8i
#
# 2. The data line thickness was increased
#
# 3. The data lines were smoothed by Inkscape's "simplify" function
#
# Copyright © 2017 Warren Young
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS LISTED ABOVE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the names of the authors above shall
# not be used in advertising or otherwise to promote the sale, use or other
# dealings in this Software without prior written authorization from those
# authors.
#

min = 0
max = 32
a = min
b = max

rising  = c(min);
falling = c(max);

for (i in 1:400) {
  a = a + (max - a) * 0.01
  b = b + (min - b) * 0.01
  
  rising[i]  = a
  falling[i] = b
  
  if (a > 31 || b < 1) break
}

data = data.frame(Rising = rising, Falling = falling)
dts = ts(data)
svg("schofield-brtval.svg", width=8, height=6)
plot.ts(dts, plot.type='single', ylab='Brightness',
        yaxp=c(min, max, 8))
dev.off()