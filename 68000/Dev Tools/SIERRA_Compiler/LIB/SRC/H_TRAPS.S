*   h_trap.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   Floating point trap exception handlers
*
*   Exception processing functions in order called:
*
*   <processor exception>
*   <excpetion handler>	traps.s, h_traps.s
*   __xraise		signal.c
*   dflt_sig		signal.c
*   disp_xcptn_info	C Run-Time Header
*   __xcptn_info_XXX	xcptn.c

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

SIGFPE = 4			; as defined in <signal.h>

    .opt    proc=68020/68881

    .globl  protocol
    .globl  bsun
    .globl  inex
    .globl  divz
    .globl  unfl
    .globl  operr
    .globl  ovfl
    .globl  snan
    .globl  unsupp

    .extern __xraise

    .text
    .align  2

  .ifdef M68020
protocol:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #2,d0
    bra.s   common_code
  .endif
bsun:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #3,d0
    bra.s   common_code
inex:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #4,d0
    bra.s   common_code
divz:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #5,d0
    bra.s   common_code
unfl:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #6,d0
    bra.s   common_code
operr:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #7,d0
    bra.s   common_code
ovfl:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #8,d0
    bra.s   common_code
snan:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #9,d0
  .ifdef M68040
    bra.s   common_code
unsupp:
    movem.l d0-d7/a0-a7,-(sp)
    moveq   #10,d0
  .endif

common_code:
    fsave   -(sp)		; save fp co-processor state
  .ifndef M68040
    move.b  (sp),d1		; get version number
    beq.s   dont_set_exc_pend	; branch if it is a null fp frame
    clr.l   d1
    move.b  1(sp),d1		; get state frame size
    bset    #3,(sp,d1)		; set bit 27 (exc_pend) of BIU
dont_set_exc_pend:
  .endif
    moveq   #0,d2
    move.b  1(sp),d2		; get the size of the fsave state frame -4
    addq.w  #4,d2		; size of fsave state frame
    swap    d2			; move the size into position XX0000
    fmovem.x fp0-fp7,-(sp)
    moveq   #24,d1
    asl.l   d1,d0
    add.l   d2,d0		; add the size into the signal number
    add.l   #SIGFPE,d0
    move.l  d0,-(sp)
  .ifdef HIGH_END
    bsr.l   __xraise		; call signal interface function
  .else
    move.l  #__xraise,a0
    suba.l  #jsr1,a0
jsr1:
    jsr	    jsr1(pc,a0.l)
  .endif
    addq.w  #4,sp
    fmovem.x (sp)+,fp0-fp7
  .ifdef M68040
    move.b  (sp),d1		; get version number
    cmpi.b  #0x40,d1		; check if busy fpu frame
    bne.s   do_frestore		; no, no special handling required
    btst    #1,0x48(sp)		; test E3 bit
    bne.s   e3_set		; yes, goto e3_set
    adda.l  #100,sp		; throw away frame
    bra.s   no_frestore
e3_set:
    bclr    #1,0x48(sp)		; clear E3 bit
do_frestore:
    frestore (sp)+		; restore fp co-processor state
no_frestore:	
  .else
    frestore (sp)+		; restore fp co-processor state
  .endif
    movem.l (sp)+,d0-d7/a0-a7
    rte

