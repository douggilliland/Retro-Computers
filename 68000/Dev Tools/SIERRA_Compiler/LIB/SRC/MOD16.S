*   mod16.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*   68000 16-bit modulus's
*
*   dividend: d1 (16)
*   divisor: d0 (16)
*   quotient (d1 % d0): d1 (32)

*   16-bit by 16-bit modulus's:
*
*   mu16u16: modulus unsigned 16 % unsigned 16 
*   ms16u16: modulus signed 16 % unsigned 16 

    .text
    .align  2

    .globl  __mu16u16
    .globl  __ms16u16

__mu16u16:		    ; u16 % u16 -> any
    swap    d1	    
    clr.w   d1	
    swap    d1		
    divu.w  d0,d1	    
    clr.w   d1		    ; if -> a32, clear high-order-to-be 
    swap    d1		    ; get remainder
    rts

__ms16u16:		    ; s16 % u16 -> any
    ext.l   d1
    bmi.s   L1
    divu.w  d0,d1
    swap    d1		    ; get remainder
    ext.l   d1		    ; if -> a32
    rts
L1:
    neg.l   d1
    divu.w  d0,d1
    swap    d1		    ; get remainder
    neg.w   d1		    ; mod takes sign ofdividend
    ext.l   d1		    ; if -> a32
    rts
