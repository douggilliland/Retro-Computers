; FILE NAME zbug_mic68k.x68
; zBug V1.0.1 for MIC68K by @kanpapa
; The source code was assembled using Easy68K 
; V1.0 1st release
; V1.0.1 Added function to Load Motorola S-record S1 format

;
; Original FILE NAME U68K.ASM 
; 
; zBug V1.0 is a small monitor program for 68000-Based Single Board Computer
; The source code was assembled using C32 CROSS ASSEMBLER VERSION 3.0
;

; Copyright (c) 2002 WICHIT SIRICHOTE email kswichit@kmitl.ac.th
; 
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
;
;

;   CPU     "68000.TBL"      ; CPU TABLE
;   HOF     "BIN16"          ; HEX OUTPUT FORMAT
;   HOF     "MOT16"          ; OUTPUT MOTOROLA S-RECORD

;
; MIC68K MEMORY MAP
;
; 000000-00FFFF RAM 32Kx2
; 010000-9FFFFF -
; A00000-A0FFFF ROM 32Kx2
; A10000-DFFFFF -
; F00009-0B     ACIA1 63B50 (IC6)
; F20009-0B     ACIA2 63B50 (IC7)
; F40009-0F     PIA (IC1)
; F60009-1F     PTM (IC2)
;

; Use EASy68k Simulator
EASY68K_SIM	EQU 0		; set 0 to use ACIA1
;EASY68K_SIM	EQU 1		; set 1 to use EASy68K Sim68K I/O  

BIT_ESC      EQU 0              ; ESC BIT POSITION #0

;DCODE68K  EQU $400              ; DISASSEMBLER START ADDRESS (option)

RAM      EQU $000000            ; RAM START ADDRESS

;
; MONITOR MEMORY MAP
; $000000-$0003FF M68000 Exception Vector Table
; $00E000         SUPER_STACK/RAMBASE
; $00FFFF         RAM END
;
; $A00000         RESET Vector
; $A00008         MAIN(Monitor start)
;

;DIN      EQU $300001 
;DOUT     EQU $700001       

ACIAC    EQU $F00009
ACIAD    EQU ACIAC+2

ACIA2C    EQU $F20009
ACIA2D    EQU ACIA2C+2

;PIT      EQU $700001

INT_ON   EQU  $2000    ; BOTH, SET SUPERVISOR MODE, S=1
INT_OFF  EQU  $2700

RDRF    EQU 0           ; ACIAC Receive Data Register Full
TDRE    EQU 1           ; ACIAC Transmit Data Register Empty

SUPERVISOR_BIT EQU 5

TRACE_BIT EQU 7

CR      EQU 13
LF      EQU 10
SP      EQU 32
BS      EQU 8
RS      EQU $1E
ESC     EQU $1B

SUPER_STACK   EQU $00E000   ; SUPER STACK TOP Address
RAMBASE_INIT  EQU $00E000

;
; EXCEPTION VECTOR address
;
TRAP0   EQU RAM+$80
TRAP1   EQU TRAP0+4
TRAP2   EQU TRAP1+4
TRAP3   EQU TRAP2+4
TRAP4   EQU TRAP3+4
TRAP5   EQU TRAP4+4
TRAP6   EQU TRAP5+4
TRAP7   EQU TRAP6+4
TRAP8   EQU TRAP7+4
TRAP9   EQU TRAP8+4
TRAP10  EQU TRAP9+4
TRAP11  EQU TRAP10+4
TRAP12  EQU TRAP11+4
TRAP13  EQU TRAP12+4
TRAP14  EQU TRAP13+4
TRAP15  EQU TRAP14+4

BUS_ERROR EQU RAM+8
ADDRESS_ERROR EQU RAM+$C
ILLEGAL_INSTRUCTION EQU RAM+$10

   ORG $C0
;RAMBASE  DC.L   $130000   ; RAM BASE ADDRESS
RAMBASE  DS.L   1          ; RAM BASE ADDRESS

;
; ROM START
;
    ORG $A00000
   ; Reset start vector
   DC.L SUPER_STACK        ; TOP OF SUPERVISOR STACK $130000
   DC.L MAIN               ; MONITOR START

;   DC.L BUS_ERROR
;   DC.L ADDRESS_ERROR
;   DC.L ILLEGAL_INSTRUCTION

;   ORG $24
;   DC.L SERVICE_TRAP0      ; TRACE THE SAME AS TRAP #0 

;   ORG $80
;   DC.L SERVICE_TRAP0      ; TRAP #0

;   ORG $C0
;RAMBASE  DC.L   $130000     ; RAM BASE ADDRESS


; RESERVED SPACE FOR FILE DECODE68K DISASSEMBLER
; RAM+$400 TO RAM+10E0
; THE DISASSEMBLER MUST BE LOADED BEFORE USING 

;   ORG $400
;  INCL "DIS.IMG"
;  INCLUDE "dis_mic68k.x68"

;-------------------------------------------------------------------------
; File DCODE68K  68K ONE LINE DISASSEMBLER                        07/28/82

;        CALLING SEQUENCE:
;   D0,D1,D2 = CODE TO BE DISASSEMBLED
;   A4 = VALUE OF PROGRAM COUNTER FOR THE CODE
;   A5 = POINTER TO STORE DATA (BUFSIZE = 80 ASSUMED)
;        JSR       DCODE68K

;        RETURN:
;   A4 = VALUE OF PROGRAM COUNTER FOR NEXT INSTRUCTION
;   A5 = POINTER TO LINE AS DISASSEMBLED
;   A6 = POINTER TO END OF LINE
;
; 01234567890123456789012345678901234567890123456789
; AAAAAA FDATA.DDDDDDDDDDDDDD FOC.... FOP.....

;                ORG $400

FDATA   EQU    10             ;OFFSET TO DATA
FOC     EQU    31             ;OFFSET TO OP-CODE (NO LABEL FIELD)
FOP     EQU    39             ;OFFSET TO OPERAND (NO LABEL FIELD)

BLANK    EQU   $20
BUFSIZE  EQU   80
LOCVARSZ EQU   16
EOT      EQU   $04

; CAUSES ORGIN MODULO 4
LONG     MACRO
         DS      0
         DS.B    (*-X)&2
         ENDM


X        DS      0              BASE ADDRESS THIS MODULE
         LONG

*  MOVEM REGISTERS TO EA
*
*        01001D001S......
*        ..........XXXXXX       EFFECTIVE ADDRESS
*        .........0......       WORD
*        .........1......       LONG
*        .....0..........       REGISTER TO MEMORY
*        .....1..........       MEMORY TO REGISTER
*

IMOVEMFR DS      0
         BSR     MOVEMS         SIZE

         MOVEQ   #$0038,D6
         AND.W   (A4),D6
         CMPI.W  #$0020,D6
         BEQ.S   IM7788         PREDECREMENT MODE

         MOVEQ   #1,D6          D6 = INCREMENTER (BIT POSITION)
         MOVEQ   #0,D1          D1 = BIT POSITION
         BRA.S   IM7799

IM7788   MOVEQ   #-1,D6         D6 = DECREMENTER (BIT POSITION)
         MOVEQ   #15,D1         D1 = BIT POSITION
IM7799   BSR     MOVEMR         BUILD MASK WORD

         MOVE.B  #',',(A6)+     STORE COMMA

         ADDQ.L  #2,D3
         MOVE.W  (A4),D4
         MOVE.W  #$1F4,D7       CONTROL + PREDECREMENT
         BSR     EEA
         BRA.S   CS16           COMMON

         LONG
* MOVEM  EA  TO REGISTERS
*
IMOVEMTR BSR     MOVEMS         SIZE
         ADDQ.L  #2,D3
         MOVE.W  #$7EC,D7       CONTROL + POSTINCREMENT
         BSR     EEA

         MOVE.B  #',',(A6)+     STORE COMMA

         MOVEQ   #1,D6          D6 = BIT POSITION INCREMENTER
         MOVEQ   #0,D1          D1 = BIT POSITION
         BSR     MOVEMR

CS16     BRA.S   CS15           COMMON


         LONG
ISTOP    DS      0
         MOVE.W  2(A4),D0
         MOVE.B  #'#',(A6)+     IMMEDIATE
         MOVE.B  #'$',(A6)+     HEX
         BSR     PNT4HX         VALUE
         BRA     COMMON4

         LONG
IMMED    DS      0              ADD  AND  CMP #  EOR  OR  SUB
         BSR     FORMSIZE
         ADDQ.L  #2,D3          SIZE = 4
         MOVE.B  #'#',(A6)+     IMMEDIATE

         CLR.L   D0
         MOVE.W  2(A4),D0       D0 = EXTENSION WORD
         MOVE.W  (A4),D1
         LSR.W   #6,D1
         ANDI.W  #3,D1
         BEQ.S   IMMED65        .BYTE

         CMPI.B  #1,D1
         BEQ.S   IMMED75        .WORD

         ADDQ.L  #2,D3          .LONG    SIZE = 6
         MOVE.L  2(A4),D0       D0 = LONG EXTENSION WORD

IMMED45  BSR     HEX2DEC        DECIMAL

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE    (A4),D0
         ANDI.W  #$003F,D0
         CMPI.W  #$003C,D0      DESTINATION ADDRESS MODE 111100  "SR"
         BNE.S   IMMED55        NOT FOUND

         MOVE.W  (A4),D0        "SR"  ILLEGAL FOR
         ANDI.W  #$4000,D0      ADDI   SUBI  CMPI
         BNE     FERROR         0600   0400  0C00

         MOVE.W  (A4),D1
         ANDI.W  #$00C0,D1
         CMPI.W  #$0080,D1
         BEQ     FERROR         .LONG NOT ALLOWED

         MOVE.B  #'S',(A6)+     #,SR FOR ANDI, EORI, ORI
         MOVE.B  #'R',(A6)+
CS15     BRA.S   CS14           COMMON

IMMED55  BSR     EEA
         BRA.S   CS14           COMMON

IMMED65  MOVE.L  D0,D1          D1 = XXXXXXXX........
         LSR.W   #8,D1          D1 = 00000000XXXXXXXX
         BEQ.S   IMMED75
         MOVE.L  D0,D1
         ASR.W   #7,D1
         ADDQ.W  #1,D1          CHECK FOR NEGATIVE
         BNE     FERROR

IMMED75  EXT.L   D0
         BRA     IMMED45

*  BIT   5432109876543210
*        ....RRRMMM......       DESTINATION REGISTER MODE
*        ..........MMMRRR       SOURCE MODE REGISTER
*        0001............       .BYTE
*        0011............       .WORD
*        0010............       .LONG
*
* IF BYTE SIZE; DESTINATION ADDRESS DIRECT NOT ALLOWED
         LONG
IMOVE    DS      0
         BRA     IMOVEA1

         LONG
ILINK    DS      0
         BSR.S   FORMREGA

         MOVE.B  D5,(A6)+       COMMA SERARATOR

         MOVE.B  #'#',(A6)+
         MOVE.W  2(A4),D0
         EXT.L   D0
         BSR     HEX2DEC        DECIMAL DISPLACEMENT
         BRA     COMMON4

         LONG
FORM1    DS      0              CLR  NEG  NEGX  NOT TST
         BSR.L   FORMSIZE


*                               NBCD TAS
FORM1A   BSR     EEA            DATA ALTERABLE ONLY
CS14     BRA.S   CS13           COMMON

         LONG
FORM3    DS      0              EXT  SWAP
         BSR.S   FORMREGD
         BRA.S   CS13           COMMON

         LONG
FORM4    DS      0              TRAP
         MOVE.B  #'#',(A6)+
         MOVE.W  (A4),D0
         ANDI.L  #$0F,D0
         BSR     HEX2DEC        DECIMAL
         BRA.S   CS13           COMMON

         LONG
FORM5    DS      0              UNLNK
         BSR.S   FORMREGA
         BRA.S   CS13           COMMON

*  BIT   5432109876543210
*        ....RRR.........       ADDRESS REGISTER
*        ..........XXXXXX       EFFECTIVE ADDRESS
*
         LONG
FORM6A   DS      0              LEA
         MOVE.W  #$7E4,D7       CONTROL ADDRESSING
         BSR.S   EEA10

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         ROL.W   #7,D4
         BSR.S   FORMREGA
         BRA.S   CS13           COMMON

*  BIT   5432109876543210
*        ....DDD.........       DATA REGISTER
*        ..........XXXXXX       EFFECTIVE ADDRESS
*
         LONG
FORM6D   DS      0              CHK  DIVS  DIVU  MULS  MULU
         MOVE.W  #$FFD,D7       DATA ADDRESSING
         BSR.S   EEA10

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         ROL.W   #7,D4
         BSR.S   FORMREGD
         BRA.S   CS13           COMMON

FORMREGA MOVE.B  #'A',(A6)+     FORMAT A@
FORMREG5 ANDI.B  #$07,D4
         ORI.B   #'0',D4
         MOVE.B  D4,(A6)+
         RTS

FORMREGD MOVE.B  #'D',(A6)+     FORMAT D@
         BRA     FORMREG5

*  BIT   5432109876543210
*        ....DDD......DDD       DATA REGISTERS
*
         LONG
FORM7    DS      0              EXG
         ROL.W   #7,D4
         BSR     FORMREGD

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         BSR     FORMREGD
         BRA.S   CS13           COMMON

*  BIT   5432109876543210
*        ....AAA......AAA       ADDRESS REGISTERS
*
         LONG
FORM8    DS      0              EXG
         ROL.W   #7,D4
         BSR     FORMREGA

FORM815  MOVE.B  #',',(A6)+     COMMA SEPARATOR

         MOVE.W  (A4),D4
         BSR     FORMREGA
CS13     BRA     CS12           COMMON

*  BIT   5432109876543210
*        ....DDD.........       DATA REGISTER
*        .............AAA       ADDRESS REGISTER
*
         LONG
FORM9    DS      0              EXG
         ROL.W   #7,D4
         BSR     FORMREGD       DATA REGISTER
         BRA     FORM815

EEA10    BRA     EEA

*  BIT   5432109876543210
*        ..........AAAAAA         EFFECTIVE ADDRESS
*        .......MMM......         OP-MODE
*        ....RRR.........         D-REGISTER
*        .......011......         WORD  EA,A@
*        .......111......         LONG  EA,A@
*        .......000......         EA,D@ BYTE (ADDRESS REGISTER DIRECT NOT ALLOWED)
*        .......0........         EA,D@
*        .......1........         D@,EA
*        ........00......         BYTE
*        ........01......         WORD
*        ........10......         LONG
*
         LONG
*                               ADD <EA>,A@   CMP <EA>,A@   SUB <EA>,A@
FORM10EX DS      0              ADD  CMP  SUB
         MOVE.W  #$FFF,D7       ALL MODES ALLOWED
         MOVE.L  D4,D0
         ANDI.W  #$01C0,D0
         BEQ.S   FORM103        .......000......
         CMPI.W  #$01C0,D0
         BEQ.S   FORM10E3       .......111......
         CMPI.W  #$00C0,D0
         BNE.S   FORM10E6

         MOVE.B  #'.',(A5)+     .......011......       STORE PERIOD
         MOVE.B  #'W',(A5)+
         BRA.S   FORM10E4

FORM10E3 MOVE.B  #'.',(A5)+
         MOVE.B  #'L',(A5)+

FORM10E4 BSR     EEA10

         MOVE.B  D5,(A6)+       STORE COMMA SEPARATOR

         MOVE.W  (A4),D4
         ROL.W   #7,D4
         BSR     FORMREGA       <EA>,A@
         BRA.S   CS12           COMMON

FORM10E6 BTST.B  #0,(A4)
         BNE.S   FORM105        .......1........    D@,<EA>
         BRA.S   FORM104        .......0........    <EA>,D@

*  BIT   5432109876543210
*        ..........AAAAAA       EFFECTIVE ADDRESS
*        .......MMM......       OP-MODE
*        ....RRR.........       D-REGISTER
*        .......0........       EA,D@
*        .......1........       D@,EA
*        ........00......       BYTE
*        ........01......       WORD
*        ........10......       LONG
         LONG
FORM10   DS      0              AND  EOR  OR
         BTST.B  #0,(A4)
         BNE.S   FORM105

FORM103  MOVE.W  #$FFD,D7       DATA ADDRESSING
FORM104  BSR     FORMSIZE
         BSR     EEA10          <EA>,D@

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGD
         BRA.S   CS12           COMMON

FORM105  BSR     FORMSIZE       D@,<EA>
         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGD

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         MOVE.W  #$1FD,D7       ALTERABLE MEMORY ADDRESSING
         BSR     EEA10
CS12     BRA     COMMON

         LONG
*                               PEA     (JMP  JSR)
FORM11   MOVE.W  #$7E4,D7       CONTROL ADDERSSING
         BSR     EEA10
         BRA     CS12           COMMON

         LONG
*                               JMP  JSR
FORM11SL MOVE.L  D4,D0          LOOK FOR .S  OR  .L
         ANDI.W  #$3F,D0
         CMPI.W  #$38,D0
         BNE.S   FORM112        NOT .S
         MOVE.B  #'.',(A5)+     PERIOD
         MOVE.B  #'S',(A5)+     S
FORM112  CMPI.W  #$39,D0
         BNE.S   FORM114
         MOVE.B  #'.',(A5)+     PERIOD
         MOVE.B  #'L',(A5)+     L
FORM114  BRA     FORM11

*  BIT   5432109876543210
*        ....XXX.....0...       DATA DESTINATION REGISTER
*        ....XXX.....1...       ADDRESS REGISTER
*        ....XXX.00......       BYTE
*        ........01......       WORD
*        ........10......       LONG
*        ............0...       DATA REGISTER TO DATA REGISTER
*        ............1...       MEMORY TO MEMORY
*        ............0XXX       DATA SOURCE REGISTER
*        ............1XXX       ADDRESS SOURCE REGISTER
*
         LONG
FORM12   DS      0              ABCD  ADDX  SBCD  SUBX
         BSR     FORMSIZE

         BTST    #3,D4
         BNE.S   FORM125

         BSR     FORMREGD       D@,D@;   FORMAT SOURCE

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGD       FORMAT DESTINATION
         BRA.S   CS11           COMMON

FORM125  MOVE.B  #'-',(A6)+     -
         MOVE.B  #'(',(A6)+     (
         BSR     FORMREGA       A@    SOURCE

         MOVE.L  #'(-,)',D0     ),-(
         BSR.S   SCHR           STORE CHARS

         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGA       A@   DESTINATION
         MOVE.B  #')',(A6)+
         BRA.S   CS11           COMMON

*  BIT   5432109876543210
*        ....XXX.....1...       ADDRESS REGISTER    DESTINATION
*        ....XXX.00......       BYTE
*        ........01......       WORD
*        ........10......       LONG
*        ............1...       MEMORY TO MEMORY
*        ............1XXX       ADDRESS SOURCE REGISTER
*
         LONG
FORM12A  DS      0              CMPM
         BSR     FORMSIZE

         MOVE.B  #'(',(A6)+     (
         BSR     FORMREGA       A@

         MOVE.L  #'(,+)',D0     )+,(
         BSR.S   SCHR           STORE CHARS

         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGA       A@
         MOVE.B  #')',(A6)+
         MOVE.B  #'+',(A6)+
CS11     BRA     COMMON

         LONG
IQUICK   BRA     IQUICKA        ADDQ  SUBQ

*  BIT   5432109876543210
*        0111...0........       FIXED
*        ....RRR.........       DATA REGISTER
*        ........DDDDDDDD       SIGN EXTENDED DATA
*
         LONG
IMOVEQ   DS      0
         MOVE.B  #'#',(A6)+     IMMEDIATE

         MOVE.W  (A4),D0
         EXT.W   D0
         EXT.L   D0
         BSR     HEX2DEC        DECIMAL

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         ROL.W   #7,D4
         BSR     FORMREGD
         BRA     CS11           COMMON

SCHR     MOVE.B  D0,(A6)+       OUTPUT STRING
         LSR.L   #8,D0
         BNE     SCHR           MORE TO OUTPUT
         RTS

* MOVE FROM SR  (STATUS REGISTER)
*
         LONG
IMVFSR   MOVE.L  #',RS'+0,D0   SR,

         BSR     SCHR
         BSR     EEA            DATA ALTERABLE
         BRA     CS11           COMMON

* MOVE FROM USP (USER STACK POINTER)
*
         LONG
IMVFUSP  MOVE.L  #',PSU',D0     USP,
         BSR     SCHR
         BSR     FORMREGA
         BRA     CS11           COMMON

* MOVE TO SR (STATUS REGISTER)
*
         LONG
IMVTSR   MOVE.W  #$FFD,D7       DATA ADDRESSING
         BSR     EEA
         MOVE.L  #'RS,'+0,D0   ,SR
IMVT44   BSR     SCHR
         BRA     CS11           COMMON

* MOVE TO USP (USER STACK POINTER)
*
         LONG
IMVTUSP  BSR     FORMREGA
         MOVE.L  #'PSU,',D0     ,USP
         BRA     IMVT44

*  MOVE TO CCR (CONDITION CODE REGISTER)
*
         LONG
IMVTCCR  MOVE.W  #$FFD,D7       DATA ADDRESSING
         BSR     EEA
         MOVE.L  #'RCC,',D0     ,CCR
         BRA     IMVT44

*  BIT   5432109876543210
*        0000...1..001...       FIXED
*        ....XXX.........       DATA REGISTER
*        ........0.......       MEMORY TO REGISTER
*        ........1.......       REGISTER TO MEMORY
*        .........0......       WORD
*        .........1......       LONG
*        .............XXX       ADDRESS REGISTER
*
         LONG
IMOVEP   DS      0
         MOVE.B  #'.',(A5)+     D@,#(A@)
         MOVE.W  #'LW',D0
         BTST    #6,D4
         BEQ.S   IMOVEP11       USE "W"
         LSR.W   #8,D0          USE "L"
IMOVEP11 MOVE.B  D0,(A5)+       LENGTH

         MOVE.B  (A4),D4
         LSR.B   #1,D4

         BTST.B  #7,1(A4)
         BEQ.S   IMOVEP35

         BSR     FORMREGD       D@,$HHHH(A@)

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         BSR.S   IMOVEP66
CS20     BRA     COMMON4

IMOVEP35 BSR.S   IMOVEP66       $HHHH(A@),D@

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.B  (A4),D4
         LSR.B   #1,D4
         BSR     FORMREGD
         BRA     CS20           COMMON4

IMOVEP66 MOVE.B  #'$',(A6)+     FORMAT DISPLACEMENT
         MOVE.W  2(A4),D0
         BSR     PNT4HX

         MOVE.B  #'(',(A6)+

         MOVE.W  (A4),D4
         BSR     FORMREGA
         MOVE.B  #')',(A6)+
         RTS

         LONG
SCOMMON  BRA     COMMON         NOP RESET RTE RTR RTS TRAPV

         LONG
ISCC     BSR     ICCCC          GET REST OF OP-CODE
         BSR     EEA            DATA ALTERABLE
         BRA     SCOMMON


         LONG
IDBCC    DS      0              DB--
         MOVE.W  (A4),D4
         BSR     FORMREGD

         MOVE.B  D5,(A6)+       COMMA SEPARATOR
         MOVE.B  #'$',(A6)+     HEX FIELD TO FOLLOW

         BSR     ICCCC
         BRA.S   ICC55

*  BIT   5432109876543210
*        0110............       FIXED
*        ....CCCC........       CONDITION
*        ........DDDDDDD0       DISPLACEMENT
*        ...............1       ERROR (ODD BOUNDRY DISPLACEMENT)
*
         LONG
ICC      DS      0              B--
         BSR     ICCCC

IBSR     MOVE.B  #'$',(A6)+     BSR   BRA

         TST.B   D4
         BEQ.S   ICC55          16 BIT DISPLACEMENT

         MOVE.B  #'.',(A5)+
         MOVE.B  #'S',(A5)+
         EXT.W   D4             8 BIT DISPLACEMENT

ICC35    EXT.L   D4             SIGN-EXTENDED DISPLACEMENT
         ADD.L   HISPC(A1),D4   + PROGRAM COUNTER
         ADDQ.L  #2,D4          + TWO
         MOVE.L  D4,D0

         ASR.L   #1,D4
         BCS     FERROR         ODD BOUNDRY DISPLACEMENT

         BSR     PNT6HX
         BRA     SCOMMON

ICC55    ADDQ.L  #2,D3          SIZE
         MOVE.W  2(A4),D4
         MOVE.B  #'.',(A5)+
         MOVE.B  #'L',(A5)+     .L FOR 16 BIT DISPLACEMENT
         BRA     ICC35

         LONG
*                               BCHG  BCLR  BSET  BTST
ISETD    DS      0              DYNAMIC BIT
         ROL.W   #7,D4
         BSR     FORMREGD       DATA REGISTER

ISETD12  MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         BSR     EEA            DATA ALTERABLE
CS18     BRA     SCOMMON

         LONG
*                            BCHG  BCLR  BSET  BTST
*  1ST WORD     .... .... ..XX XXXX    EA   DATA ALTERABLE ONLY
*  2ND WORD     0000 0000 000Y YYYY    BIT NUMBER
*
ISETS    DS      0              STATIC BIT
         ADDQ.L  #2,D3     SIZE
         MOVE.B  #'#',(A6)+     IMMEDIATE

         CLR.L   D0
         MOVE.W  2(A4),D0       GET BIT POSITION FROM 2ND WORD
         MOVE.L  D0,D1
         LSR.L   #5,D1
         BNE     FERROR
         BSR     HEX2DEC        DECIMAL

         BRA     ISETD12

*   BIT  5432109876543210
*        ....XXX.........       IMMEDIATE COUNT/REGISTER
*        .......0........       RIGHT SHIFT
*        .......1........       LEFT SHIFT
*        ........00......       BYTE
*        ........01......       WORD
*        ........10......       LONG
*        ....0...11......       WORD (MEMORY)
*        ....0...11AAAAAA       EFFECTIVE ADDRESS
*        ..........0.....       SHIFT IMMEDIATE COUNT
*        ..........1.....       SHIFT COUNT (MODULO 64) IN DATA REGISTER
*
         LONG
ISHIFT   DS      0              AS-  LS-  RO-  ROX-
         MOVE.W  #'LR',D0
         BTST    #8,D4          DIRECTION BIT
         BEQ.S   ISHIFT13       RIGHT
         LSR.W   #8,D0          LEFT
ISHIFT13 MOVE.B  D0,(A5)+       DIRECTION; "L" OR "R"

         MOVE.W  (A4),D0
         ANDI.W  #$00C0,D0
         CMPI.W  #$00C0,D0
         BEQ.S   ISHIFTM1       MEMORY SHIFT

         BSR     FORMSIZE

         ROL.W   #7,D4
         BTST    #12,D4         I/R BIT
         BNE.S   ISHIFT33       COUNT IN REGISTER

         ANDI.B  #$07,D4        IMMEDIATE COUNT
         BNE.S   ISHIFT23
         ORI.B   #$08,D4        CHANGE ZERO TO EIGHT
ISHIFT23 ORI.B   #'0',D4
         MOVE.B  #'#',(A6)+
         MOVE.B  D4,(A6)+
         BRA.S   ISHIFT44

ISHIFT33 BSR     FORMREGD

ISHIFT44 MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4
         BSR     FORMREGD
CS17     BRA     CS18           COMMON

ISHIFTM1 MOVE.B  #'.',(A5)+     PERIOD
         MOVE.B  #'W',(A5)+     .WORD

         BTST    #11,D4
         BNE     FERROR         BIT 11 MUST BE ZERO

         MOVE.W  #$1FC,D7       MEMORY ALTERABLE ADDRESSING
         BSR     EEA
         BRA     CS17           COMMON

ICCCC    MOVEQ   #$0F,D0        APPEND CONDITION CODE
         AND.B   (A4),D0        D0 = CCC
         LSL.L   #1,D0          D0 = CCC*2

         MOVE.W  BRTBL(PC,D0.W),D1  GET BRANCH MNEMONIC
         MOVE.B  D1,(A5)+           (REVERSED) FROM THE TABLE
         LSR.W   #8,D1              AND ADD THE NONBLANK PORTION
         CMPI.B  #BLANK,D1          TO THE BUFFER.
         BEQ.S   ICCCC9
         MOVE.B  D1,(A5)+
ICCCC9   RTS

BRTBL    DC.B    ' T'      'T '  BRA ACCEPTED
         DC.B    ' F'      'F '
         DC.B    'IH'      'HI'
         DC.B    'SL'      'LS'
         DC.B    'CC'      'CC'
         DC.B    'SC'      'CS'
         DC.B    'EN'      'NE'
         DC.B    'QE'      'EQ'
         DC.B    'CV'      'VC'
         DC.B    'SV'      'VS'
         DC.B    'LP'      'PL'
         DC.B    'IM'      'MI'
         DC.B    'EG'      'GE'
         DC.B    'TL'      'LT'
         DC.B    'TG'      'GT'
         DC.B    'EL'      'LE'

*   BIT  5432109876543210
*        ....RRRMMM......    DESTINATION REGISTER MODE
*        ..........MMMRRR    SOURCE MODE REGISTER
*
* IF BYTE SIZE; ADDRESS DIRECT NOT ALLOWED AS SOURCE
*
IMOVEA1  DS      0
         MOVE.W  #$FFF,D7       ALL MODES
         BSR     EEA

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4        ....RRRMMM......
         LSR.W   #1,D4          .....RRRMMM.....
         LSR.B   #5,D4          .....RRR.....MMM
         ROR.W   #8,D4          .....MMM.....RRR
         LSL.B   #5,D4          .....MMMRRR.....
         LSR.W   #5,D4          ..........MMMRRR

* IF .BYTE DESTINATION A@ NOT ALLOWED
         MOVE.W  #$1FF,D7       DATA ALTERABLE + A@
         MOVE.B  (A4),D0
         CMPI.B  #$01,D0
         BNE.S   IMOVE19        NOT BYTE SIZE

         MOVE.W  #$1FD,D7       DATA ALTERABLE
IMOVE19

         BSR     EEA
         BRA.S   CS19           COMMON

*  IF BYTE; ADDRESS REGISTER DIRECT NOT ALLOWED
IQUICKA  DS      0              ADDQ  SUBQ
         BSR.S   FORMSIZE

         MOVE.B  #'#',(A6)+
         ROL.W   #7,D4
         ANDI.B  #7,D4
         BNE.S   IQUICK21
         ORI.B   #8,D4          MAKE ZERO INTO EIGHT
IQUICK21 ORI.B   #'0',D4        MAKE ASCII
         MOVE.B  D4,(A6)+

         MOVE.B  D5,(A6)+       COMMA SEPARATOR

         MOVE.W  (A4),D4

         MOVE.W  (A4),D0
         ANDI.W  #$00C0,D0
         BEQ.S   IQUICK31       DATA ALTERABLE
         MOVE.W  #$1FF,D7       ALTERABLE ADDRESSING
IQUICK31 BSR     EEA
CS19     BRA     COMMON

*  BIT   5432109876543210
*        ........00......       BYTE
*        ........01......       WORD
*        ........10......       LONG
*        ........11......       ERROR
*
FORMSIZE DS      0
         MOVE.W  (A4),D2
         MOVE.B  #'.',(A5)+     STORE PERIOD
         LSR.W   #6,D2
         ANDI.W  #$03,D2
         BNE.S   FORM91
         MOVE.B  #'B',(A5)+     STORE "B"
         BRA.S   FORM95

FORM91   MOVE.B  #'W',D0
         CMPI.B  #1,D2
         BEQ.S   FORM93
         MOVE.B  #'L',D0
         CMPI.B  #2,D2
         BNE.S   FE10           FERROR
FORM93   MOVE.B  D0,(A5)+       STORE "W" OR "L"
FORM95   RTS

EA000    BSR     FORMREGD
         BTST    #0,D7
         BEQ.S   FE10           FERROR
         RTS

EA001    BSR     FORMREGA
         BTST    #1,D7
         BEQ.S   FE10           FERROR  THIS MODE NOT ALLOWED
         RTS

EA010    MOVE.B  #'(',(A6)+
         BSR     FORMREGA
         MOVE.B  #')',(A6)+
         BTST    #2,D7
         BEQ.S   FE10           FERROR  THIS MODE NOT ALLOWED
         RTS

EA011    MOVE.B  #'(',(A6)+
         BSR     FORMREGA
         MOVE.B  #')',(A6)+
         MOVE.B  #'+',(A6)+
         BTST    #3,D7
         BEQ.S   FE10           FERROR  THIS MODE NOT ALLOWED
EA011RTS RTS

EA100    MOVE.B  #'-',(A6)+
         MOVE.B  #'(',(A6)+
         BSR     FORMREGA
         MOVE.B  #')',(A6)+
         BTST    #4,D7
         BNE     EA011RTS
FE10     BRA     FERROR         THIS MODE NOT ALLOWED

*  ENTER       A4 = POINTER TO FIRST WORD
*              D3 = OFFSET TO EXTENSION
*              D4 = VALUE TO PROCESS
*              D7 = MODES ALLOWED MASK
*
EEA      DS      0
         MOVE.L  D4,D0
         LSR.W   #3,D0
         ANDI.W  #$7,D0
         BEQ     EA000

         CMPI.B  #1,D0
         BEQ     EA001

         CMPI.B  #2,D0
         BEQ     EA010

         CMPI.B  #3,D0
         BEQ     EA011

         CMPI.B  #4,D0
         BEQ     EA100

         CMPI.B  #5,D0
         BEQ.S   EA101

         CMPI.B  #7,D0
         BEQ.S   EA111

*    EXTENSION WORD
*   BIT  5432109876543210
*        0...............    DATA REGISTER
*        1...............    ADDRESS REGISTER
*        .RRR............    REGISTER
*        ....0...........    SIGN EXTENDED, LOW ORDER INTEGER IN INDEX REG
*        ....1...........    LONG VALUE IN INDEX REGISTER
*        .....000........
*        ........DDDDDDDD    DISPLACEMENT INTEGER
*
* EA110            ADDRESS REGISTER INDIRECT WITH INDEX

         BTST    #6,D7
         BEQ     FE10           FERROR  THIS MODE NOT ALLOWED

         MOVE.W  (A4,D3),D1
         ANDI.W  #$0700,D1
         BNE     FE10           FERROR  BITS 10-8 MUST BE ZERO

         MOVE.W  (A4,D3),D0     D0 = DISPLACEMENT
         EXT.W   D0
         EXT.L   D0
         BSR     HEX2DEC        DECIMAL
         MOVE.B  #'(',(A6)+     (

         BSR     FORMREGA       XX(A@

         MOVE.B  #',',(A6)+     XX(A@,

         MOVE.B  (A4,D3),D4
         ASR.B   #4,D4
         BPL.S   EA1105
         BSR     FORMREGA
         BRA.S   EA1107

EA1105   BSR     FORMREGD
EA1107   MOVE.B  #'.',(A6)+     XX(A@,X@.

         MOVE.W  (A4,D3),D4     D4 = R@
         MOVE.B  #'W',D0        ..........W
         BTST    #11,D4
         BEQ.S   EA1109
         MOVE.B  #'L',D0        ..........L
EA1109   MOVE.B  D0,(A6)+
         MOVE.B  #')',(A6)+     ...........)
         ADDQ.L  #2,D3
         RTS

* ADDRESS REGISTER INDIRECT WITH DISPLACEMENT
*
EA101    BTST    #5,D7          101000;   DIS(A@)
         BEQ.S   FE11           FERROR;  THIS MODE NOT ALLOWED

         MOVE.W  (A4,D3),D0
         EXT.L   D0
         BSR     HEX2DEC        DECIMAL
         ADDQ.L  #2,D3          SIZE
         BRA     EA010

*  111000        ABSOLUTE SHORT
*  111001        ABSOLUTE LONG
*  111010        PROGRAM COUNTER WITH DISPLACEMENT
*  111011        PROGRAM COUNTER WITH INDEX
*  111100        IMMEDIATE OR STATUS REG
*
EA111
         ANDI.W  #7,D4
         BNE.S   EA1112

         BTST    #7,D7
         BEQ.S   FE11           FERROR;  THIS MODE NOT ALLOWED

         MOVE.W  (A4,D3),D0     111000;   ABSOLUTE SHORT
         EXT.L   D0
         MOVE.B  #'$',(A6)+
         BSR     PNT8HX         SIGN EXTENDED VALUE
         ADDQ.L  #2,D3          SIZE + 2
         RTS

EA1112   CMPI.B  #1,D4
         BNE.S   EA1113

         BTST    #8,D7
         BEQ.S   FE11           FERROR;  THIS MODE NOT ALLOWED

         MOVE.B  #'$',(A6)+     HEX
         MOVE.L  (A4,D3),D0     111001;     ABSOLUTE LONG
         BSR     PNT8HX
*-       MOVE.B  #'.',(A6)+     FORCE LONG FORMAT
*-       MOVE.B  #'L',(A6)+     IE   .L
         ADDQ.L  #4,D3
         RTS

EA1113   CMPI.B  #2,D4
         BNE.S   EA1114

         BTST    #9,D7
         BNE.S   EA1113A
FE11     BRA     FERROR         THIS MODE NOT ALLOWED
EA1113A

         MOVE.W  (A4,D3),D0     111010;  PC + DISPLACEMENT  DESTINATION(PC)
         EXT.L   D0
         ADD.L   HISPC(A1),D0
         ADDQ.L  #2,D0
         MOVE.B  #'$',(A6)+     HEX "$"
         BSR     PNT8HX         DESTINATION
         MOVE.L  #')CP(',D0     (PC)
         BSR     SCHR           STORE WORD
         ADDQ.L  #2,D3          SIZE
         RTS

EA1114   CMPI.B  #3,D4
         BNE.S   EA1115

* PROGRAM COUNTER WITH INDEX    DESTINATION(PC,R@.X)
*
*        5432109876543210       SECOND WORD
*        0...............       DATA REGISTER
*        1...............       ADDRESS REGISTER
*        .XXX............       REGISTER
*        ....0...........       SIGN-EXTENDED, LOW ORDER WORD INTEGER
*                               ..IN INDEX REGISTER
*        ....1...........       LONG VALUE IN INDEX REGISTER
*        .....000........
*        ........XXXXXXXX       DISPLACEMENT INTEGER
*
         BTST    #10,D7
         BEQ     FE11           FERROR  THIS MODE NOT ASLLOWED

         MOVE.W  (A4,D3),D1
         ANDI.W  #$0700,D1
         BNE     FE11           FERROR;  BITS 10-8 MUST BE ZERO

         MOVE.B  1(A4,D3),D0    111100;   DESTINATION(PC,R@.X)
         EXT.W   D0
         EXT.L   D0
         ADD.L   HISPC(A1),D0
         ADDQ.L  #2,D0
         MOVE.B  #'$',(A6)+     HEX "$"
         BSR     PNT8HX         DESTINATION

         MOVE.L  #',CP(',D0
         BSR     SCHR           DES(PC,

         MOVE.W  (A4,D3),D4
         ROL.W   #4,D4
         BTST    #3,D4
         BEQ.S   EAF25
         BSR     FORMREGA
         BRA.S   EAF27
EAF25    BSR     FORMREGD       DES(PC,R@
EAF27

         MOVE.B  #'.',(A6)+     DES(PC,R@.

         MOVE.W  (A4,D3),D4
         MOVE.W  #'LW',D0
         BTST    #11,D4
         BEQ.S   EAF35
         LSR.W   #8,D0
EAF35    MOVE.B  D0,(A6)+       DES(PC,R@.X

         MOVE.B  #')',(A6)+     DES(PC,R@.X)
         ADDQ.L  #2,D3
         RTS

*   BIT  5432109876543210
*        ..........111100       FIRST WORD;  #<IMMEDIATE>
*
EA1115   CMPI.B  #4,D4
         BNE     FE11           FERROR

         BTST    #11,D7
         BEQ     FE11           FERROR;  THIS MODE NOT ALLOWED

         MOVE.B  #'#',(A6)+     IMMEDIATE

         MOVE.B  -1(A5),D1
         CMPI.B  #'L',D1
         BEQ.S   EA11155        LONG

         MOVE.W  (A4,D3),D0

         CMPI.B  #'B',D1
         BNE.S   EA11153        .WORD

* BYTE SIZE; DATA ALLOWED
*  0000 0000 XXXX XXXX
*  1111 1111 1XXX XXXX
         MOVE.L  D0,D1
         LSR.W   #8,D1
         BEQ.S   EA11153
         MOVE.L  D0,D1
         ASR.W   #7,D1
         ADDQ.W  #1,D1
         BNE     FE11           FERROR

EA11153  EXT.L   D0
         BSR     HEX2DEC
         ADDQ.L  #2,D3
         RTS

EA11155  MOVE.L  (A4,D3),D0
         BSR     HEX2DEC
         ADDQ.L  #4,D3          SIZE
         RTS

MOVEMS   MOVE.B  #'.',(A5)+     PERIOD
         MOVE.W  #'LW',D0
         BTST    #6,D4
         BEQ.S   MOVEMS2
         LSR.W   #8,D0
MOVEMS2  MOVE.B  D0,(A5)+       SIZE
         RTS

* MOVEM - REGISTER EXPANSION
*
MOVEMR   DS      0
         MOVE.W  2(A4),D2       D2 = SECOND WORD
         MOVEQ   #$20,D0        D0 = SPACE
         MOVEQ   #$2F,D7        D7 = /
         SUBQ.L  #1,A6          ADJUST STORE POINTER
         MOVEQ   #$30,D5        D5 = REGISTER #
         MOVE.W  #'AD',D4       D4 = REG CLASS

MOVEMR11 BTST    D1,D2
         BEQ.S   MOVEMR77       BIT RESET

         CMP.B   (A6),D0        BIT SET
         BNE.S   MOVEMR44       NOT SPACE

MOVEMR33 MOVE.B  D4,1(A6)       REG TYPE
         MOVE.B  D5,2(A6)       REG #
         MOVE.B  #'-',3(A6)     -
         ADDQ.L  #3,A6
         BRA.S   MOVEMR88

MOVEMR44 CMPI.B  #',',(A6)
         BEQ     MOVEMR33       COMMA SEPARATOR

         CMP.B   (A6),D7        / SEPARATOR
         BEQ     MOVEMR33

         MOVE.B  D4,1(A6)       REG TYPE
         MOVE.B  D5,2(A6)       REG #
         MOVE.B  #'-',3(A6)     - SEPARATOR
         BRA.S   MOVEMR88

MOVEMR77 CMPI.B  #',',(A6)
         BEQ.S   MOVEMR88       COMMA

         CMP.B   (A6),D0
         BEQ.S   MOVEMR88       SPACE
         CMP.B   1(A6),D0
         BEQ.S   MOVEMR79       SPACE
         ADDQ.L  #3,A6
MOVEMR79 MOVE.B  D7,(A6)        / SEPARATOR

MOVEMR88 ADDQ.L  #1,D5
         ADD.L   D6,D1          D1 = BIT POSITION
         CMPI.B  #'8',D5
         BNE     MOVEMR11

         CMP.B   (A6),D0        SPACE
         BEQ.S   MOVEMR94

         CMP.B   1(A6),D0       SPACE
         BEQ.S   MOVEMR94
         ADDQ.L  #3,A6
         MOVE.B  D7,(A6)        /   SEPARATOR

MOVEMR94 MOVE.B  #'0',D5        RESET REG TO ZERO
         LSR.W   #8,D4          CHANGE REG TYPE
         BNE     MOVEMR11       MORE

         MOVE.B  D0,(A6)        SPACE
         RTS

DCODE68K DS      0
         LINK    A1,#-LOCVARSZ       CREATE A FRAME FOR THE
         MOVEM.L D0-D2/A4,DDATA(A1)  CODE AND ITS PC.  A4
         LEA     DDATA(A1),A4        POINTS TO THE CODE.

         MOVE.L  A5,A3          A3 = START OF OUTPUT BUFFER
         MOVEQ   #BUFSIZE,D0
         MOVE.L  A3,A6
DEC311   MOVE.B  #BLANK,(A6)+   SPACE FILL BUFFER
         SUBQ.L  #1,D0
         BNE     DEC311

         MOVE.L  A3,A6          FORMAT ADDRESS
         MOVE.L  HISPC(A1),D0
         BSR     FRELADDR

* CHECK FOR KNOWN ILLEGAL CODES
         MOVE.W  (A4),D0

         LEA     KI(PC),A5
         MOVE.L  A5,A6
         ADD.L   #KIEND-KI,A6
DEC404   CMP.W   (A5)+,D0
         BEQ.S   FE12           FERROR;  ILLEGAL CODE
         CMP.L   A6,A5
         BNE     DEC404

* LOOK FOR MATCH OF OP-CODE
*
         LEA     TBL(PC),A5     A5 = POINTER TO DECODE TABLE
         LEA     TBLE(PC),A6    A6 = POINTER TO END OF TABLE
DEC411   MOVE.W  (A4),D0        FIRST WORD
         AND.W   (A5)+,D0       MASK
         CMP.W   (A5)+,D0
         BEQ.S   DEC425         FOUND MATCH
         ADDQ.L  #2,A5          UPDATE POINTER
         CMP.L   A6,A5
         BNE     DEC411         MORE TABLE
FE12     BRA.S   FERROR         ILLEGAL INSTRUCTION

DEC425   CLR.L   D6
         MOVE.B  (A5)+,D6       D6 = (GOTO OFFSET)/4
         LSL.L   #2,D6

         CLR.L   D7
         MOVE.B  (A5)+,D7       D7 = INDEX TO OP-CODE

* MOVE OP-CODE TO BUFFER
*
         LEA     OPCTBL(PC),A0
DEC510   TST     D7
         BEQ.S   DEC530         AT INDEX
DEC515   TST.B   (A0)+
         BPL     DEC515         MOVE THROUGH FIELD
         SUBQ.L  #1,D7
         BRA     DEC510

DEC530   MOVEQ   #FOC,D0
         LEA.L   (A3,D0),A5     A5 = STORE POINTER  OP-CODE
DEC535   MOVE.B  (A0)+,D0
         BCLR    #7,D0
         BNE.S   DEC537         END OF MOVE
         MOVE.B  D0,(A5)+
         BRA     DEC535
DEC537   MOVE.B  D0,(A5)+

* CALCULATE GOTO AND GO
*
         MOVEQ   #2,D3          D3= SIZE
         LEA     X(PC),A0
         ADD.L   D6,A0

         MOVEQ   #FOP,D0
         LEA.L   (A3,D0),A6     A6 = POINTER FOR OPERAND

         MOVE.W  (A4),D4        D4 = FIRST WORD

         MOVE.B  #',',D5        D5 = CONTAINS ASCII COMMA

         MOVE.W  #$1FD,D7       D7 = DATA ALTERABLE MODES ALLOWED

         JMP     (A0)
*
*  A4 = POINTER TO DATA IN FRAME CREATED BY 'LINK A1,...'
*  A5 = POINTER STORE OP-CODE
*  A6 = POINTER STORE OPERAND
*  D3 = SIZE = 2 BYTES
*  D4 = FIRST WORD
*  D7 = ADDRESS MODES ALLOWED ($1FD) DATA ALTERABLE

COMMON4  ADDQ.L  #2,D3          SIZE = 4

COMMON   MOVE.L  D3,D6          D6 = SIZE
         MOVE.B  #BLANK,(A6)+   SPACE AS LAST CHAR

         MOVE.L  A6,A5          SAVE END OF BUFFER POINTER
         MOVEQ   #FDATA,D0
         LEA.L   (A3,D0),A6

COMMON35 MOVE.W  (A4)+,D0       GET NEXT WORD OF DATA.
         ADDQ.L  #2,HISPC(A1)   ADJUST PROG COUNTER.
         BSR     PNT4HX         FORMAT DATA. (A6)+
         SUBQ.B  #2,D3
         BNE     COMMON35

         MOVE.L  A5,A6          A6 = RESTORE END POINTER

         MOVE.L  A3,A5          A5 =  BEGINNING OF BUFFER

         MOVE.L  HISPC(A1),A4   MOVE THE UPDATED PC
         UNLK    A1               TO A4 AND UNDO FRAME.

         RTS


FERROR   DS      0
* ILLEGAL INSTRUCTION
*
         MOVEQ   #FOC,D0
         LEA.L   (A3,D0),A6
         LEA     MSG111(PC),A5
FERROR35 MOVE.B  (A5)+,D0
         CMPI.B  #EOT,D0
         BEQ.S   FERROR39
         MOVE.B  D0,(A6)+
         BRA     FERROR35
FERROR39 DS      0

         MOVE.W  (A4),D0
         BSR     PNT4HX

         MOVEQ   #2,D3          SIZE

         BRA     COMMON

MSG111   DC.B    'DC.W    $',EOT



KI       DC.W    $4AFB          KNOWN ILLEGAL CODES
KIEND    DS      0


*  \1   MASK
*  \2   OP-CODE PATTERN
*  \3   GOTO OFFSET
*  \4   INDEX TO OP-CODE
C68      MACRO
         DC.W    $\1
         DC.W    $\2
         DC.B    (\3-X)>>2
         DC.B    \4
         ENDM

TBL      DS      0
         C68     FEC0,E6C0,ISHIFT,56           RO
         C68     FEC0,E4C0,ISHIFT,57           ROX
         C68     FEC0,E2C0,ISHIFT,55           LS
         C68     FEC0,E0C0,ISHIFT,54           AS
         C68     F018,E018,ISHIFT,56           RO
         C68     F018,E010,ISHIFT,57           ROX
         C68     F018,E008,ISHIFT,55           LS
         C68     F018,E000,ISHIFT,54           AS
         C68     F0C0,D0C0,FORM10EX,4          ADD       <EA>,A@
         C68     F130,D100,FORM12,53           ADDX
         C68     F000,D000,FORM10EX,4            ADD
         C68     F1F8,C188,FORM9,50            EXG
         C68     F1F8,C148,FORM8,50            EXG
         C68     F1F8,C140,FORM7,50            EXG
         C68     F1F0,C100,FORM12,49           ABCD
         C68     F1C0,C1C0,FORM6D,48           MULS
         C68     F1C0,C0C0,FORM6D,47           MULU
         C68     F000,C000,FORM10,2            AND
         C68     F0C0,B0C0,FORM10EX,6          CMP     <EA>,A@
         C68     F138,B108,FORM12A,46           CMPM
         C68     F100,B100,FORM10,5            EOR
         C68     F000,B000,FORM10EX,6            CMP
         C68     F0C0,90C0,FORM10EX,44         SUB       <EA>,A@
         C68     F130,9100,FORM12,45           SUBX
         C68     F000,9000,FORM10EX,44           SUB
         C68     F1F0,8100,FORM12,43           SBCD
         C68     F1C0,81C0,FORM6D,42           DIVS
         C68     F1C0,80C0,FORM6D,41           DIVU
         C68     F000,8000,FORM10,40           OR
         C68     F100,7000,IMOVEQ,39           MOVEQ
         C68     FF00,6100,IBSR,51             BSR
         C68     FF00,6000,IBSR,65             BRA
         C68     F000,6000,ICC,38              B
         C68     F0F8,50C8,IDBCC,37              DB
         C68     F0C0,50C0,ISCC,36             S
         C68     F100,5100,IQUICK,35           SUBQ
         C68     F100,5000,IQUICK,34           ADDQ
         C68     F1C0,41C0,FORM6A,33           LEA
         C68     F1C0,4180,FORM6D,32           CHK
         C68     FFC0,4EC0,FORM11SL,31         JMP
         C68     FFC0,4E80,FORM11SL,30         JSR
         C68     FFFF,4E77,SCOMMON,29           RTR
         C68     FFFF,4E76,SCOMMON,28           TRAPV
         C68     FFFF,4E75,SCOMMON,27           RTS
         C68     FFFF,4E73,SCOMMON,26           RTE
         C68     FFFF,4E72,ISTOP,25             STOP
         C68     FFFF,4E71,SCOMMON,24           NOP
         C68     FFFF,4E70,SCOMMON,23           RESET
         C68     FFF8,4E68,IMVFUSP,60          MOVE FROM USP
         C68     FFF8,4E60,IMVTUSP,60          MOVE TO USP
         C68     FFF8,4E58,FORM5,22            UNLINK
         C68     FFF8,4E50,ILINK,21            LINK
         C68     FFF0,4E40,FORM4,20            TRAP
         C68     FF80,4C80,IMOVEMTR,15         MOVEM FROM REGISTERS
         C68     FFC0,4AC0,FORM1A,19           TAS
         C68     FF00,4A00,FORM1,18            TST
         C68     FFF8,48C0,FORM3,17            EXT.L
         C68     FFF8,4880,FORM3,16            EXT.W
         C68     FF80,4880,IMOVEMFR,15         MOVEA TO REGISTERS
         C68     FFF8,4840,FORM3,14            SWAP
         C68     FFC0,4840,FORM11,13           PEA
         C68     FFC0,4800,FORM1A,12           NBCD
         C68     FFC0,46C0,IMVTSR,59           MOVE TO SR
         C68     FF00,4600,FORM1,11            NOT
         C68     FFC0,44C0,IMVTCCR,59          MOVE TO CCR
         C68     FF00,4400,FORM1,10            NEG
         C68     FF00,4200,FORM1,9             CLR
         C68     FFC0,40C0,IMVFSR,59           MOVE.W  FROM  SR
         C68     FF00,4000,FORM1,8             NEGX
         C68     F000,3000,IMOVE,59            MOVE.W
         C68     F000,2000,IMOVE,60            MOVE.L
         C68     F000,1000,IMOVE,58            MOVE.B
         C68     FF00,0C00,IMMED,6             CMP       #
         C68     FF00,0A00,IMMED,5             EOR       #
         C68     FF00,0600,IMMED,4             ADD       #
         C68     FF00,0400,IMMED,3             SUB       #
         C68     FF00,0200,IMMED,2             AND       #
         C68     FF00,0000,IMMED,1             OR        #
         C68     F138,0108,IMOVEP,0            MOVEP
         C68     FFC0,08C0,ISETS,64            BSET
         C68     FFC0,0880,ISETS,63            BCLR
         C68     FFC0,0840,ISETS,62            BCHG
         C68     FFC0,0800,ISETS,61            BTST
         C68     F1C0,01C0,ISETD,64            BSET
         C68     F1C0,0180,ISETD,63            BCLR
         C68     F1C0,0140,ISETD,62            BCHG
         C68     F1C0,0100,ISETD,61            BTST
TBLE     DS      0

N68      MACRO
         DC.B    '\1',128+'\2'        \1\2
         ENDM

OPCTBL   DS      0
         N68     MOVE,P    0
         N68     O,R       1
         N68     AN,D      2
         N68     SU,B      3
         N68     AD,D      4
         N68     EO,R      5
         N68     CM,P      6
         N68     MOV,E     7
         N68     NEG,X     8
         N68     CL,R      9
         N68     NE,G      10
         N68     NO,T      11
         N68     NBC,D     12
         N68     PEA.,L    13
         N68     SWAP.,W   14
         N68     MOVE,M    15
         N68     EXT.,W    16
         N68     EXT.,L    17
         N68     TS,T      18
         N68     TAS.,B    19
         N68     TRA,P     20
         N68     LIN,K     21
         N68     UNL,K     22
         N68     RESE,T    23
         N68     NO,P      24
         N68     STO,P     25
         N68     RT,E      26
         N68     RT,S      27
         N68     TRAP,V    28
         N68     RT,R      29
         N68     JS,R      30
         N68     JM,P      31
         N68     CHK.,W    32
         N68     LEA.,L    33
         N68     ADD,Q     34
         N68     SUB,Q     35
         DC.B    128+'S'   36
         N68     D,B       37
         DC.B    128+'B'   38
         N68     MOVEQ.,L  .....39
         N68     O,R       40
         N68     DIVU.,W   41
         N68     DIVS.,W   42
         N68     SBC,D     43
         N68     SU,B      44
         N68     SUB,X     45
         N68     CMP,M     46
         N68     MULU.,W   47
         N68     MULS.,W   48
         N68     ABC,D    49
         N68     EX,G      50
         N68     BS,R      .....51
         N68     NUL,L     .....52
         N68     ADD,X     53
         N68     A,S       54
         N68     L,S       55
         N68     R,O       56
         N68     RO,X      57
         N68     MOVE.,B   58
         N68     MOVE.,W   59
         N68     MOVE.,L   60
         N68     BTS,T     61
         N68     BCH,G     62
         N68     BCL,R     63
         N68     BSE,T     64
         N68     BR,A      65

         DC.B    0              PAD BYTE



;   ORG $2000

MAIN MOVE.W #INT_OFF,SR  ; INTERRUPT OFF, SUPERVISOR MODE SET

;      MOVE.L #RAMBASE+USER_STACK,SP ; INIT TOP OF USER STACK
;      movea.l #DOUT,a1
;      move.b #$FF,d2    ; with cpld
;      MOVE.B D2,(A1)    ; OFF LEDS

      BSR INIT_ACIA         ; ACIA init

      BSR VECINIT           ; EXCEPTION VECTOR init

      BSR SCROLL            ; NEW LINE

      BSR CLEAR_MON_RAM     ; Initialize 1Kbyte from RAMBASE with 0.

      LEA.L TITLE1.L,A3     ; print START MESSAGE
      BSR PSTR

      MOVEA.L RAMBASE.L,A6  ; Initialize Monitor work area 
      MOVE.L #RAM,POINTER_NOW(A6)
      MOVE.L #RAM+$400,USER_PC(A6)    ; INIT USER PC TO START OF RAM

      MOVE.L #SUPER_STACK+USER_STACK,USER_USP(A6) ; INIT USER STACK
      MOVE.W SR,D0
      MOVE.W D0,USER_SR(A6) 

      CLR.L FLAG(A6)         ; CLEAR SYSTEM MONITOR FLAG
      MOVE.W #INT_ON,SR       ; ON INTERRUPT, SUPERVISOR MODE SET

loop  BSR SEND_PROMPT
      BSR CIN
      CMP.B #$40,D0
      blt.S	NO_CHANGE

      AND.B #%11011111,D0

NO_CHANGE

      CMP.B #'L',D0
      BNE NEXT1
      BSR READ_S_REC
      BRA LOOP

NEXT1 CMP.B #'S',D0       
      BNE NEXT2
      BSR VIEW_USP      ; VIEW USER STACK
      BRA LOOP


NEXT2 CMP.B #'H',D0
      BNE NEXT3
      BSR HEX_DUMP
      BRA LOOP

NEXT3 CMP.B #'N',D0
      BNE NEXT4
      BSR NEW_POINTER
      BRA LOOP

NEXT4 CMP.B #'J',D0
      BNE NEXT5
      BSR JUMP
      BRA LOOP

NEXT5 CMP.B #'Z',D0
      BNE NEXT6
      BSR UPLOAD         ; PRINT_DEBUG <------ USE Z FOR UPLOAD BINARY IMAGE
      BRA LOOP


NEXT6 CMP.B #'F',D0
      BNE NEXT7
      BSR FILL_MEMORY
      BRA LOOP

NEXT7 CMP.B #'E',D0
      BNE NEXT8
      BSR EDIT_MEMORY
      BRA LOOP

NEXT8 CMP.B #'C',D0
      BNE NEXT9
      BSR CLEAR_MEMORY
      BRA LOOP

NEXT9 CMP.B #'Q',D0
      BNE NEXT10
      BSR QUICK_HOME
      BRA LOOP

NEXT10 CMP.B #'?',D0
       BNE.S NEXT11
       BSR HELP
       BRA LOOP


NEXT11 CMP.B #'R',D0
      BNE.S NEXT12
      BSR DISPLAY_REG
      BRA LOOP

NEXT12 CMP.B #'.',D0
      BNE.S NEXT13
      BSR MODIFY_REG
      BRA LOOP

NEXT13 CMP.B #'D',D0
       BNE.S NEXT14
       BSR DISASSEMBLE
       BRA LOOP

NEXT14 CMP.B #'A',D0
       BNE.S NEXT15
       BSR ABOUT
       BRA LOOP


NEXT15 CMP.B #'T',D0
       BNE.S NEXT16
       BSR TRACE_JUMP
       BRA LOOP

NEXT16 CMP.B #'G',D0
       BNE.S NEXT17
       JMP $102000.L       ; USE G COMMAND FOR SIMPLE JUMP TO RAM


NEXT17 CMP.B #'B',D0
       BNE.S NEXT18
       BRA BOOT_RAM

NEXT18  BSR NEW_LINE
      BSR SEND_TITLE
      bra loop

; CONSOLE IS ACIA1

	  IFEQ	EASY68K_SIM
		
; INIT ACIA

INIT_ACIA  MOVE.B #3,ACIAC.L   ; RESET ACIA
           MOVE.W #100,D0
           DBRA  D0,*
           MOVE.B #$15,ACIAC.L   ; rts enabled 9600 8ne
           RTS

COUT      BTST.B #TDRE,ACIAC.L
          BEQ.S  COUT
          MOVE.B D0,ACIAD.L
          RTS


CINS      BTST.B #RDRF,ACIAC.L
          BEQ.S  CINS
          MOVE.B ACIAD.L,D0
          RTS


CIN      BTST.B #RDRF,ACIAC.L
         BEQ.S  CIN
         MOVE.B ACIAD.L,D0
         BSR COUT
         RTS

	ENDC

; CONSOLE IS EASy68K Sim68K I/O

	IFNE	EASY68K_SIM

INIT_ACIA  ;Keyboard Echo.
           ;D1.B = 0 to turn off keyboard echo.
           ;D1.B = non zero to enable it (default).
           ;Echo is restored on 'Reset' or when a new file is loaded.
           MOVE.B #0,D1
           MOVE.B #12,D0
           TRAP #15
           RTS

COUT      MOVEM.L D0-D1,-(SP)  ; SAVE D1
          MOVE.B D0,D1
          MOVE.B #6,D0
          TRAP #15
          MOVEM.L (SP)+,D0-D1 ; RESTORE D1
          RTS


CINS      MOVE.L D1,-(SP)  ; SAVE D1
          MOVE.B #5,D0
          TRAP #15
          MOVE.B D1,D0  ;ACIAD.L,D0
          MOVE.L (SP)+,D1 ; RESTORE D1
          RTS


CIN       BSR CINS
          BSR COUT
          RTS

         ENDC


; A3 POINTED TO FIRST BYTE
; END WITH 0

PSTR     MOVE.B (A3)+,D0
         CMP.B  #0,D0
         BEQ.S PSTR1
         BSR COUT
         BRA.S PSTR

PSTR1    RTS

; NEW LINE

NEW_LINE MOVE.L D0,-(SP)
         MOVE.B #CR,D0
         BSR COUT
         MOVE.B #LF,D0
         BSR COUT
         MOVE.L (SP)+,D0
         RTS

SPACE    MOVE.B #SP,D0
         BSR COUT
         RTS

SCROLL   MOVE.W #25,D1
SCROLL1  BSR NEW_LINE
         DBF D1,SCROLL1
         RTS

SEND_PROMPT
        MOVEA.L RAMBASE.L,A6
        BSR NEW_LINE
        MOVE.L POINTER_NOW(A6),D0
        BSR OUT6X
        LEA.L PROMPT.L,A3
        BSR PSTR
        RTS

SEND_TITLE LEA.L TITLE.L,A3
           BSR PSTR
           RTS

; S19 LOADER

; CONVERT ASCII LETTER TO 8-BIT VALUE

TO_HEX SUBI.B #$30,D0
       CMPI.B #$A,D0
       BMI  ZERO_TO_NINE
       AND.B #%11011111,D0
       SUBI.B #7,D0

ZERO_TO_NINE

       MOVE.B D0,D1

        RTS

; READ TWO BYTES ASCII AND CONVERT TO SINGLE BYTE DATA

; ENTRY: D0 FROM CIN 
; EXIT: D1 8-BIT VALUE 
;       


GET_HEX  BSR CIN

         CMP.B #' ',D0         ; IF BIT_ESC PRESSED
         BNE.S GET_HEX1
         BSET.B #BIT_ESC,FLAG(A6)
         RTS


GET_HEX1 CMP.B #CR,D0
         BNE.S GET_HEX2
         BSET.B #1,FLAG(A6)       ; ENTER PRESSED
         RTS


GET_HEX2 BSR TO_HEX
         ROL.B #4,D1
         MOVE.B D1,D2
         BSR CIN
         BSR TO_HEX
         ADD.B D2,D1
         RTS


GET_HEXS   BSR CINS
         BSR TO_HEX
         ROL.B #4,D1
         MOVE.B D1,D2
         BSR CINS
         BSR TO_HEX
         ADD.B D2,D1
         RTS

;
;S214000400227C00400001143C00006100002C128297
;S804000000FB

; READ S-RECORD
; D5 = BYTE CHECK SUM FOR EACH RECORD
; D4 = NUMBER OF BYTE RECEIVED

READ_S_REC      LEA.L LOAD.L,A3
                BSR PSTR
                CLR.L D4     ; CLEAR NUMBER OF BYTE 
                CLR.L D5     ; CLEAR CHECK SUM AND ERROR BYTE

READ_S_REC1     BSR CINS
                CMP.B #'S',D0
                BNE.S CHECK_ESC
                BRA.S GET_TYPE


CHECK_ESC       CMP.B #ESC,D0
                BNE.S READ_S_REC1

                RTS


GET_TYPE        BSR CINS
                CMP.B #'8',D0
                BNE CHECK_START

WAIT_CR         BSR CINS
                CMP.B #CR,D0
                BNE.S WAIT_CR

                BSR NEW_LINE
                BSR NEW_LINE
                MOVE.L D4,D0
                BSR PRINT_DEC     ; SHOW NUMBER OF BYTE RECEIVED
                MOVEA.L #NUMBER,A3
                BSR PSTR

                SWAP.W D5
                CLR.L D0
                MOVE.W D5,D0
                BSR PRINT_DEC
                MOVEA.L #ERROR,A3
                BSR PSTR
                RTS


CHECK_START     CMP.B #'2',D0	; CHECK S2 RECORD
                BEQ.S READ_S2

                CMP.B #'1',D0	; CHECK S1 RECORD
                BEQ.S READ_S1

                CMP.B #'0',D0	; CHECK S0 RECORD
                BEQ.S READ_S_REC1	; SKIP DATA
                BRA.S READ_S_REC1	; SKIP DATA


START_FOUND     CLR.W D5          ; CLEAR BYTE CHECK SUM

                BSR GET_HEXS
                CLR.L D7
                MOVE.B D1,D7       ; NUMBER OF BYTE SAVED TO D7
                ;SUBQ.B #5,D7
                ;MOVE.L D7,D0

                ADD.B  D1,D5       ; ADD CHECK SUM
		RTS

;S1 (2 BYTE ADDRESS)
READ_S1		BSR START_FOUND

              SUBQ.B #4,D7
              MOVE.L D7,D0

; GET 16-BIT ADDRESS, SAVE TO A6

              CLR.L D6
              BSR GET_HEXS
              MOVE.B D1,D6
              ADD.B  D1,D5          ; ADD CHECK SUM

              ROL.L #8,D6
              BSR GET_HEXS
              MOVE.B D1,D6
              ADD.B D1,D5           ; ADD CHECK SUM

              MOVEA.L D6,A6
              BRA READ_DATA           


;S2 (3 BYTE ADDRESS)
READ_S2       BSR START_FOUND                

              SUBQ.B #5,D7
              MOVE.L D7,D0

; GET 24-BIT ADDRESS, SAVE TO A6

              CLR.L D6
              BSR GET_HEXS
              MOVE.B D1,D6
              ADD.B  D1,D5

              ROL.L #8,D6
              BSR GET_HEXS
              MOVE.B D1,D6
              ADD.B D1,D5

              ROL.L #8,D6

              BSR GET_HEXS
              MOVE.B D1,D6
              ADD.B D1,D5

              MOVEA.L D6,A6
                         
READ_DATA     BSR GET_HEXS
              ADD.B  D1,D5      ; ADD CHECK SUM
              MOVE.B D1,(A6)+

              not.b d1          ; complement before sending

              ;MOVE.B D1,DOUT.L  ; INDICATOR WHILE LOADING

              ADDQ.L #1,D4      ; BUMP NUMBER OF BYTE RECEIVED
              DBF D7,READ_DATA

              NOT.B D5          ; ONE'S COMPLEMENT OF BYTE CHECK SUM         

              BSR GET_HEXS      ; GET BYTE CHECK SUM

              CMP.B D1,D5       ; COMPARE CHECK SUM
              BEQ.S NO_ERROR

              ADD.L #$10000,D5  ; ADD 1 TO UPPER WORD
              MOVE.B #'X',D0    ; IF NOT EQUAL SEND 'X' FOR ERROR
              BRA.S CHECKSUM_ERROR

NO_ERROR      MOVE.B #'_',D0      ; '_' NO ERROR RECORD
CHECKSUM_ERROR BSR COUT

              BRA READ_S_REC1


LOOP_BACK     BSR CIN
              CMP.B #13,D0
              BNE LOOP_BACK
              RTS



; PRINT HEX 
; OUT1X = PRINT ONE HEX
; OUT2X = PRINT TWO
; OUT4X = PRINT FOUR
; OUT8X = PRINT EIGHT
; ENTRY: D0

OUT1X        MOVE.B D0,-(SP)    ;SAVE D0
             AND.B #$F,D0
             ADD.B #'0',D0
             CMP.B #'9',D0
             BLS.S   OUT1X1
             ADD.B #7,D0
OUT1X1       BSR COUT
             MOVE.B (SP)+,D0    ;RESTORE D0
             RTS

OUT2X        ROR.B #4,D0
             BSR.S OUT1X
             ROL.B #4,D0
             BRA OUT1X

OUT4X        ROR.W #8,D0
             BSR.S OUT2X
             ROL.W #8,D0
             BRA.S OUT2X

OUT6X        SWAP.W D0        ; OUT 24-BIT HEX NUMBER
             BSR.S OUT2X
             SWAP.W D0
             BRA.S OUT4X

OUT8X        SWAP.W D0        ; OUT 32-BIT HEX NUMBER
             BSR.S  OUT4X
             SWAP.W D0
             BRA.S  OUT4X


; PRINT D0 CONTENT

PRINT_D0  BSR.S OUT8X
          RTS

; HEX DUMP
; DUMP MEMORY CONTENT
; A3: START ADDRESS

HEX_DUMP    LEA.L HEX.L,A3
            BSR PSTR

            MOVEA.L RAMBASE.L,A6
            MOVEA.L POINTER_NOW(A6),A3
            MOVE.W #15,D6
            BSR NEW_LINE

HEX_DUMP2   BSR NEW_LINE
            MOVE.L A3,D0
            BSR OUT6X
            BSR SPACE
            BSR SPACE

            MOVE.W #15,D7

HEX_DUMP1   MOVE.B (A3)+,D0
            BSR OUT2X
            BSR SPACE

            DBF D7,HEX_DUMP1

            BSR SPACE
            SUBA.L #16,A3       ; GET BACK TO BEGINING 
            MOVE.W #15,D7

HEX_DUMP6   MOVE.B (A3)+,D0

            CMP.B #$20,D0
            BGE.S HEX_DUMP3

HEX_DUMP4   MOVE.B #'.',D0
            BRA.S  HEX_DUMP5

HEX_DUMP3   CMP.B #$7F,D0
            BGT.S HEX_DUMP4

HEX_DUMP5   BSR COUT
            DBF D7,HEX_DUMP6


            DBF D6,HEX_DUMP2

            MOVE.L A3,POINTER_NOW(A6)   ; UPDATE POINTER_NOW
            BSR NEW_LINE
            RTS


; NEW POINTER
; CHANGE 24-BIT ADDRESS-> POINTER_NOW

NEW_POINTER   LEA.L NEW.L,A3
              BSR PSTR

              BSR SEND_PROMPT

              MOVEA.L RAMBASE.L,A6
              CLR.L D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6

              BCLR.L #0,D6        ; FORCE TO EVEN ADDRESS

              MOVE.L D6,POINTER_NOW(A6)
              RTS

PRINT_DEBUG   BSR NEW_LINE
              MOVE.L DEBUG(A6),D0
              BSR OUT8X
              RTS

QUICK_HOME    LEA.L QUICK.L,A3
              BSR PSTR
              MOVEA.L RAMBASE.L,A6
              MOVE.L #RAM,POINTER_NOW(A6)
              RTS  

; TEST RAM

; GET 32BIT DATA
; EXIT: D6 CONTAINS 32-BIT ADDRESS

GET_32BIT     CLR.L D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              RTS


; GET_ADDRESS
; EXIT: D6 CONTAINS 24-BIT ADDRESS

GET_ADDRESS   CLR.L D6
              BSR GET_HEX

GET_ADDRESS1  MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              ROL.L #8,D6
              BSR GET_HEX
              MOVE.B D1,D6
              RTS

TEST_RAM      RTS

; FILL MEMORY WITH 0xFF

FILL_MEMORY   LEA.L FILL.L,A3
              BSR PSTR

              LEA.L START.L,A3
              BSR PSTR
              BSR GET_ADDRESS
              MOVEA.L D6,A4             ; A4 START ADDRESS

              LEA.L STOP.L,A3
              BSR PSTR
              BSR GET_ADDRESS
              MOVEA.L D6,A5             ; A5 STOP ADDRESS

FILL_MEMORY1  MOVE.W #$FFFF,(A4)+
              CMPA.L A4,A5
              BGE.S FILL_MEMORY1

              MOVEA.L #DONE,A3
              BSR PSTR
              RTS

; CLEAR MEMORY WITH 0x00

CLEAR_MEMORY  LEA.L CLEAR.L,A3
              BSR PSTR

              LEA.L START.L,A3
              BSR PSTR
              BSR GET_ADDRESS
              MOVEA.L D6,A4             ; A4 START ADDRESS

              LEA.L STOP.L,A3
              BSR PSTR
              BSR GET_ADDRESS
              MOVEA.L D6,A5             ; A5 STOP ADDRESS

CLEAR_MEMORY1 MOVE.W #$0000,(A4)+
              CMPA.L A4,A5
              BGE.S CLEAR_MEMORY1

              MOVEA.L #DONE,A3
              BSR PSTR
              RTS

; EDIT MEMORY
; PRESS SPACE BAR TO QUIT

EDIT_MEMORY   LEA.L EDIT1.L,A3
              BSR PSTR

              LEA.L EDIT.L,A3
              BSR PSTR
              BSR GET_ADDRESS

              BCLR.L #0,D6        ; FORCE TO EVEN ADDRESS
              MOVEA.L D6,A3       ; EDIT ADDRESS

             ; MOVEA.L POINTER_NOW.L,A3

EDIT_MEMORY2  BSR NEW_LINE
              MOVE.L A3,D0
              BSR OUT6X
              BSR SPACE
              BSR SPACE

              MOVE.B #'[',D0
              BSR COUT
              MOVE.W (A3),D0
              BSR OUT4X
              MOVE.B #']',D0
              BSR COUT

              BSR SPACE

              CLR.W D1
              BSR GET_HEX

              BCLR.B #BIT_ESC,FLAG(A6)	; TEST BIT_ESC BIT
              BNE.S EDIT_MEMORY3  ; IF BIT = 1 THEN EXIT

              BCLR.B #1,FLAG(A6)  ; CHECK IF ENTER KEY PRESSED
              BNE.S EDIT_MEMORY4  ; SKIP WRITE TO RAM

              ROL.W #8,D1
              BSR GET_HEX

              MOVE.W #0,(A3)

              MOVE.W (A3),D0   ; TEST RAM OR ROM BY WRITING 0 AND READ BACK
              CMP.W #0,D0
              BNE.S EDIT_MEMORY5

              MOVE.W D1,(A3)     ; OK WRITE TO RAM
              BRA.S EDIT_MEMORY4 

EDIT_MEMORY5  MOVE.L A3,-(SP)
              LEA.L ROM.L,A3
              BSR PSTR
              MOVEA.L (SP)+,A3

EDIT_MEMORY4  ADDQ.L #2,A3     ; BUMP A3

              BRA.S EDIT_MEMORY2

EDIT_MEMORY3  BSR NEW_LINE
              RTS


; HELP LIST MONITOR COMMANDS

HELP          LEA.L HELP_LIST.L,A3
              BSR PSTR
              RTS

;----------------------------------------------------------------------
; PRINT_DEC
; D0 32-BIT BINARY NUMBER

PRINT_DEC MOVE.L D0,-(SP)  ; SAVE D0
          MOVEA.L RAMBASE.L,A6
          ADDA.L #BUFFER,A6
          BSR HEX2DEC
          MOVEA.L RAMBASE.L,A3
          ADDA.L #BUFFER,A3
          BSR PSTR
          MOVE.L (SP)+,D0 ; RESTORE D0
          RTS

;**************************************************************************
; The portion of code within STAR lines are modified from Tutor source code
;
;
; HEX2DEC   HEX2DEC convert hex to decimal                   
; CONVERT BINARY TO DECIMAL  REG D0 PUT IN (A6) BUFFER AS ASCII

HEX2DEC  MOVEM.L D1-D7,-(SP)   ;SAVE REGISTERS
         MOVE.L  D0,D7               ;SAVE IT HERE
         BPL.S   HX2DC
         NEG.L   D7             ;CHANGE TO POSITIVE
         BMI.S   HX2DC57        ;SPECIAL CASE (-0)
         MOVE.B  #'-',(A6)+     ;PUT IN NEG SIGN
HX2DC    CLR.W   D4             ;FOR ZERO SURPRESS
         MOVEQ.L   #10,D6         ;COUNTER
HX2DC0   MOVEQ.L   #1,D2          ;VALUE TO SUB
         MOVE.L  D6,D1          ;COUNTER
         SUBQ.L  #1,D1          ;ADJUST - FORM POWER OF TEN
         BEQ.S   HX2DC2         ;IF POWER IS ZERO
HX2DC1   MOVE.W  D2,D3          ;D3=LOWER WORD
         MULU.W    #10,D3
         SWAP.W    D2             ;D2=UPPER WORD
         MULU.W    #10,D2
         SWAP.W    D3             ;ADD UPPER TO UPPER
         ADD.W   D3,D2
         SWAP.W    D2             ;PUT UPPER IN UPPER
         SWAP.W    D3             ;PUT LOWER IN LOWER
         MOVE.W  D3,D2          ;D2=UPPER & LOWER
         SUBQ.L  #1,D1
         BNE     HX2DC1
HX2DC2   CLR.L   D0             ;HOLDS SUB AMT
HX2DC22  CMP.L   D2,D7
         BLT.S   HX2DC3         ;IF NO MORE SUB POSSIBLE
         ADDQ.L  #1,D0          ;BUMP SUBS
         SUB.L   D2,D7          ;COUNT DOWN BY POWERS OF TEN
         BRA.S   HX2DC22        ;DO MORE
HX2DC3   TST.B   D0             ;ANY VALUE?
         BNE.S   HX2DC4
         TST.W   D4             ;ZERO SURPRESS
         BEQ.S   HX2DC5
HX2DC4   ADDI.B  #$30,D0        ;BINARY TO ASCII
         MOVE.B  D0,(A6)+       ;PUT IN BUFFER
         MOVE.B  D0,D4          ;MARK AS NON ZERO SURPRESS
HX2DC5   SUBQ.L  #1,D6          ;NEXT POWER
         BNE     HX2DC0
         TST.W   D4             ;SEE IF ANYTHING PRINTED
         BNE.S   HX2DC6
HX2DC57  MOVE.B  #'0',(A6)+     ;PRINT AT LEST A ZERO
HX2DC6   MOVE.B  #0,(A6)        ; PUT TERMINATOR
         MOVEM.L (SP)+,D1-D7   ;RESTORE REGISTERS
         RTS                    ;END OF ROUTINE

*
*  PRINT HEX ROUTINES
*
*
* PRINT 8 HEX CHARACTERS
*
*  D0,D1,D2 DESTROYED
*
PNT8HX   SWAP    D0             FLIP REG HALVES
         BSR.S   PNT4HX         DO TOP WORD
         SWAP    D0             NOW DO LOWER WORD
         BRA.S   PNT4HX
* PRINT 6 HEX CHARACTERS
PNT6HX   SWAP    D0             FLIP REGISTER HALVES
         BSR.S   PNT2HX
         SWAP    D0             FLIP BACK REG HALVES
* PRINT 4 HEX CHARACTERS IN D0.W
PNT4HX   MOVE.W  D0,D1          SAVE IN TEMP
         ROR.W   #8,D0          GET BITS 15-8 INTO LOWER BYTE
         BSR.S   PNT2HX         PRINT IT
         MOVE.W  D1,D0          PULL IT BACK
* PRINT 2 HEX CHARACTERS IN D0.B
PNT2HX   MOVE.W  D0,D2          SAVE IN TEMP REG
         ROXR.W  #4,D0          FORM UPPER NIBBLE
         BSR.S   PUTHEX         PUT ASCII INTO PRINT BUFFER
         MOVE.W  D2,D0          GET BACK FROM TEMP
* CONVERT D0.NIBBLE TO HEX & PUT IT IN PRINT BUFFER
*
PUTHEX   ANDI.B  #$0F,D0        SAVE LOWER NIBBLE
         ORI.B   #$30,D0        CONVERT TO ASCII
         CMPI.B  #$39,D0        SEE IF IT IS>9
         BLE.S   SAVHEX
         ADD     #7,D0          ADD TO MAKE 10=>A
SAVHEX   MOVE.B  D0,(A6)+       PUT IT IN PRINT BUFFER
         RTS

* FORMAT RELATIVE ADDRESS  AAAAAA+Rn
*        ENTER     D0 = VALUE
*                  A6 = STORE POINTER
*
FRELADDR MOVEM.L D1/D5-D7/A0,-(A7)
         MOVEA.L RAMBASE.L,A0   ;LEA     OFFSET,A0
         MOVEQ   #-1,D7         D7 = DIFF. BEST FIT
         CLR.L   D6             D6 = OFFSET POSITION

FREL10   MOVE.L  D0,D1
         TST.L   (A0)
         BEQ.S   FREL15         ZERO OFFSET
         SUB.L   (A0),D1        D1 = DIFF.
         BMI.S   FREL15         NO FIT

         CMP.L   D7,D1
         BCC.S   FREL15         OLD FIT BETTER

         MOVE.L  D1,D7          D7 = NEW BEST FIT
         MOVE.L  D6,D5          D5 = POSITION

FREL15   ADDQ.L  #4,A0
         ADDQ.L  #1,D6
         CMPI.W  #8,D6
         BNE     FREL10         MORE OFFSETS TO CHECK

         TST.L   D7
         BMI.S   FREL25         NO FIT
         TST     D6
         BNE.S   FREL20
         TST.L   RAMBASE.L      ;TST.L    OFFSET
         BEQ.S   FREL25         R0 = 000000; NO FIT

FREL20   MOVE.L  D7,D0
         BSR     PNT6HX         FORMAT OFFSET
         MOVE.B  #'+',(A6)+     +
         MOVE.B  #'R',(A6)+     R
         ADDI.B  #'0',D5        MAKE ASCII
         BRA.S   FREL30

FREL25   BSR     PNT6HX         FORMAT ADDRESS AS IS
         MOVE.B  #BLANK,D5
         MOVE.B  D5,(A6)+       THREE SPACES FOR ALIGNMENT
         MOVE.B  D5,(A6)+
FREL30   MOVE.B  D5,(A6)+

         MOVEM.L (A7)+,D1/D5-D7/A0
         RTS

;******************************************************************************


; DISPLAY USER REGISTERS D0-D7 AND A0-A7
;

DISPLAY_REG  LEA.L REGISTER_DISP.L,A3
             BSR PSTR

DISPLAY_REG1 MOVEA.L RAMBASE.L,A6
             BSR NEW_LINE
             BSR NEW_LINE
             MOVEA.L #PC_REG,A3
             BSR PSTR
             MOVE.L USER_PC(A6),D0
             BSR OUT6X

             BSR SPACE

             MOVEA.L #SR_REG,A3
             BSR PSTR
             MOVE.W USER_SR(A6),D0
             BSR OUT4X

; NOW PRINT FLAG LOGIC IN BINARY
             MOVE.B D0,D4       ; SAVE TO D4

             LSL.B #3,D4        ; BIT POSITION BEFORE SHIFTING OUT

             BSR SPACE
             MOVEA.L #X_FLAG,A3
             BSR PSTR
             LSL.B #1,D4
             BSR PRINT_BIT

             BSR SPACE
             MOVEA.L #N_FLAG,A3
             BSR PSTR
             LSL.B #1,D4
             BSR PRINT_BIT

             BSR SPACE
             MOVEA.L #Z_FLAG,A3
             BSR PSTR
             LSL.B #1,D4
             BSR PRINT_BIT

             BSR SPACE
             MOVEA.L #V_FLAG,A3
             BSR PSTR
             LSL.B #1,D4
             BSR PRINT_BIT

             BSR SPACE
             MOVEA.L #CARRY_FLAG,A3
             BSR PSTR
             LSL.B #1,D4
             BSR PRINT_BIT


             BSR NEW_LINE
             MOVE.B #0,D2

             MOVEA.L RAMBASE.L,A6

             LEA.L USER_DATA(A6),A3

REG1         MOVE.B #'D',D0
             BSR COUT
             MOVE.B D2,D0
             BSR OUT1X
             MOVE.B #'=',D0
             BSR COUT

             MOVE.L (A3)+,D0
             BSR OUT8X
             ADDQ.B #1,D2
             CMPI.B #8,D2
             BEQ.S REG4
             BSR SPACE

             CMPI.B #4,D2
             BNE.S REG1
             BSR NEW_LINE
             BRA.S REG1

REG4         BSR NEW_LINE
             MOVE.B #0,D2

REG3         MOVE.B #'A',D0
             BSR COUT
             MOVE.B D2,D0
             BSR OUT1X
             MOVE.B #'=',D0
             BSR COUT

             MOVE.L (A3)+,D0
             BSR OUT8X
             ADDQ.B #1,D2
             CMPI.B #8,D2
             BEQ.S REG2
             BSR SPACE

             CMPI.B #4,D2
             BNE.S REG3
             BSR NEW_LINE
             BRA.S REG3

REG2         BSR NEW_LINE
             RTS




; SEND '0' OR '1' TO SCREEN

PRINT_BIT   BCS.S WRITE_1
            MOVE.B #'0',D0
            BSR COUT
            RTS

WRITE_1     MOVE.B #'1',D0
            BSR COUT
            RTS

; JUMP TO USER PROGRAM
; 

JUMP       LEA.L JUMP_TO.L,A3
           BSR PSTR

           MOVEA.L RAMBASE.L,A6
           MOVE.L USER_PC(A6),D0
           BSR OUT6X
           MOVE.B #'>',D0

           BSR COUT

           BSR GET_HEX

           BCLR.B #BIT_ESC,FLAG(A6)	; TEST BIT_ESC BIT
           BNE.S ABORT             ; IF BIT = 1 THEN EXIT

           BCLR.B #1,FLAG(A6)  ; CHECK IF ENTER KEY PRESSED
           BNE.S JUMP1         ; RUN USER PROGRAM

           CLR.L D6
           BSR GET_ADDRESS1

; GOT D6 FOR DESTINATION

           MOVE.L D6,USER_PC(A6)  ; SAVE TO USER PC
           BRA.S JUMP1

ABORT      RTS                 ; GET BACK MONITOR

JUMP1      MOVEA.L RAMBASE.L,A6     ; POINTED TO START MONITOR RAM

           MOVEA.L USER_USP(A6),A0
           MOVE.L  A0,USP           ; WRITE TO REAL USER STACK (A7)

           MOVE.L  USER_PC(A6),-(SP)     ; PUSH PC

           BCLR.B   #5,USER_SR(A6) ; SET USER MODE     

           MOVE.W  USER_SR(A6),-(SP)
           MOVEM.L USER_DATA(A6),D0-D7/A0-A6
           RTE                     ; JUMP TO USER PROGRAM


; TRACE JUMP
; SET TRACE BIT IN SAVED STATUS REGISTER

TRACE_JUMP LEA.L TRACE_MSG.L,A3
           BSR PSTR
           BSR NEW_LINE

           MOVEA.L RAMBASE.L,A6
           MOVEA.L USER_PC(A6),A4
           MOVEM.L (A4),D0-D2
           MOVEA.L RAMBASE.L,A5
           ADDA.L #BUFFER,A5      ; LOAD A5 WITH $130000+BUFFER

           JSR  DCODE68K.L

           BSR NEW_LINE
           BSR PRINT_LINE

           MOVEA.L RAMBASE.L,A6

           BSET.B #TRACE_BIT,USER_SR(A6)  ; SET TRACE BIT
           BRA JUMP1                    ; BORROW JUMP ROUTINE

; CLEAR MONITOR RAM

CLEAR_MON_RAM MOVEA.L RAMBASE.L,A6
              MOVE.W  #512,D7

CLEAR1        MOVE.W #0000,(A6)+
              DBRA D7,CLEAR1
              RTS



; MODIFY USER REGISTERS

MODIFY_REG    MOVEA.L RAMBASE.L,A6
              BSR CIN
              AND.B #%11011111,D0
              CMPI.B #'P',D0
              BNE.S DATA_REG1

              MOVE.B #'C',D0
              BSR COUT
              MOVE.B #'=',D0
              BSR COUT
              BSR GET_ADDRESS

              MOVE.L D6,USER_PC(A6)
              RTS

DATA_REG1     CMPI.B #'D',D0
              BNE.S ADDRESS_REG2
              BSR CIN
              SUB.B #'0',D0

              CLR.L D7
              MOVE.B D0,D7

              MOVE.B #'=',D0
              BSR COUT

              BSR GET_32BIT

              LSL.B #2,D7        ; D7*4
              ADDA.W D7,A6
              MOVE.L D6,USER_DATA(A6)  ; SAVE TO USER DATA REGISTERS

              RTS
              
ADDRESS_REG2  CMPI.B #'A',D0
              BNE.S WHAT3
              BSR CIN
              SUB.B #'0',D0

              CLR.L D7
              MOVE.B D0,D7

              MOVE.B #'=',D0
              BSR COUT

              BSR GET_32BIT

              LSL.B #2,D7        ; D7*4
              ADDA.W D7,A6
              MOVE.L D6,USER_ADDR(A6)  ; SAVE TO USER ADDRESS REGISTERS

WHAT3         RTS

;=======================================================================
; TRAP #N SERVICES
;

SERVICE_TRAP0   MOVE.L A0,-(SP)      ; SAVE A0 BEFOREHAND
                MOVEA.L RAMBASE.L,A0  ; USE A0 AS THE POINTER
                LEA.L USER_DATA(A0),A0
                MOVEM.L D0-D7/A0-A6,(A0)
                MOVE.L (SP)+,32(A0)  ; RESTORE A0

                MOVEA.L RAMBASE.L,A0
                MOVE.W (SP)+,USER_SR(A0)
                BCLR.B #TRACE_BIT,USER_SR(A0) ; TURN TRACE BIT OFF
                MOVE.L (SP)+,USER_PC(A0)

                MOVE.L USP,A2
                MOVE.L A2,USER_USP(A0)

                BSR DISPLAY_REG1

                MOVE.L #SUPER_STACK,SP  ; REINIT SYSTEM STACK
                MOVE.W #INT_ON,SR   ; REENTER SUPERVISOR MODE

                JMP LOOP.L        ; GET BACK MONITOR


; DISASSEMBLE THE MACHNIE CODE INTO MNEMONIC

DISASSEMBLE     LEA.L DIS.L,A3
                BSR PSTR

           ;   LEA.L $102000.L,A4

               MOVEA.L RAMBASE.L,A6

               MOVE.W #19,D7       ; 20 LINES DISASSEMBLE

               MOVEA.L POINTER_NOW(A6),A4

DIS1           MOVEM.L (A4),D0-D2
               MOVEA.L RAMBASE.L,A5
               ADDA.L #BUFFER,A5      ; LOAD A5 WITH $130000+BUFFER

               MOVEM.L A6/D7,-(SP)

               JSR  DCODE68K.L

               BSR NEW_LINE
               BSR PRINT_LINE

               MOVEM.L (SP)+,D7/A6

               DBRA D7,DIS1

               MOVE.L A4,POINTER_NOW(A6) ; NEXT BLOCK
               BSR NEW_LINE
               RTS

PRINT_LINE     MOVE.B (A5)+,D0
               BSR COUT
               CMPA.L A5,A6
               BNE.S PRINT_LINE
               RTS


; UPLOAD BINARY IMAGE FROM MEMORY
; SEND IT TO TERMINAL AS HEX CODE IN LONG WORD FORMAT
; USE FOR DISASSEMBLER HEX CODE PREPARATION

UPLOAD        LEA.L UPLOAD1.L,A3
              BSR PSTR
              BSR CIN

              LEA.L $100400.L,A5    ; START
              LEA.L $102000.L,A6    ; STOP

UPLOAD3       BSR NEW_LINE
              LEA.L STRING1.L,A3
              BSR PSTR

              MOVE.W #7,D7

UPLOAD2       MOVE.B #'$',D0
              BSR COUT
              MOVE.L (A5)+,D0
              BSR OUT8X
              MOVE.B #',',D0
              BSR COUT
              DBRA D7,UPLOAD2

              CMPA.L A5,A6
              BGT  UPLOAD3

              RTS

; ABOUT zBUG V1.0

ABOUT         LEA.L ABOUTZBUG.L,A3
              BSR PSTR
              RTS

; VIEW USER STACK

VIEW_USP      LEA.L VIEW.L,A3
              BSR PSTR

              BSR NEW_LINE

              MOVEA.L #SUPER_STACK+USER_STACK,A1 ; TOP OF USER STACK

              LEA.L -32(A1),A0    ; EACH COMPOSED OF TWO BYTES

              MOVE.W #16,D7
              MOVEA.L RAMBASE.L,A6


VIEW1         MOVE.L A0,D0

              MOVE.L D0,-(SP)

              CMPA.L USER_USP(A6),A0
              BNE.S NOT_TOS

              LEA.L TOP_OF_STACK.L,A3
              BSR PSTR
              BRA.S SKIP_PRINT_BLANK

NOT_TOS       LEA.L BLANK_BLOCK.L,A3
              BSR PSTR

SKIP_PRINT_BLANK

              MOVE.L (SP)+,D0
              BSR OUT6X
              BSR SPACE

              MOVE.B #'[',D0
              BSR COUT

              MOVE.W (A0)+,D0
              BSR OUT4X

              MOVE.B #']',D0
              BSR COUT

              BSR NEW_LINE
              DBRA D7,VIEW1

              RTS


; LOAD SP WITH [RAM] AND PC [RAM+4]

BOOT_RAM      MOVEA.L RAM.L,SP
              MOVEA.L 4+RAM.L,A0
              JMP     (A0)

; SERVICE BUS ERROR
SERVICE_BUSERROR MOVEA.L BUSERROR_MSG.L,A3
                BRA SERVICE_MSG

; SERVICE ADDRESS ERROR
SERVICE_ADDRESSERR MOVEA.L ADDRESSERR_MSG.L,A3
                BRA SERVICE_MSG

; SERVICE ILLEGAL INTSRUCTION
SERVICE_ILLEGAL MOVEA.L ILLEGAL_MSG.L,A3
                BRA SERVICE_MSG

; SERVICE ZERO DIVIDE
SERVICE_ZERODIV MOVEA.L ZERODIV_MSG.L,A3
SERVICE_MSG     BSR PSTR
                TRAP #0

; vector table initrize
VECINIT   LEA   VECTABLE(pc),a0
          MOVEA.W   #$0008,a1
          MOVEQ     #10,D0
VECINIT1  MOVE.L    (a0)+,(a1)+
          SUBQ.B    #1,D0
          BNE       VECINIT1
          MOVEA.W   #$60,A1
          MOVEQ     #24,D0
VECINIT2  MOVE.L    (a0)+,(a1)+
          SUBQ.B    #1,D0
          BNE       VECINIT2
          MOVEA.W   #$C0,A1
          MOVE.L    #RAMBASE_INIT,(a1)
          RTS

;----------------- M68000 EXCEPTION VECTOR TABLE -----------------------------
VECTABLE  DC.L  SERVICE_BUSERROR     ; 2 Bus error
          DC.L  SERVICE_ADDRESSERR   ; 3 Address error
          DC.L  SERVICE_ILLEGAL      ; 4 Illegal instruction
          DC.L  SERVICE_ZERODIV      ; 5 Zero divide
          DC.L  SERVICE_TRAP0        ; 6 CHK instruction
          DC.L  SERVICE_TRAP0        ; 7 TRAPV instruction
          DC.L  SERVICE_TRAP0        ; 8 Privilege violation
          DC.L  SERVICE_TRAP0        ; 9 Trace
          DC.L  SERVICE_TRAP0    ; 10 Line 1010 emulator
          DC.L  SERVICE_TRAP0    ; 11 Line 1111 emulator

          DC.L  SERVICE_TRAP0    ; 24 Spurious Interupt
          DC.L  SERVICE_TRAP0    ; 25 LEVEL 1 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 26 LEVEL 2 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 27 LEVEL 3 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 28 LEVEL 4 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 29 LEVEL 5 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 30 LEVEL 6 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 31 LEVEL 7 Interupt autovector
          DC.L  SERVICE_TRAP0    ; 32 TRAP #0
          DC.L  SERVICE_TRAP0    ; 33 TRAP #1
          DC.L  SERVICE_TRAP0    ; 34 TRAP #2
          DC.L  SERVICE_TRAP0    ; 35 TRAP #3
          DC.L  SERVICE_TRAP0    ; 36 TRAP #4
          DC.L  SERVICE_TRAP0    ; 37 TRAP #5
          DC.L  SERVICE_TRAP0    ; 38 TRAP #6
          DC.L  SERVICE_TRAP0    ; 39 TRAP #7
          DC.L  SERVICE_TRAP0    ; 40 TRAP #8
          DC.L  SERVICE_TRAP0    ; 41 TRAP #9
          DC.L  SERVICE_TRAP0    ; 42 TRAP #10
          DC.L  SERVICE_TRAP0    ; 43 TRAP #11
          DC.L  SERVICE_TRAP0    ; 44 TRAP #12
          DC.L  SERVICE_TRAP0    ; 45 TRAP #13
          DC.L  SERVICE_TRAP0    ; 46 TRAP #14
          DC.L  SERVICE_TRAP0    ; 47 TRAP #15
;----------------------- STRING CONSTANT -------------------------------------

TITLE  DC.B 13,10,'zBug V1.0.1 for MIC68K',13,10,0
TITLE1 DC.B 13,10,'zBug V1.0.1 for MIC68K (press ? for help)',13,10,0

PROMPT DC.B '>',0

CLEAR  DC.B 'lear memory with 0x0000',0
FILL   DC.B 'ill memory with 0xFFFF',0 
START  DC.B 13,10,10,'start address=',0
STOP   DC.B 13,10,'stop  address=',0
DONE   DC.B 13,10,'done...',0

EDIT1  DC.B 'dit memory (quit: SPACE BAR, next address: ENTER)',0
EDIT   DC.B 13,10,10,'Address=',0
ROM    DC.B '  rom',0

NEW    DC.B 'ew 24-bit pointer',0

QUICK  DC.B 'uick home, get back to start of RAM!',13,10,0
HEX    DC.B 'ex dump memory',13,10,10
       DC.B 'ADDRESS  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F',0

LOAD   DC.B 'oad Motorola s-record (accept s1,s2 and s8) quit: ESC',13,10,0

NUMBER DC.B ' bytes loaded, ',0
ERROR  DC.B ' records checksum error',13,10,0

JUMP_TO DC.B 'ump to user program ',0 

TRAP_0 DC.B ' TRAP 0 !',0

REGISTER_DISP DC.B 'egister(user) display (A7= user stack pointer)',0

DIS    DC.B 'isassemble machine code to mnemonic',13,10,0

UPLOAD1 DC.B 'pload binary image, hit any key to begin ',0
STRING1 DC.B '  DFL ',0

ABOUTZBUG DC.B 'bout zBuG V1.0',13,10,10
          DC.B 'zBug V1.0 Copyright (C) 2002 W.SIRICHOTE',13,10,10
          DC.B 'zBug V1.0.1 MIC68K Version by @kanpapa',13,10,0

TRACE_MSG DC.B 'race instruction',0

VIEW      DC.B 'tack (user)s content, shows 16-WORD deep',13,10,0

BUSERROR_MSG DC.B 'bus error...',0
ADDRESSERR_MSG DC.B 'address error...',0
ILLEGAL_MSG DC.B 'illegal instruction...',0
ZERODIV_MSG DC.B 'zero divide...',0

TOP_OF_STACK DC.B 'TOS--->',0
BLANK_BLOCK  DC.B '       ',0

PC_REG DC.B 'PC=',0
SR_REG DC.B 'SR=',0

CARRY_FLAG DC.B 'C=',0
V_FLAG     DC.B 'V=',0
Z_FLAG     DC.B 'Z=',0
N_FLAG     DC.B 'N=',0
X_FLAG     DC.B 'X=',0


HELP_LIST DC.B ' monitor commands',13,10,10

       DC.B 'A   About zBug V1.0',13,10
       DC.B 'B   Boot from RAM [000000] -> SP [000004] ->PC',13,10
       DC.B 'C   Clear memory with 0x0000',13,10
       DC.B 'D   Disassemble machine code to mnemonic',13,10
       DC.B 'E   Edit memory',13,10
       DC.B 'F   Fill memory with 0xFFFF',13,10
       DC.B 'H   Hex dump memory',13,10
       DC.B 'J   Jump to address',13,10
       DC.B 'L   Load Motorola s-record',13,10
       DC.B 'N   New 24-bit pointer',13,10
       DC.B 'R   Register(user) display',13,10
       DC.B 'S   Stack(user)s content',13,10
       DC.B 'T   Trace instruction',13,10
       DC.B '.   Modify user registers, exp .PC .D0 .A0',13,10
       DC.B '?   Monitor commands list',13,10,0


; MONITOR'S RAM AREA
; MUST BE EVEN ADDRESS FOE RAMBASE
; THE A6 WAS LOADED WITH RAMBASE AS THE BASE MEMORY POINTER
; THE FOLLOWING VARIABLE CAN BE ACCEESED BY USING INDIRECT WITH DISPLACMENT

;RAMBASE     DC.L   $130000     ; RAM BASE ADDRESS

; DCODE68K
DDATA    EQU     $FFFFFFF0       ; DS.L 3
HISPC    EQU     $FFFFFFFC       ; DS.L 1

; OFFSET(DISPLACEMENT) DEFINITION

OFFSET      EQU  0               ; FOR DISASSEMBLER USAGE
DEBUG       EQU  OFFSET+32
FLAG        EQU  DEBUG+4         ; 16-BIT MONITOR FLAG
BUFFER      EQU  FLAG+2
POINTER_NOW EQU  BUFFER+128
USER_DATA   EQU  POINTER_NOW+4   ; USER D0-D7 AND A0-A7
USER_ADDR   EQU  USER_DATA+32    ; USER ADDRESS REGISTERS, A0-A7
USER_USP    EQU  USER_ADDR+28    ; A7 = USP
USER_SR     EQU  USER_USP+4      ; 
USER_SS     EQU  USER_SR+2
USER_PC     EQU  USER_SS+4

STACK_AREA  EQU  USER_PC+4           ; 32kB USER STACK -> 2kB
;USER_STACK  EQU  STACK_AREA+$7000    ; TOP OF STACK
USER_STACK  EQU  STACK_AREA+$1F00    ; TOP OF STACK



       END	MAIN







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
