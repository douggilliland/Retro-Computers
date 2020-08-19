*   h_ldexp.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.
*
*   double ldexp(double x, int exponent)

    .opt    proc=68020/68881
    .text
    .align  2

    .globl  _ldexp
    .globl  ldexp

_ldexp:
ldexp:

 .ifdef M68040

    link    a6,#0
    fmove.d (8,a6),fp0		    ; (8,a6) is argument x (8 bytes)
    fbeq.w  rtrn		    ; jmp if zero
    fmove.l fpsr,d0
    btst    #24,d0
    bne.s   nan
    btst    #25,d0
    bne.s   infinity
    move.l  (8,a6),d0		    ; move value into d0:a0
    movea.l (12,a6),a0
    move.l  d0,d1
    andi.l  #0x800fffff,d0	    ; remove exponent from d0
    swap    d1			    ; move exponent into d1
    lsr.w   #4,d1
    andi.w  #0x7ff,d1
    ext.l   d1
 .ifdef INT_16
    movea.w (16,a6),a1
    cmpa.l  #0x7ff,a1		    ; is exp infinity
    bge.s   infinity
    add.l   a1,d1		    ; add exp to value exponent
 .else
    cmpi.l  #0x7ff,(16,a6)	    ; is exp infinity
    bge.s   infinity
    add.l   (16,a6),d1		    ; add exp to value exponent
 .endif
    ble.s   zero		    ; jmp if the result is <= zero
    cmpi.l  #0x7ff,d1		    ; is the result infinity
    bge.s   infinity
    swap    d1			    ; place the new exponent back into value
    lsl.l   #4,d1
    or.l    d1,d0
    move.l  a0,-(sp)
    move.l  d0,-(sp)
    fmove.d (sp)+,fp0
rtrn:
    unlk    a6
    rts
nan:
    bsr.w   __set_errno_edom
    bra.s   rtrn
infinity:
    pea	    rtrn(pc)
    btst    #7,(8,a6)
    beq.w   __set_errno_erange_p
    bra.w   __set_errno_erange_n
zero:
    fmove.w #0,fp0
    bra.s   rtrn

 .else

    fmove.d	(4,sp),fp0	    ; 4(sp) is argument x (8 bytes long)
 .ifdef INT_16
    fscale.w	(12,sp),fp0	    ; multiply x by 2 ** exponent
 .else
    fscale.l	(12,sp),fp0	    ; multiply x by 2 ** exponent
 .endif
    fmove.d	fp0,-(sp)	    ; force into double to ckeck for ERANGE
    addq.w	#8,sp
    fmove.l	fpsr,d0
    btst	#12,d0		    ; test for OVERFLOW
    bne.s	infinity
    rts
infinity:
    btst	#27,d0
    bne.w	__set_errno_erange_n
    bra.w	__set_errno_erange_p
    rts

 .endif
