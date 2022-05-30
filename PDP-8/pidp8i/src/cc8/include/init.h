/*
 * This file is part of the CC8 cross-compiler.
 *
 * The CC8 cross-compiler is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License 
 * as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * The CC8 cross-compiler is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the CC8 cross-compiler as ../GPL3.txt.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

#asm

/ INIT.H SPECIFIC GLOBALS.  THESE HAVE TO DO WITH ADDITIONAL CODE HERE
/ AND NOT IN HEADER.SB.  THEY SHOULD ABUT THOSE BELOW.
/
/ THESE HAVE TO BE HIGH UP IN THE ZERO PAGE TO AVOID THE LOADER HELPER
/ ROUTINES PLACED IN EVERY CODE LOADER LINKS CODE INTO.  (EXCEPTING LIBC,
/ WHICH RUNS ON DIFFERENT RULES.)
ABSYM STRV 153
ABSYM PSTRL 154
ABSYM PSTRD 155
ABSYM PINIT 156
ABSYM PSTRI 157

/ GENERIC INIT GLOBALS SHARED WITH THE HEADER.SB IMPLEMENTATION; CHANGES
/ HERE SHOULD MATCH THOSE THERE.
/
/ WE ARE AVOIDING LOCATIONS 172-177: LOADER REPORTEDLY USES THESE!
ABSYM POP 160
ABSYM PSH 161
ABSYM JLC 162
ABSYM STKP 163
ABSYM PTSK 164
ABSYM POPR 165
ABSYM PCAL 166
ABSYM TMP 167
ABSYM GBL 170
ABSYM ZTMP 171

/
/
STK,    COMMN 7400
/
/
/
        ENTRY MAIN
MAIN,   BLOCK 2
        TAD GBLS
        DCA STKP
        TAD GBLS
        DCA GBL
        ISZ GBL     / LOCAL LITERALS = STKP+1
        TAD PVL
        DCA PSH
        TAD OVL
        DCA POP
        TAD MVL
        DCA PTSK
        TAD PVR
        DCA POPR
        TAD PVC
        DCA PCAL
        TAD SII
        DCA PINIT
        TAD SRI
        DCA PSTRI
        TAD SRD
        DCA PSTRD
        TAD SRL
        DCA PSTRL
        RIF
        TAD (6201           / BUILD CDF + IF INSTR
        DCA PCL1
        TAD PCL1
        DCA DCC0
        JMS MCC0
        CLA CMA
        MQL
        CALL 1,LIBC
        ARG STKP
        CALL 0,OPEN
        JMSI PCAL
        XMAIN
        CALL 0,EXIT
/
PUSH,   0
        CDF1
        ISZ STKP
        DCAI STKP
        TADI STKP
        JMPI PUSH
PPOP,   0
        CDF1
        DCA TMP
        TADI STKP
        MQL
        CMA
        TAD STKP
        DCA STKP
        TAD TMP
        JMPI PPOP
PUTSTK, 0
        JMSI POP
        SWP
        DCA JLC
        SWP
        DCAI JLC
        TADI JLC
        JMPI PUTSTK
POPRET, JMSI POP
        SWP
        DCA ZTMP
        SWP
        JMPI ZTMP
PCALL,  0
        CLA CLL
PCL1,   0
        TADI PCALL
        DCA ZTMP
        TAD PCALL
        IAC
        JMSI PSH        / PUSH RETURN
        CLA
        JMPI ZTMP
IINIT,  0
        DCA STRV
        JMPI IINIT
STRI,   0
        CDF4
        DCAI STRV
        CDF1
        ISZ STRV
        JMPI STRI
STRD,   0
        CDF4
        CLA
        TADI STRV
        CDF1
        ISZ STRV
        JMPI STRD       
STRL,   0
        CDF4
        CLA
        TADI STRV
        CDF1
        JMPI STRL       
PVL,    PUSH
OVL,    PPOP
MVL,    PUTSTK
SVL,    STK
PVR,    POPRET
PVC,    PCALL
SII,    IINIT
SRI,    STRI
SRD,    STRD
SRL,    STRL
/
#endasm

