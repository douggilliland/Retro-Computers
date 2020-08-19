*   crt306.s
*
*   Copyright 1993 - 1994 by Sierra Systems.  All rights reserved.
*
*   Sierra Systems 68306 C Run Time (CRT) header, 306MON version
*
*   Define QUICKFIX when assembling for use with the QuickFix debugger.

    .opt    proc=68000
;   .opt    pcf

    .globl  start
    .globl  qstop
    .globl  __exit
    .globl  _putchx
    .globl  _getchx
    .globl  _checkchx
;   .globl  __disp_xcptn_info

    .globl  __start_timer
    .globl  __stop_timer
    .globl  __getch_port
    .globl  __putch_port
    .globl  __checkch_port

    .text
    .align  2

start:
    movea.l #0x7fff0,sp	    ; set the system stack location
;   bsr.s   startup	    ; turn on cache or whatever
;   jsr	    ldtrapsx	    ; load exception vectors
;   jsr	    ldftraps	    ; load floating-point traps (or dummy)
    jsr	    initfpcr	    ; initialize floating point control register 
			    ; (overflow, div. by zero and operand error)

; Initialize 68306 TIMER and DUART interrupts (uncomment the following
; statement) if the functions described in Reference Manual Section 13.4,
; "68306 Specific Functions" are used independent of either the 306MON
; debug monitor or QuickFix monitor. Note that init_tm_duart is defined in
; the library lib306.68.
 
;   jsr	    init_tm_duart   ; initialize 68306 TIMER and DUART interrupts
			    
;   movea.l #0x........,a5  ; set a5-relative data location
;   lea	    start,a2	    ; set load table offset at run-time
    jsr	    load_tbl	    ; fill bss sections and copy sections from
			    ; their load to run-time address
    jsr	    __main
    move.l  d0,-(sp)	    ; pass return value to _exit
    jsr	    _exit	    ; call atexit functions, then jump to __exit
__exit:
;   bsr.s   exit_code
qstop:
    bra.s   monitor	    ; return to monitor
    
;__disp_xcptn_info:	    ; exception handler
;   jmp	   __xcptn_info_000 ; default 68000 exception handler
    
startup:
;   rts

exit_code:
;   rts

_putchx:		    ; output a character to the terminal port
    move.l  4(sp),d0
    trap    #15
    .word   0x2
    rts

_getchx:		    ; get a character from the terminal port
    trap    #15
    .word   0x1
    rts

_checkchx:		    ; get the number of characters waiting at terminal port
    trap    #15
    .word   0x3
    rts

monitor:
    move.l  (sp)+,d0	    ; put return value from _exit into d0
    trap    #15
    .word   0x0		    ; return to 306 monitor

; Trap #15 versions of functions defined in lib306.68 follow below:
; Note that all integer arguments expected to be passed as 4 bytes.

__checkch_port:		    ; characters waiting a specified port
    move.l  4(sp),d0
    cmpi.b  #'A',d0
    bne.s   cpb
    trap    #15
    .word   0x6
    rts
cpb:
    trap    #15
    .word   0x9
    rts

__getch_port:		    ; input a character from specified port
    move.l  4(sp),d0
    cmpi.b  #'A',d0
    bne.s   gpb
    trap    #15
    .word   0x4
    rts
gpb:
    trap    #15
    .word   0x7
    rts

__putch_port:		    ; output a character to specified port
    move.l  8(sp),d0
    move.l  4(sp),d1
    cmpi.b  #'A',d1
    bne.s   ppb
    trap    #15
    .word   0x5
    rts
ppb:
    trap    #15
    .word   0x8
    rts

__start_timer:		    ; start the 68306 timer
    trap    #15
    .word   0xa
    rts

__stop_timer:		    ; specify resolution and stop the timer 
    move.l  4(sp),d0
    trap    #15
    .word   0xb
    rts

 .ifdef QUICKFIX
    .include "qlibc.s"
 .endif

