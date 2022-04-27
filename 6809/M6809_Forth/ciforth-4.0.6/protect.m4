dnl  $Id: protect.m4,v 4.1.2.1 2004/11/01 20:45:21 albert Exp $  M4 file to handle siwtching from to preotected mode
dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
divert(-1)
_BITS16_( {define({IDENTIFY_PROT},{IDENTIFY_16})})
_BITS32_( {define({IDENTIFY_PROT},{IDENTIFY_32})})
dnl NOTE: $+..+CW is the address of the next instruction in the
dnl protected mode code segment. the offset makes it relative w.r.t. switch segment.
define({SAVE_SP},{
        MOV     _CELL_PTR[SPSAVE],SPO
        AND     AX,AX
        MOV     SPO,AX})dnl
dnl Switch from protected mode stay at the same place.
define({JMPHERE_FROM_PROT},{
        JMP     GDT_SWITCH: _AP_+3+CW+M4_SWITCHOFFSET
        MOV EAX,CR0
        DEC AL
        MOV CR0,EAX            _C{set real mode}
dnl The curly brackets prevent AX to be expanded to EAX
        SET_16_BIT_MODE
        MOV     {AX},SWITCHSEGMENT
        MOV     DS,{AX}
        MOV     ES,{AX}})dnl
dnl Do everything to restore coming from Forth.
define({JMPHERE_FROM_FORTH},{
        SAVE_SP
        JMPHERE_FROM_PROT
        MOV     {AX},SS_RST _C {Make stack valid}
        MOV     SS,{AX}
        STI})dnl
dnl Switch from real mode stay at the same place.
define({JMPHERE_FROM_REAL},{
        MOV EAX,CR0
        INC AL
        MOV CR0,EAX            _C{set protected mode}
        SET_16_BIT_MODE
        JMP    GDT_CS: _AP_+5
        _BITS32_({SET_32_BIT_MODE})
        MOV     AX,GDT_DS
        MOV     DS,AX
        MOV     ES,AX
        MOV     SS,AX})dnl
define({RESTORE_SP},{
        MOV     SPO,_CELL_PTR[SPSAVE]})dnl
dnl Do everything to setup going to Forth.
define({JMPHERE_FROM_OS},{
        CLI
        JMPHERE_FROM_REAL
        RESTORE_SP})dnl
