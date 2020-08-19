*   div16.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*   68000 16-bit divides
*
*   dividend: d1 (16)
*   divisor: d0 (16)
*   quotient (d1/d0): d1 (32)

*   16-bit by 16-bit divides:
*
*   du16u16: divide unsigned 16 / unsigned 16 
*   ds16u16: divide signed 16 / unsigned 16 

    .text
    .align  2

    .globl  __du16u16
    .globl  __ds16u16

__du16u16:		; u16 / u16 -> any
    swap    d1	    
    clr.w   d1	
    swap    d1		
    divu.w  d0,d1	    
    swap    d1	    
    clr.w   d1	
    swap    d1		; if -> a32
    rts

__ds16u16:		; s16 / u16 -> any
    ext.l   d1
    bmi.s   L1
    divu.w  d0,d1
    ext.l   d1		; if -> a32
    rts
L1:
    neg.l   d1
    divu.w  d0,d1
    neg.w   d1
    ext.l   d1		; if -> a32
    rts
