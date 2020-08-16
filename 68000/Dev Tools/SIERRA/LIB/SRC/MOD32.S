*   mod32.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*   68000 32-bit modulus's
*
*   dividend: d1 (32)
*   divisor: d0 (32)
*   quotient (d1 % d0): d1 (32)
*   scratch registers: d2, a0, and a1

*   32-bit by 32-bit modulus's:
*
*   ms32s32: modulus signed 32 % signed 32 
*   mu32u32: modulus unsigned 32 % unsigned 32 

    .opt    proc=68000

    .text
    .align  2

    .globl  __mu32u32
    .globl  __ms32s32

__mu32u32:		    ; u32 % u32 -> any
    move.l  a2,-(sp)
    pea	    L1(pc)	    ; needed to get control on return
    move.l  #__mod1,a0	    ; use du32u32's multiply overflow adjustment logic
    suba.l  #lea1,a0
lea1:
    lea	    lea1(pc,a0.l),a0
    bra.s   mod32
L1:			    ; return from mod32
    move.l  d2,d1	    ; get (x/y)*y {adj mult product} - x {dividend}
    neg.l   d1		    ; make x - (x/y)*y = x mod y
    move.l  (sp)+,a2
    rts
    
__ms32s32:		    ; s32 % s32 -> any
    move.l  a2,-(sp)
    tst.l   d0
    bpl.s   L2
    neg.l   d0		    ; mod takes sign of dividend (x mod y) = (x mod -y)
L2:
    tst.l   d1
    bmi.s   L5
    lea	    L1(pc),a0	    ; signed opnd >= 0 do unsigned mod/div, no overflo
mod32:			    ; common function for 32 bit modulus
    swap    d0
    movea.w d0,a1
    swap    d0
    move.w  a1,d2
    beq.s   L3
    move.l  #__mod2,a2
    suba.l  #jmp1,a2
jmp1:
    jmp	    jmp1(pc,a2.l)
L3:
    divu.w  d0,d1	    ; see if quotient fits in 16 bits
    bvc.s   L4		    ; branch if it does
    move.w  d1,-(sp)	    ; save low order of dividend
    clr.w   d1		    ; shift right 16
    swap    d1
    divu.w  d0,d1	    ; divide high order
    move.w  (sp)+,d1	    ; combine remainder(high) with low word of dividend
    divu.w  d0,d1	    ; divide low order
L4:
    clr.w   d1		    ; unsigned extend, get remainder from high order
    swap    d1		    ; then negate to match, note: swap/neg.w/ext.l
    neg.l   d1		    ; won't work, remainder may be >= 2**15
    move.l  d1,d2	    ; must also put it where div32 leaves it
    jmp	    (a0)
L5:			    ; dividend < 0, mod is negative
    neg.l   d1
    lea	    L6(pc),a0	    ; do unsigned mod/divide
    bra.s   mod32	    ; no overflow adjustment necessary
L6:			    ; mod32 returns here
    move.l  d2,d1	    ; mod32 supplies negated mod 
    move.l  (sp)+,a2
    rts


