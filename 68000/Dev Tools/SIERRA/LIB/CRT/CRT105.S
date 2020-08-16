*   crt105.s
*
*   Copyright 1992 - 1994 by Sierra Systems.  All rights reserved.
*
*   Sierra Systems C Run Time (CRT) header, 105bug version
*
*   Define QUICKFIX when assembling for use with the QuickFix debugger.

    .opt    proc=68010

    .globl  start
    .globl  qstop
    .globl  __exit
    .globl  _putchx
    .globl  _getchx
    .globl  _checkchx
;   .globl  __disp_xcptn_info

    .text
    .align  2

start:
;   movea.l #0x........,sp  ; set the system stack location
;   bsr.s   startup	    ; turn on cache or whatever
;   jsr	    ldtrapsx	    ; load exception vectors
;   jsr	    ldftraps	    ; load floating point traps (or dummy)
    jsr	    initfpcr	    ; initialize floating point control register 
			    ; (overflow, div. by zero and operand error)
    jsr	    load_tbl	    ; fill bss sections and copy sections from
			    ; their load to run-time address
    jsr	    __main
    move.l  d0,-(sp)	    ; pass return value to _exit
    jsr	    _exit	    ; call atexit functions, then jump to __exit
__exit:
;   bsr.s   exit_code
qstop:
    link    a6,#0	    ; create frame for traceback - unlk not needed
    bra.s   monitor	    ; return to monitor

;__disp_xcptn_info:	    ; exception handler
;   jmp	    __xcptn_info_010; default 68010 exception handler
    
startup:
    rts

;exit_code:
;   rts

monitor:
    move.l  (sp)+,d0	    ; put return value from _exit into d0
    trap    #15
    .word   0x63	    ; return to 105bug
    
_putchx:		    ; output a character to the terminal port
    link    a6,#0
    move.l  8(sp),d0
    move.b  d0,-(sp)
    trap    #15
    .word   0x20
    unlk    a6
    rts

_getchx:		    ; get a character from the terminal port
    subq.l  #2,sp
    trap    #15
    .word   0x0
    clr.l   d0
    move.b  (sp)+,d0
    rts

_checkchx:		    ; are characters waiting at the terminal port
    clr.l   d0
    trap    #15
    .word   0x1
    seq	    d0
    addq.b  #1,d0
    rts

 .ifdef QUICKFIX
    .include "qlibc.s"
 .endif

