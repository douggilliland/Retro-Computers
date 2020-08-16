*   h_ldtrap.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   Load floating point trap vectors -- called from C Run-Time Header

 .ifdef PC_REL
    .opt    pcf
 .endif

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

    .opt    proc=68020/68881
    .text
    .align  2

SIGFPE = 4			; as defined in <signal.h>

    .globl  ldftraps
    .globl  ldftraps10

    .extern protocol
    .extern bsun
    .extern inex
    .extern divz
    .extern unfl
    .extern operr
    .extern ovfl
    .extern snan
    .extern unsupp

ldftraps10:
    movec   vbr,a0
    bra.s   ld_traps
ldftraps:

 .ifdef HIGH_END
    .opt    fr32
    movec   vbr,a0
 .else
    .opt    fr16
    suba.l  a0,a0
 .endif

ld_traps:
 .ifdef M68020
    lea	    protocol,a1
    move.l  a1,0x34(a0)
 .endif
    lea	    0xc0(a0),a0
    lea	    bsun,a1
    move.l  a1,(a0)+
    lea	    inex,a1
    move.l  a1,(a0)+
    lea	    divz,a1
    move.l  a1,(a0)+
    lea	    unfl,a1
    move.l  a1,(a0)+
    lea	    operr,a1
    move.l  a1,(a0)+
    lea	    ovfl,a1
    move.l  a1,(a0)+
    lea	    snan,a1
    move.l  a1,(a0)+
 .ifdef M68040
    lea	    unsupp,a1
    move.l  a1,(a0)+
 .endif
    rts
