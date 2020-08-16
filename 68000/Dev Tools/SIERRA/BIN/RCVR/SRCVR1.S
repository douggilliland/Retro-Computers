;   Run-Time Header for Sierra Systems serial receiver (S record / $ record)
;
;   Copyright 1987 by Sierra Systems.  All rights reserved.

.ifdef	    M68020
    .opt    proc=68020
.else
    .opt    proc=68000
.endif

    .globl  start
    .globl  _putchx
    .globl  _getchx
    .globl  _putchx1
    .globl  _getchx1

    .opt    fr16		;set position-independent mode
    .opt    nopca
    .opt    pcf
    .text
    .align  4

start:
    moveq   #0,d1
    bra.s   L1
echo_entry:			;load address + 4
    moveq   #1,d1
L1:
.ifdef	    STACK
    movea.l #STACK,sp		;set the system stack location
.endif
    jsr	    startup		;turn on cache or whatever ...
    lea	    -200(sp),sp		;make room for static data
    movea.l sp,a5		;set global address pointer a5
    move.l  d1,-(sp)
    jsr	    _srcvr
    lea	    204(sp),sp		;restore stack
    bra.s   monitor		;return to monitor

startup:
.ifdef	    M68020
    moveq   #0x8,d0
    movec   d0,cacr		;clear cache
    moveq   #0x1,d0
    movec   d0,cacr		;enable cache
.endif
    rts

monitor:
.ifdef	    M68020
    moveq   #0,d0
    movec   d0,cacr		;disable cache
.endif

;   *****************************************
;   * AS SHIPPED, THE REMAINDER OF THE FILE *
;   * IS SETUP TO WORK WITH MOTOROLA XXXBUG *
;   *****************************************

;   RETURN TO SYSTEM

    trap    #15
    .word   0x63

;   OUTPUT A CHARACTER TO THE SERIAL PORT CONNECTED TO THE TERMINAL
;
;   the character to be output is stored as a long at 4(sp)
    
_putchx:
    move.l  4(sp),d0
    move.b  d0,-(sp)
    trap    #15
    .word   0x20
    rts

;   GET A CHARACTER FROM THE SERIAL PORT CONNECTED TO THE TERMINAL
;
;   the character is returned as a long in d0

_getchx:
    subq.l  #2,sp
    trap    #15
    .word   0x0
    clr.l   d0
    move.b  (sp)+,d0
    rts

;   THE LAST TWO ROUTINES ARE NOT NEEDED FOR THE PC/AT VERSION
.ifndef	PC_AT

;   OUTPUT A CHARACTER TO THE SERIAL PORT CONNECTED TO THE HOST COMPUTER
;
;   the character to be output is stored as a long at 4(sp)

_putchx1:
    move.l  4(sp),d0
    move.b  d0,-(sp)
    move.w  #0x20,-(sp)
    move.w  #1,-(sp)
    trap    #15
    .word   0x60
    rts

;   GET A CHARACTER FROM THE SERIAL PORT CONNECTED TO THE HOST COMPUTER
;
;   the character is returned as a long in d0

_getchx1:
    subq.l  #2,sp
    move.w  #0x0,-(sp)
    move.w  #1,-(sp)
    trap    #15
    .word   0x60
    clr.l   d0
    move.b  (sp)+,d0
    rts

.endif
