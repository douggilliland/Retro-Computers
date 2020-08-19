*   div32.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*   68000 32-bit divides
*
*   dividend: d1 (32)
*   divisor: d0 (32)
*   quotient (d1/d0): d1 (32)
*   scratch registers: d2, a0, and a1

*   32-bit by 32-bit divides:
*
*   ds32s32: divide signed 32 / signed 32 
*   du32u32: divide unsigned 32 / unsigned 32 

    .text
    .align  2

    .globl  __du32u32
    .globl  __ds32s32
    .globl  __mod1
    .globl  __mod2

__du32u32:		    ; u32 / s32 -> any
    lea	    L1(pc),a0	    ; must get control before return to user
    bra.s   div32   
L1:
__mod1:			    ; check 33rd multiply bit calculated by div32
    cmpa.w  #0,a1	    ; note: compares entire 32 bits
    beq.s   L4
L2:			    ; overflow - adjust quotient
    subq.w  #1,d1
    sub.l   d0,d2	    ; subtract true divisor (y)
    bhi.s   L2		    ; branch if d3 unsigned > y
    rts

L3:			    ; part of ds32s32
    neg.l   d1
L4:
    rts
L5:			    ; from ds32s32 d1 < 0
    neg.l   d1
    tst.l   d0
    bpl.s   L7
    neg.l   d0
    bra.s   L8		    ; both operands negative, quotient positive
L6:			    ; from ds32s32 d1 >= 0, d0 < 0, quotient negative
    neg.l   d0
L7:			    ; from ds32s32 d1 < 0,d0 >= 0, quotient negative
    lea	    L3(pc),a0	    ; must negate unsigned quotient before returning
    bra.s   div32

__ds32s32:		    ; s32 / s32 -> any
    tst.l   d1
    bmi.s   L5
    tst.l   d0
    bmi.s   L6
L8:			    ; quotient positive,
    move.l  (sp)+,a0	    ; return directly to caller

div32:			    ; common to all 32 by 32 div's, does unsigned div
    swap    d0
    movea.w d0,a1
    swap    d0
    move.w  a1,d2
    bne.s   L10		    ; branch if really must do 32 by 32 divide
    divu.w  d0,d1	    ; do 32 by 32 divide yielding 32 bit quotient
    bvs.s   L9
    swap    d1
    clr.w   d1
    swap    d1		    ; clear remainder in high order
    jmp	    (a0)
L9:
    move.w  d1,-(sp)	    ; save low order of dividend
    clr.w   d1		    ; shift right 16
    swap    d1
    divu.w  d0,d1	    ; get high order of quotient
    move.l  d1,d2
    move.w  (sp)+,d2	    ; combine remainder(high) with low word of dividend
    divu.w  d0,d2	    ; get low order of quotient
    swap    d1
    move.w  d2,d1	    ; combine halves of quotient
    jmp	    (a0)
L10:
__mod2:
    move.l  d1,-(sp)	    ; save original dividend
    and.w   #0xff00,d2
    bne.s   L14
    move.w  a1,d2
    and.w   #0x00f0,d2
    bne.s   L16
    move.l  d0,d2	    ; 0x000X shift right 4
    lsr.l   #4,d2
    lsr.l   #4,d1
L11:
    divu.w  d2,d1	    ; divide to get estimated quotient
    move.w  d1,d2	    ; multiply back out
    exg	    a1,d7
    mulu.w  d2,d7	    ; y.high x est_quo
    mulu.w  d0,d2	    ; y.low x est_quo
    swap    d2
    add.w   d7,d2
    swap    d2
    swap    d7
    addx.w  d7,d7
    ext.l   d7		    ; for cmpa at label mod1, which compares 32 bits
    exg	    d7,a1
    sub.l   (sp)+,d2	    ; subtract true dividend (x)
    bls.s   L13		    ; branch if d3 was unsigned <= x
L12:
    subq.w  #1,d1
    sub.l   d0,d2
    bhi.s   L12
L13:
    swap    d1
    clr.w   d1
    swap    d1		    ; in case 32-bit result desired
    jmp	    (a0)
L14:
    and.w   #0xf000,d2
    bne.s   L15
    move.l  a1,d2	    ; 0x0XXX shift right 12 = rotate rt 16 then left 4
    rol.l   #4,d2
    lsr.l   #8,d1	    ; 68000 can't shift by 12 (can't rot - need 0 fill)
    lsr.l   #4,d1
    bra.s   L11
L15:
    move.w  a1,d2	    ; 0xXXXX shift right 16
    clr.w   d1
    swap    d1
    bra.s   L11
L16:
    move.l  d0,d2	    ; 0x00XX: shift right 8
    lsr.l   #8,d2
    lsr.l   #8,d1
    bra.s   L11
