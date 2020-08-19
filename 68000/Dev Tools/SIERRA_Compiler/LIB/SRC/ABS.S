*   abs.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
*
*   int abs(int value)
*
*   abs( value ) returns the absolute value of its integer argument	    

    .text
    .align  2

    .globl  abs
    .globl  _abs

abs:
_abs:
 .ifdef INT_16
    move.w  4(sp),d0
    bpl.s   positive
    neg.w   d0
 .else
    move.l  4(sp),d0
    bpl.s   positive
    neg.l   d0
 .endif
positive:
    rts	
