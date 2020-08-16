*   traps.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   Non-FP trap exception handlers
*
*   Exception processing functions in order called:
*
*   <processor exception>
*   <exception handler>	traps.s, h_traps.s
*   __xraise		signal.c
*   dflt_sig		signal.c
*   disp_xcptn_info	crtXXX.s
*   __xcptn_info_XXX	xcptn.c

*   The following numbers are also defined in the standard header <signal.h>.
*   Any modifications to these numbers *MUST* be accompanied by identical
*   modifications <signal.h>.

SIGBUS	= 2	    ; bus error
SIGCHK	= 3	    ; chk instruction exception
SIGILL	= 5	    ; illegal instruction.
SIGINT	= 6	    ; interrupt
SIGTRAP	= 7	    ; trapv or trapcc instruction
SIGPRIV	= 8	    ; privilege violation
SIGADDR	= 9	    ; address error
SIGSPUR	= 11	    ; spuriuos interrupt
SIGZDIV	= 12	    ; divide by zero

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
    .align  2

    .globl  buserr
    .globl  addrerr
    .globl  illinst
    .globl  idivz
    .globl  chkinst
    .globl  trapinst
    .globl  privviol
    .globl  spurious

;   .globl  keyboard_int
;
;keyboard_int:			; SIGINT
;   movem.l d0-d7/a0-a7,-(sp)
;   move.l  #SIGINT,d0
;   bra.s   common_code

;   SIGUSER = 13
;   .globl  user_defined
;
;user_defined:			; SIGUSER
;   movem.l d0-d7/a0-a7,-(sp)
;   move.l  #SIGUSER,d0
;   bra.s   common_code

buserr:				; SIGBUS
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGBUS,d0
    bra.s   common_code

addrerr:			; SIGADDR
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGADDR,d0
    bra.s   common_code

illinst:			; SIGILL
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGILL,d0
    bra.s   common_code

idivz:				; SIGZDIV
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGZDIV,d0
    bra.s   common_code

chkinst:			; SIGCHK
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGCHK,d0
    bra.s   common_code

trapinst:			; SIGTRAP
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGTRAP,d0
    bra.s   common_code

privviol:			; SIGPRIV
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGPRIV,d0
    bra.s   common_code

spurious:			; SIGSPUR
    movem.l d0-d7/a0-a7,-(sp)
    move.l  #SIGSPUR,d0

common_code:
    move.l  d0,-(sp)
 .ifdef HIGH_END
    bsr.l   __xraise		; call signal interface function
 .else
    move.l  #__xraise,a0
    suba.l  #jsr1,a0
jsr1:
    jsr	    jsr1(pc,a0.l)	; call signal interface function
 .endif
    addq.w  #4,sp
    movem.l (sp)+,d0-d7/a0-a7
    rte

