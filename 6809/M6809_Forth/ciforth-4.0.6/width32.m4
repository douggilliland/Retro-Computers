dnl  $Id: width32.m4,v 4.1.2.1 2004/11/01 20:45:21 albert Exp $  M4 file to handle the develish FIG headers.
dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
SET_32_BIT_MODE         _C Assembler directive
define({CELL_M4},LONG)dnl
define({CELLWIDTH},4)dnl
define({LCELL},{{LIT, CW}})dnl
define({DC},{DD})dnl
define({AX},{EAX})dnl
define({BX},{EBX})dnl
define({CX},{ECX})dnl
define({DX},{EDX})dnl
define({DI},{EDI})dnl
define({SI},{ESI})dnl
define({BP},{EBP})dnl
define({SP},{ESP})dnl
define({SPO},{ESP})dnl
define({LODSW},{LODSD})dnl
define({WOR},{EAX})dnl
