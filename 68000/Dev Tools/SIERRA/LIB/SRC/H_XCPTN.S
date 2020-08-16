*   h_xcptn.s
*
*   Copyright 1991 by Sierra Systems.  All rights reserved.

    .opt    proc=68020/68881
    .text
    .align  4

nan:
    .long   0x7fffffff,0xffffffff
inf_p:
DP_HUGE:
    .long   0x7ff00000,0x00000000
inf_n:
    .long   0xfff00000,0x00000000

__set_errno_edom:
    fmove.d nan,fp0
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

__set_errno_erange_p:
    fmove.d inf_p,fp0
    bra.s   __set_errno_erange
__set_errno_erange_n:
    fmove.d inf_n,fp0
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
    
    .globl  __set_errno_edom
    .globl  __set_errno_erange_p
    .globl  __set_errno_erange_n
    .globl  __set_errno_erange

    .extern __errno


