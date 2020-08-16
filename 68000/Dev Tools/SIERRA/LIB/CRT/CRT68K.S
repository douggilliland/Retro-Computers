*   qcrt68k.s
*
*   Copyright 1987 - 1992 by Sierra Systems.  All rights reserved.
*
*   Sierra Systems C Run Time (CRT) header for typical 68000 system
*   using a MC6850 UART (serial device) located at address 0x9ff01.
*
*   Define QUICKFIX when assembling for use with the QuickFix debugger.

    .opt    proc=68000

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
;   jsr	    ldtraps	    ; load exception vectors, including illegal
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
;   jmp	    __xcptn_info_000; default 68000 exception handler

startup:
    rts

;exit_code:
;   rts

monitor:		    ; return to monitor
    move.l  #10000,d1	    ; delay for last character to be output
loop1:
    subq.l  #1,d1
    bne	    loop1
    move.l  (sp)+,d0	    ; put return value from _exit into d0
    jmp	    0x80008	    ; back to monitoa located at 0x80008

_putchx:		    ; output a character to the terminal port
    movea.l #0x9ff01,a0
    movea.l #0x9ff03,a1
    moveq   #1,d0
loop2:
    btst    d0,(a0)
    beq	    loop2
    move.b  7(sp),(a1)
    rts	

_getchx:		    ; get a character from the terminal port
    movea.l #0x9ff01,a0
    movea.l #0x9ff03,a1
    moveq   #0,d0
loop3:
    btst    d0,(a0)
    beq	    loop3
    move.b  (a1),d0
    andi.b  #0x7f,d0
    rts	

_checkchx:		    ; are characters waiting at the terminal port
    nop			    ; not implemented
    rts

 .ifdef QUICKFIX
    .include "qlibc.s"
 .endif

