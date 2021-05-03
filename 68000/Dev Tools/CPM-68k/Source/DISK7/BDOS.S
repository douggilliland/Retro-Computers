        .globl _bdos

_bdos:  move.w  4(sp),d0
        move.l  6(sp),d1
        trap    #2
        rts

        .end
