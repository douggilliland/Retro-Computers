*   dp_ldexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   double ldexp(double value, int exp)

    .opt    proc=68000

    .globl  _ldexp
    .globl  ldexp

    .text
    .align  2

_ldexp:
ldexp:
    link    a6,#-16
    movem.l d2-d3,-16(a6)

    move.w  8(a6),d0		    ; test value for NAN
    add.w   d0,d0
    beq.s   zero		    ; jmp if value is zero
    cmpi.w  #0xffe0,d0
    bcs.s   not_nan_nor_inf
    andi.w  #0x1f,d0		    ; test value for infinity
    beq.s   infinity
nan:
    lea	    nan_rtrn(pc),a0
    bra.w   DNANRS
nan_rtrn:		
    bsr.w   __set_errno_edom
    bra.s   xit
zero:
    moveq   #0,d2		    ; set return value to 0.0
    move.l  d2,d3
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

not_nan_nor_inf:
    move.l  8(a6),d2		    ; move value into d2:d3
    move.l  12(a6),d3
    move.l  d2,d1
    andi.l  #0x800fffff,d2	    ; remove exponent from d2

    swap    d1			    ; move exponent into d1
    lsr.w   #4,d1
    andi.w  #0x7ff,d1
    ext.l   d1
 .ifdef INT_16
    move.w  16(a6),d0
    ext.l   d0
    cmpi.w  #0x7ff,d0		    ; is exp infinity
    bge.s   infinity
    add.l   d0,d1		    ; add exp to value exponent
 .else
    cmpi.l  #0x7ff,16(a6)	    ; is exp infinity
    bge.s   infinity
    add.l   16(a6),d1		    ; add exp to value exponent
 .endif
    ble.s   zero		    ; jmp if the result is <= zero
    cmpi.l  #0x7ff,d1		    ; is the result infinity
    bge.s   infinity
    swap    d1			    ; place the new exponent back into value
    lsl.l   #4,d1
    or.l    d1,d2

xit:
    movea.l (a6),a1
    move.l  d2,-8(a1)
    move.l  d3,-4(a1)
    movem.l -16(a6),d2-d3
    unlk    a6
    rts	

