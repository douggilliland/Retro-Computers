*   mx_xcptn.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   mx_xcptn.o goes into LIBMS, LIBMSF, LIBMSFF and LIBMSMX

 .ifdef M68020
HIGH_END = 0
 .else
 .ifdef M68040
HIGH_END = 0
 .else
 .ifdef M68332
HIGH_END = 0
 .endif
 .endif
 .endif

    .opt    proc=68020

    .text
    .align  4

    .globl  __set_errno_edom
    .globl  __set_errno_erange
    .globl  __dp_div_zero
    .globl  __fp_div_zero
    .globl  __ff_div_zero
    .globl  DP_HUGE
    .globl  FP_HUGE
    .globl  FF_HUGE

    .extern __errno

DP_HUGE:
    .long   0x7ff00000,0x0
FP_HUGE:
    .long   0x7f800000
FF_HUGE:
    .long   0xffffff7f
L1:
    .byte   "Floating Point Divide by Zero Exception.\n\0"

    .align  2
__dp_div_zero:
__fp_div_zero:
__ff_div_zero:
    link    a6,#-24
    movem.l d0-d2/a0-a1,-24(a6)	    ; save __eputs scratch registers
    pea	    L1(pc)
 .ifdef HIGH_END
    bsr.l   __eputs
 .else
    move.l  #__eputs,a0
    suba.l  #x,a0
x:
    jsr	    x(pc,a0.l)
 .endif
    movem.l -24(a6),d0-d2/a0-a1
*   move.l  ...,d2		    ; reset result in d2:d3 if necessary
*   move.l  ...,d3
    unlk    a6
    rts

__set_errno_edom:
 .ifdef INT_16
 .ifdef A5_16
    move.w  #20,(__errno.w,a5)	    ; set EDOM
 .else
 .ifdef A5_32
    move.w  #20,(__errno.l,a5)	    ; set EDOM
 .else
    move.w  #20,__errno		    ; set EDOM
 .endif
 .endif
 .else
 .ifdef A5_16
    move.l  #20,(__errno.w,a5)	    ; set EDOM
 .else
 .ifdef A5_32
    move.l  #20,(__errno.l,a5)	    ; set EDOM
 .else
    move.l  #20,__errno		    ; set EDOM
 .endif
 .endif
 .endif
    rts

__set_errno_erange:
 .ifdef INT_16
 .ifdef A5_16
    move.w  #21,(__errno.w,a5)	    ; set ERANGE
 .else
 .ifdef A5_32
    move.w  #21,(__errno.l,a5)	    ; set ERANGE
 .else
    move.w  #21,__errno		    ; set ERANGE
 .endif
 .endif
 .else
 .ifdef A5_16
    move.l  #21,(__errno.w,a5)	    ; set ERANGE
 .else
 .ifdef A5_32
    move.l  #21,(__errno.l,a5)	    ; set ERANGE
 .else
    move.l  #21,__errno		    ; set ERANGE
 .endif
 .endif
 .endif
    rts
