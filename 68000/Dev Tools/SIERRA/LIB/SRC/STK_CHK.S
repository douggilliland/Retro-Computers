*   stk_chk.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
*
*   Check the stack to make sure that it will not run into the heap.

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
msg:
    .byte   "stack/heap overlap (exiting)\n\0"
    .align  2

    .globl  __stk_ck

    .extern __heap_base
    .extern heap_org

__stk_ck:
 .ifdef A5_16
    movea.l (__heap_base.w,a5),a0   ; get current bottom of available heap
 .else
 .ifdef A5_32
    movea.l (__heap_base.l,a5),a0   ; get current bottom of available heap
 .else
    movea.l __heap_base,a0	    ; get current bottom of available heap
 .endif
 .endif
    move.l  a0,d1
    tst.l   d1
    bne.s   L2
    movea.l #heap_org,a0	    ; if NULL, use __heap_org
L2:
    adda.l  #100,a0		    ; add a safety margin
    adda.l  d0,a0		    ; adjust for stack space to be used by
    cmpa.l  sp,a0		    ; current function
    blt.s   L4
    pea	    msg(pc)
 .ifdef HIGH_END
    bsr.l   __eputs
    bsr.l   _exit
 .else
    move.l  #__eputs,a0
    suba.l  #jsr1,a0
jsr1:
    jsr	    jsr1(pc,a0.l)
    move.l  #_exit,a0
    suba.l  #jsr2,a0
jsr2:
    jsr	    jsr2(pc,a0.l)
 .endif
L4:
    rts
