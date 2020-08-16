;   Run-Time Header for Sierra Systems parallel receiver used with pldr
;
;   Copyright 1987 by Sierra Systems.  All rights reserved.

.ifdef	    M68020
    .opt    proc=68020
.else
    .opt    proc=68000
.endif
    .opt    fr16	    ;set position-independent mode
    .opt    nopca
    .opt    pcf
    .text
    .align  4

.ifdef	    STACK
    movea.l #STACK,a7	    ;set the system stack location
.endif
    jsr	    startup
    jsr	    _prcvr	    ;call receiver
    move.l  #50000,d0	    ;delay to give piggyback ROM chance to re-enable
L10:
    subq.l  #1,d0
    bne.s   L10
    cmpa.w  #-1,a0
    beq.s   monitor	    ;exit if a -1 is returned by _prcvr
    jsr	    (a0)	    ;start execution at address returned by _prcvr

startup:
.ifdef	    M68020
    moveq   #0x8,d0
    movec   d0,cacr	    ;clear cache
    moveq   #0x1,d0
    movec   d0,cacr	    ;enable cache
.endif
    rts

monitor:
.ifdef	    M68020
    moveq   #0,d0
    movec   d0,cacr	    ;disable cache
.endif
    trap    #15		    ;RETURN TO SYSTEM (currently for Motorola XXXBUG)
    .word   0x63

    .globl  _exit
