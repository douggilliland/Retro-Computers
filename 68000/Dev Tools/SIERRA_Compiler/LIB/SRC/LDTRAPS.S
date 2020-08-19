*   ldtraps.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   Load non-fp exception trap vectors -- called from C Run-Time Header

*   Define SKIP_ILL_INST if the illegal instruction trap vector is NOT to be
*   loaded.  Many of the Motorola BUG monitors use the illegal instruction
*   trap and thus it should not be loaded by the user's application.
*
*   Define M68000 only when assembling for the LIBC.68 library.
*
*   The following numbers are defined in the standard header <signal.h>.

;SIGBUS	    = 2		; bus error
;SIGCHK	    = 3		; chk instruction exception
;SIGILL	    = 5		; illegal instruction.
;SIGINT	    = 6		; interrupt
;SIGTRAP    = 7		; trapv or trapcc instruction
;SIGPRIV    = 8		; privilege violation
;SIGADDR    = 9		; address error
;SIGSPUR    = 11	; spuriuos interrupt
;SIGZDIV    = 12	; divide by zero

    .opt    proc=68020

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

  .ifdef HIGH_END
    .opt    fr32
  .else
    .opt    fr16
  .endif

    .text
    .align  2

    .extern buserr
    .extern addrerr
    .extern idivz
    .extern chkinst
    .extern trapinst
    .extern privviol
    .extern spurious

  .ifdef M68000		    ; assembling for LIBC.68

  .ifdef SKIP_ILL_INST
    .globl  ldtrapsx
    .globl  ldtraps10x
  .else
    .extern illinst
    .globl  ldtraps
    .globl  ldtraps10
  .endif

  .ifdef SKIP_ILL_INST
ldtraps10x:
    movec   vbr,a0
    bra.s   ld_traps
ldtrapsx:
  .else
ldtraps10:
    movec   vbr,a0
    bra.s   ld_traps
ldtraps:
  .endif
    suba.l  a0,a0
ld_traps:

  .else			    ; not assembling for LIBC.68

  .ifdef SKIP_ILL_INST
    .globl  ldtrapsx
  .else
    .extern illinst
    .globl  ldtraps
  .endif
  .ifdef SKIP_ILL_INST
ldtrapsx:
  .endif
    movec   vbr,a0

  .endif

    lea	    buserr,a1
    move.l  a1,0x8(a0)
    lea	    addrerr,a1
    move.l  a1,0xc(a0)
  .ifndef SKIP_ILL_INST
    lea	    illinst,a1
    move.l  a1,0x10(a0)
  .endif
    lea	    idivz,a1
    move.l  a1,0x14(a0)
    lea	    chkinst,a1
    move.l  a1,0x18(a0)
    lea	    trapinst,a1
    move.l  a1,0x1c(a0)
    lea	    privviol,a1
    move.l  a1,0x20(a0)
    lea	    spurious,a1
    move.l  a1,0x60(a0)
;   lea	    keyboard_int,a1
;   move.l  a1,0xc0(a0)
;   lea	    user_defined,a1
;   move.l  a1,0x7c(a0)
    rts
