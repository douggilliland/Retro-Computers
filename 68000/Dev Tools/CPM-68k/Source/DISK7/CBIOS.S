*	@(#)cbios.s	3.1		*
*
* Interface between C programs and BIOS
*
        .globl  _BIOS
_BIOS:  move    4(sp),d0
        move.l  6(sp),d1
        move.l  10(sp),d2
        trap    #3
        rts
        .end

_BIOS:  move    4(sp),d0
        mo