*   ff_frexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   Fast (Motorola) Single Precision Version
*
*   float frexp(float value, int *exp)

    .opt    proc=68000

    .opt    ffp
    .text
    .align  2

 .ifdef LIBMSMX
    .globl  _frexpff
    .globl  frexpff
_frexpff:
frexpff:

 .else
    .globl  _frexp
    .globl  frexp
_frexp:
frexp:
 .endif

    link    a6,#-16
    movem.l d2-d3,-16(a6)
    move.l  12(a6),a0
    move.w  10(a6),d0
    bne.s   non_zero		    ; jmp if value is non-zero
    moveq   #0,d2		    ; set retrun value to 0.0
 .ifdef INT_16
    move.w  d2,(a0)		    ; set *exp to 0
 .else
    move.l  d2,(a0)		    ; set *exp to 0
 .endif
    bra.s   xit
non_zero:
    move.l  8(a6),d2		    ; move value into d2
    move.l  d2,d1		    ; save lower part of value with exponent
    andi.l  #0xffffff80,d2	    ; remove exponent from value
    ori.b   #0x40,d2		    ; insert 2^-1 exponent back into value
    andi.w  #0x7f,d1		    ; mask off original exponent
    subi.w  #0x40,d1		    ; normalize original exponent
 .ifdef INT_16
    move.w  d1,(a0)		    ; return exponent in *exp
 .else
    ext.l   d1
    move.l  d1,(a0)		    ; return exponent in *exp
 .endif
xit:
    movea.l (a6),a1
    move.l  d2,-(a1)
    movem.l -16(a6),d2-d3
    unlk    a6
    rts	

