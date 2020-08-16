*   dp_frexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   double frexp(double value, int *exp)

    .opt    proc=68000

    .text
    .align  2

    .globl  _frexp
    .globl  frexp

_frexp:
frexp:
    link    a6,#-16
    movem.l d2-d3,-16(a6)
    move.l  16(a6),a0
    move.w  8(a6),d0		    ; test value for NAN
    add.w   d0,d0
    beq.s   zero		    ; jmp if value is zero
    cmpi.w  #0xffe0,d0
    bcs.s   not_nan_nor_inf
    moveq   #0,d2
 .ifdef INT_16
    move.w  d2,(a0)		    ; set *exp to 0
 .else
    move.l  d2,(a0)		    ; set *exp to 0
 .endif
    andi.w  #0x1f,d0
    beq.s   infinity
nan:
    lea	    nan_rtrn(pc),a0
    bra.w   DNANRS
nan_rtrn:		
    bsr.w   __set_errno_edom
    bra.s   xit

infinity:
    lea	    erange_rtrn(pc),a0	    ; return +/- infinity and set errno
    btst    #7,8(a6)
    beq.s   plus_inf
    bra.w   MDHUGE
plus_inf:
    bra.w   DHUGE
erange_rtrn:
    bsr.w   __set_errno_erange
    bra.s   xit

zero:
    moveq   #0,d2		    ; set retrun value to 0.0
    move.l  d2,d3
 .ifdef INT_16
    move.w  d2,(a0)		    ; set *exp to 0
 .else
    move.l  d2,(a0)		    ; set *exp to 0
 .endif
    bra.s   xit

not_nan_nor_inf:
    move.l  8(a6),d2		    ; move value into d2:d3
    move.l  12(a6),d3
    move.l  d2,d1		    ; save upper half of value with exponent
    andi.l  #0x800fffff,d2	    ; remove exponent from value
    ori.l   #0x3fe00000,d2	    ; insert 2^-1 exponent back into value
    swap    d1			    ; move original exponent from value to d1
    lsr.w   #4,d1
    andi.w  #0x7ff,d1		    ; mask off original exponent
    subi.w  #0x3fe,d1		    ; normalize original exponent
 .ifdef INT_16
    move.w  d1,(a0)		    ; return exponent in *exp
 .else
    ext.l   d1
    move.l  d1,(a0)		    ; return exponent in *exp
 .endif

xit:
    movea.l (a6),a1
    move.l  d2,-8(a1)
    move.l  d3,-4(a1)
    movem.l -16(a6),d2-d3
    unlk    a6
    rts	

