*   setjmp.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
*
*   int setjmp(jmp_buf env)
*
*   void longjmp(jmp_buf env, int value)

    .text
    .align  2

    .opt    proc=68020/68881

    .globl  _setjmp
    .globl  _longjmp
    .globl  setjmp
    .globl  longjmp

_setjmp:
setjmp:
    move.l	(4,sp),a0	    ; get jmpbuf address
 .ifdef FP_REGS
    movem.l	d2-d7/a2-a7,(a0)    ; put registers in buffer
    fmovem.x	fp2-fp7,(48,a0)	    ; put fp registers in buffer
    move.l	(sp),(120,a0)	    ; store setjmp return address
 .else
    movem.l	d2-d7/a2-a7,(a0)    ; put registers in buffer
    move.l	(sp),(48,a0)	    ; store setjmp return address
 .endif
    moveq.l	#0,d0		    ; returns zero
    rts

_longjmp:
longjmp:
    move.l	(4,sp),a0	    ; get jmpbuf address
 .ifdef INT_16
    move.w	(8,sp),d0	    ; get return value
 .else
    move.l	(8,sp),d0	    ; get return value
 .endif
    bne.s	L1		    ; 0 return value is
    moveq.l	#1,d0		    ; changed to 1
L1:
 .ifdef FP_REGS
    movem.l	(a0)+,d2-d7/a2-a7   ; restore registers
    fmovem.x	(a0)+,fp2-fp7	    ; restore fp registers
 .else
    movem.l	(a0)+,d2-d7/a2-a7   ; restore registers
 .endif
    move.l	(a0),(a7)	    ; restore return address
    rts
