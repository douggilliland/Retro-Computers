dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
dnl $Id: names.m4,v 4.1.2.1 2004/10/27 14:13:35 albert Exp $
include(VERSION)
                Macros for names in the documentation
define({figforth},fig-Forth)
dnl define({ciforth},fig-Forth)
define({DFW},{{D.F.W.}})
define({_BITS_},_BITS16_({16})_BITS32_({32}))
define({_SEGMENT_},_PROTECTED_({selector}) _REAL_({descriptor}))
define({thisfilename},{ciforth})
define({ci86gnrversion}, ifelse(M4_VERSION,, {snapshot 4.15.5.19}, {M4_VERSION} ))dnl
define({thisfilename},{ci86.lina.texinfo})
define({thisforth},{lina})
