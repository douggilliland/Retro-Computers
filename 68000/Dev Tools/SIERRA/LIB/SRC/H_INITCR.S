*   h_initcr.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   initfpcr enables the divide_by_zero, operand_error and overflow
*   bits in the floating point condition register (fpcr)

    .opt    proc=68020/68881
    .text
    .align  2

    .globl  initfpcr

initfpcr:
    fmove.l #0x3400,fpcr
    rts
