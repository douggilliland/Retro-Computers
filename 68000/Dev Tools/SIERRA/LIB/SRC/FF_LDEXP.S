*   ff_ldexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   Fast (Motorola) Single Precision Version
*
*   single ldexp(single value, int exp)

    .opt    proc=68000

    .opt    ffp
    .text
    .align  2

 .ifdef LIBMSMX
    .globl  _ldexpff
    .globl  ldexpff
_ldexpff:
ldexpff:

 .else
    .globl  _ldexp
    .globl  ldexp
_ldexp:
ldexp:
 .endif

    link    a6,#-16
    movem.l d2-d3,-16(a6)
    move.w  10(a6),d0
    bne.s   non_zero		    ; jmp if value is non_zero
zero:
    moveq   #0,d2		    ; set return value to 0.0
    bra.s   xit
infinity:
    moveq   #-1,d2		    ; return +/- infinity and set errno
    btst    #7,11(a6)
    bne.s   minus_inf
    bclr    #7,d2
minus_inf:
    bsr.w   __set_errno_erange
    bra.s   xit
non_zero:
    move.l  8(a6),d2		    ; move value into d2
    move.w  d2,d1
    andi.l  #0xffffff80,d2	    ; remove exponent from d2
    andi.w  #0x7f,d1		    ; move exponent into d1
    ext.l   d1
 .ifdef INT_16
    move.w  12(a6),d0
    ext.l   d0
    add.l   d0,d1		    ; add exp to value exponent
 .else
    add.l   12(a6),d1		    ; add exp to value exponent
 .endif
    ble.s   zero		    ; jmp if the result is <= zero
    cmpi.l  #0x7f,d1		    ; is the result infinity
    bgt.s   infinity
    or.b    d1,d2		    ; place the new exponent back into value
xit:
    movea.l (a6),a1
    move.l  d2,-(a1)
    movem.l -16(a6),d2-d3
    unlk    a6
    rts	

