*   h_frexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   double frexp(double value, int *exponent)


    .opt    proc=68020/68881
    .text
    .align  2

    .globl  _frexp
    .globl  frexp

_frexp:
frexp:

 .ifdef M68040

    link    a6,#0
    move.l  (16,a6),a0		    ; get pointer to *exp to return power
    fmove.d (8,a6),fp0		    ; get argument
    fmove.l fpsr,d0
    andi.l  #0x07000000,d0
    bne.s   zero_inf_or_nan	    ; jmp to exit if zero, infinity or nan
    move.l  (8,a6),d0		    ; move value into d0:a1
    movea.l (12,a6),a1
    move.l  d0,d1		    ; save upper half of value with exponent
    andi.l  #0x800fffff,d0	    ; remove exponent from value
    ori.l   #0x3fe00000,d0	    ; insert 2^-1 exponent back into value
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
    move.l  a1,-(sp)
    move.l  d0,-(sp)
    fmove.d (sp)+,fp0
xit:
    unlk    a6
    rts	
zero_inf_or_nan:
    moveq   #0,d0
 .ifdef INT_16
    move.w  d0,(a0)		    ; set *exp to 0
 .else
    move.l  d0,(a0)		    ; set *exp to 0
 .endif
    bra.s   xit

 .else

    fgetexp.d	(4,sp),fp0	    ; (4,sp) is argument value (8 bytes)
    fmove.l	fp0,d0		    ; move exponent into d0
    fgetman.d	(4,sp),fp0
    fbeq.w	rtrn		    ; jmp if zero
    moveq	#-1,d1
    fscale.l	d1,fp0		    ; divide mantissa by 2
    addq.l	#1,d0		    ; add 1 to exponent (multiply by 2)
rtrn:
    move.l	(12,sp),a0	    ; (12,sp) is address of exponent
 .ifdef INT_16
    move.w	d0,(a0)		    ; return exponent in *exponent
 .else
    move.l	d0,(a0)		    ; return exponent in *exponent
 .endif
    rts

 .endif
