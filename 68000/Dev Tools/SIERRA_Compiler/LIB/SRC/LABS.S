*   labs.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
*
*   long labs(long value)
*
*   abs( value ) returns the absolute value of its long integer argument	    

    .text
    .align  2

    .globl  labs
    .globl  _labs

labs:
_labs:
    move.l  4(sp),d0
    bpl.s   positive
    neg.l   d0
positive:
    rts	
