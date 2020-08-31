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
; November 6 2014 - Modifications for 68Katy by Steve Chamberlin
;

LOADADDR    EQU $00000

; 68Katy memory map
ROMBASE	    EQU $00000
SERIN       EQU $78000
SEROUT      EQU $7A000
SERSTATUS_RDF   EQU $7C000
SERSTATUS_TXE   EQU $7D000
DOUT        EQU $7E000
RAM         EQU $80000
RAMTOP      EQU $FFFFF

; RAM-resident vector jump table, 198 bytes
; the ROM exception vectors point here
JUMP_TABLE_TOP  EQU  RAMTOP-5
JBUS_ERR    EQU  JUMP_TABLE_TOP ; 32
JADDR_ERR   EQU  JBUS_ERR-6 ; 31
JILLEGAL    EQU  JADDR_ERR-6
JZERO_DIV   EQU  JILLEGAL-6 ; 29
JCHK        EQU  JZERO_DIV-6
JTRAPV      EQU  JCHK-6 ; 27
JPRIV_VIOL  EQU  JTRAPV-6
JTRACE      EQU  JPRIV_VIOL-6 ; 25
JLINE_A     EQU  JTRACE-6
JLINE_F     EQU  JLINE_A-6 ; 23
JINT1       EQU  JLINE_F-6
JINT2       EQU  JINT1-6
JINT3       EQU  JINT2-6
JINT4       EQU  JINT3-6
JINT5       EQU  JINT4-6
JINT6       EQU  JINT5-6
JINT7       EQU  JINT6-6 ; 16
JTRAP0      EQU  JINT7-6
JTRAP1      EQU  JTRAP0-6
JTRAP2      EQU  JTRAP1-6
JTRAP3      EQU  JTRAP2-6
JTRAP4      EQU  JTRAP3-6
JTRAP5      EQU  JTRAP4-6
JTRAP6      EQU  JTRAP5-6
JTRAP7      EQU  JTRAP6-6
JTRAP8      EQU  JTRAP7-6
JTRAP9      EQU  JTRAP8-6
JTRAPA      EQU  JTRAP9-6
JTRAPB      EQU  JTRAPA-6
JTRAPC      EQU  JTRAPB-6
JTRAPD      EQU  JTRAPC-6
JTRAPE      EQU  JTRAPD-6
JTRAPF      EQU  JTRAPE-6
JLAST_ENTRY EQU  JTRAPF      

; jump table patching
JUMPLONG    EQU  $4EF9           ; opcode for jmp long

; Monitor's RAM area, 192 bytes
MONVARS     EQU  JLAST_ENTRY-192
OFFSET_OFF  EQU  0               ; 32 byte, for disassembler usage
FLAG        EQU  OFFSET_OFF+32   ; 2 byte, 16-bit monitor flag
BUFFER      EQU  FLAG+2          ; 80 byte
POINTER_NOW EQU  BUFFER+80       ; 4 byte
USER_DATA   EQU  POINTER_NOW+4   ; 32 byte, user D0-D7
USER_ADDR   EQU  USER_DATA+32    ; 28 byte, user A0-A6
USER_USP    EQU  USER_ADDR+28    ; 4 byte, A7 = USP
USER_SR     EQU  USER_USP+4      ; 2 byte
USER_SS     EQU  USER_SR+2       ; 4 byte
USER_PC     EQU  USER_SS+4       ; 4 byte
OFFSET      EQU  MONVARS+OFFSET_OFF

; Monitor's stack
SUPER_STACK EQU MONVARS-4	        ; top of supervisor stack, monitor worst-case stack usage is about 40-50 bytes
USER_STACK  EQU SUPER_STACK-80   ; top of user stack

; status register values
INT_ON   EQU  $2000    ; BOTH, SET SUPERVISOR MODE, S=1
INT_OFF  EQU  $2700
SUPERVISOR_BIT EQU 5
TRACE_BIT EQU 7

CR      EQU 13
LF      EQU 10
SP      EQU 32
BS      EQU 8
RS      EQU $1E
ESC     EQU $1B
BIT_ESC      EQU 0              ; ESC BIT POSITION #0

MAIN    EQU 0
UTIL    EQU 1

   SECTION MAIN
   ORG LOADADDR               
   
; ROM Exception vector table
; When running from RAM, this is just wasted space

   BRA SZERO               ; 4 bytes, if executing from RAMBASE. This is also the stack pointer value after reset
   dc.l SRESET
   dc.l JBUS_ERR, JADDR_ERR, JILLEGAL, JZERO_DIV, JCHK, JTRAPV, JPRIV_VIOL, JTRACE, JLINE_A, JLINE_F

   ORG LOADADDR+$64   
   dc.l JINT1, JINT2, JINT3, JINT4, JINT5, JINT6, JINT7
   dc.l JTRAP0, JTRAP1, JTRAP2, JTRAP3, JTRAP4, JTRAP5, JTRAP6, JTRAP7, JTRAP8, JTRAP9, JTRAPA, JTRAPB, JTRAPC, JTRAPD, JTRAPE, JTRAPF 
   ; end of exception vector table

   ORG LOADADDR+$400

SZERO:
      MOVE.W #INT_OFF,SR  ; INTERRUPT OFF, SUPERVISOR MODE SET
      MOVE.L #SUPER_STACK,SP  ; REINIT SYSTEM STACK
      LEA.L BZERO.L,A3
      BSR PSTR
      JMP START
SRESET:
      MOVE.W #INT_OFF,SR  ; INTERRUPT OFF, SUPERVISOR MODE SET
      MOVE.L #SUPER_STACK,SP  ; REINIT SYSTEM STACK
      LEA.L BRESET.L,A3
      BSR PSTR
START:
      ; turn off LEDs
      MOVEA.L #DOUT,A1
      MOVE.B #$FF,D2
      MOVE.B D2,(A1)    
      
      ; init RAM jump table entries
      MOVEA.L #JLAST_ENTRY, A1
      MOVEA.L #RAMTOP+1, A2
      
FILLJMP
      MOVE.W #JUMPLONG, (A1)+
      MOVE.L #SERVICE_DEFAULT, (A1)+
      CMPA.L A1, A2
      BNE FILLJMP
      
      MOVE.L #SERVICE_TRAP0, JTRACE+2
      MOVE.L #SERVICE_TRAP0, JTRAP0+2
      MOVE.L #SERVICE_ILLEGAL, JILLEGAL+2
      MOVE.L #SERVICE_ADDRERR, JADDR_ERR+2
      MOVE.L #SERVICE_ZERODIV, JZERO_DIV+2
      MOVE.L #SERVICE_PRIVVIOL, JPRIV_VIOL+2
      MOVE.L #SERVICE_LINEA, JLINE_A+2
      MOVE.L #SERVICE_LINEF, JLINE_F+2

      ; monitor init
      ;BSR SCROLL

      BSR CLEAR_MON_RAM

      LEA.L TITLE1.L,A3
      BSR PSTR

      ; init pointer and user PC to a safe RAM location that should be after a RAM-resident monitor
      MOVEA.L #MONVARS,A6
      MOVE.L #RAM+$4000,POINTER_NOW(A6)
      MOVE.L #RAM+$4000,USER_PC(A6)    
      
      MOVE.L #USER_STACK,USER_USP(A6) ; INIT USER STACK
      MOVE.W SR,D0
      MOVE.W D0,USER_SR(A6) 

      CLR.L FLAG(A6)         ; CLEAR SYSTEM MONITOR FLAG
      ;MOVE.W #INT_ON,SR       ; ON INTERRUPT, SUPERVISOR MODE SET

loop  BSR SEND_PROMPT
      BSR CIN
      CMP.B #$40,D0
      BLT.S NO_CHANGE

      AND.B #$DF,D0

NO_CHANGE
      CMP.B #'L',D0
      BNE NEXT1
      BSR READ_S_REC    ; load Motorola S-record
      BRA LOOP

NEXT1 CMP.B #'S',D0       
      BNE NEXT2
      BSR VIEW_USP      ; VIEW USER STACK
      BRA LOOP

NEXT2 CMP.B #'H',D0
      BNE NEXT3
      BSR HEX_DUMP      ; hex dump memory from current pointer
      BRA LOOP

NEXT3 CMP.B #'P',D0
      BNE NEXT4
      BSR NEW_POINTER   ; change current memory pointer
      BRA LOOP

NEXT4 CMP.B #'J',D0
      BNE NEXT5
      BSR JUMP          ; jump to address
      BRA LOOP

NEXT5 CMP.B #'N',D0
      BNE NEXT6
      BSR READ_BINARY   ; upload binary data
      BRA LOOP

NEXT6 CMP.B #'F',D0
      BNE NEXT7
      BSR FILL_MEMORY    ; fill memory 
      BRA LOOP

NEXT7 CMP.B #'E',D0
      BNE NEXT8
      BSR EDIT_MEMORY    ; edit memory
      BRA LOOP

NEXT8 CMP.B #'Z',D0
      BNE NEXT9
      BSR CLEAR_MEMORY   ; clear memory
      BRA LOOP

NEXT9 CMP.B #'U',D0
      BNE NEXT10
      BSR UPDATE_FLASH
      BRA LOOP

NEXT10 CMP.B #'?',D0
       BNE.S NEXT11
       BSR ABOUT         ; about and help
       ; show amount of RAM used for monitor and jump table
       LEA.L MEMUSE1.L,A3
       BSR PSTR
       MOVE.L #LOADADDR,D0
       BSR OUT6X
       MOVE.B #'-',D0
       BSR COUT
       MOVE.L #TAIL,D0
       BSR OUT6X  
       LEA.L MEMUSE2.L,A3
       BSR PSTR 
       MOVE.L #USER_STACK,D0
       BSR OUT6X     
       BSR NEW_LINE
       BSR HELP
       BRA LOOP

NEXT11 CMP.B #'R',D0
      BNE.S NEXT12
      BSR DISPLAY_REG    ; display register contents
      BRA LOOP

NEXT12 CMP.B #'.',D0
      BNE.S NEXT13
      BSR MODIFY_REG     ; modify register contents
      BRA LOOP

NEXT13 CMP.B #'D',D0
       BNE.S NEXT14
       BSR DISASSEMBLE   ; disassemble memory from current pointer
       BRA LOOP

NEXT14 ;CMP.B #'A',D0
       ;BNE.S NEXT15
       ;BSR ABOUT
       ;BRA LOOP

NEXT15 CMP.B #'T',D0
       BNE.S NEXT16
       BSR TRACE_JUMP    ; trace execution from user PC
       BRA LOOP

NEXT16 ;CMP.B #'G',D0
       ;BNE.S NEXT17
       ;JMP $102000.L       ; USE G COMMAND FOR SIMPLE JUMP TO RAM

NEXT17 CMP.B #'I',D0
       BNE.S NEXT18
       BRA BOOT_RAM      ; simulate "boot" from RAM

NEXT18  BSR NEW_LINE
      BSR SEND_TITLE     ; unrecognized command
      BRA loop


COUT      MOVE.B #$FD,DOUT	  
	  BTST.B #0,SERSTATUS_TXE
          BNE.S  COUT
          MOVE.B D0,SEROUT
          MOVE.B #$FF,DOUT
          RTS


CINS      MOVE.B #$FE,DOUT
	  BTST.B #0,SERSTATUS_RDF
          BNE.S  CINS
          MOVE.B SERIN,D0
          MOVE.B #$FF,DOUT
          RTS


CIN      MOVE.B #$FE,DOUT
	 BTST.B #0,SERSTATUS_RDF
         BNE.S  CIN
         MOVE.B SERIN,D0
         BSR COUT
         MOVE.B #$FF,DOUT
         RTS

CINREADY BTST.B #0,SERSTATUS_RDF
         RTS
         
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
        MOVEA.L #MONVARS,A6
        BSR NEW_LINE
        MOVE.L POINTER_NOW(A6),D0
        BSR OUT6X
        LEA.L PROMPT.L,A3
        BSR PSTR
        RTS

SEND_TITLE LEA.L TITLE1.L,A3
           BSR PSTR
           RTS

; S19 LOADER

; CONVERT ASCII LETTER TO 8-BIT VALUE

TO_HEX SUBI.B #$30,D0
       CMPI.B #$A,D0
       BMI  ZERO_TO_NINE
       AND.B #$DF,D0
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

UPDATE_FLASH
	 LEA.L UPDATE.L,A3
         BSR PSTR
         ; hard-code the address at RAMBASE+$1000 (RAMBASE+4K)
         MOVE.L #RAM+$1000,A4
         MOVEA.L A4,A5
         JSR READ_BINARY_XFER
         ; copy flash util to RAMBASE
         MOVE.L #FLASHUTIL_START,A0
         MOVE.L #FLASHUTIL_END,A1
         MOVE.L #RAM,A2
COPY_FLASHUTIL
         MOVE.B (A0)+,(A2)+
         CMP.L  A0,A1
         BNE COPY_FLASHUTIL
         ; set up call to flash util
         ; A0 = source buffer start address (in RAM)
	 ; A1 = source buffer end address + 1
	 ; A2 = dest buffer start address (in Flash ROM)
	 MOVE.L #RAM+$1000,A0
	 MOVE.L A4,A1
	 MOVE.L #ROMBASE,A2
	 ; run flash util
	 JMP RAM
         
READ_BINARY LEA.L LOADB.L,A3
         BSR PSTR
         LEA.L STARTA.L,A3
         BSR PSTR
         BSR GET_ADDRESS
         MOVEA.L D6,A4
         MOVEA.L D6,A5
         BSR NEW_LINE
READ_BINARY_XFER
         LEA.L LOADB1.L,A3
         BSR PSTR

WAITBIN
         BSR CINREADY
         BNE WAITBIN
         
         BSR CINS
         CMP.B #ESC,D0
         BNE GOTBIN
         RTS
GOTBIN   MOVE.B D0,(A4)+
	 BRA CHK_ACK
	 
GETBIN   MOVE.B SERIN,(A4)+
CHK_ACK  ;TSTB.L #$FF,A4
         ;BNE NOACK
         ;MOVE.B #'_',SEROUT
NOACK    ; quick test for next byte ready
         BTST.B #0,SERSTATUS_RDF
         BEQ GETBIN
         ; busy loop for next byte
         MOVE.L #20000, D1 ; reset timeout
	
WAITBIN2 
         ;BSR CINREADY
         BTST.B #0,SERSTATUS_RDF
         BEQ GETBIN
         DBF D1,WAITBIN2
         
         ; done
         BSR NEW_LINE
         MOVE.L A4,A6
         SUB.L A5,A6
         MOVE.L A6,D0
         BSR PRINT_DEC
         LEA.L NUMBER.L,A3
         BSR PSTR
         BSR NEW_LINE
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
                BNE CHECK_DATA

WAIT_CR         BSR CINS
                CMP.B #LF,D0
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


CHECK_DATA      CMP.B #'2',D0
                BEQ.S DATA_FOUND

                CMP.B #'0',D0
                BEQ.S READ_S_REC1
                BRA.S READ_S_REC1


DATA_FOUND      CLR.W D5          ; CLEAR BYTE CHECK SUM

                BSR GET_HEXS
                CLR.L D7
                MOVE.B D1,D7       ; NUMBER OF BYTE SAVED TO D7
                SUBQ.B #5,D7
                MOVE.L D7,D0

                ADD.B  D1,D5       ; ADD CHECK SUM

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

              not.b d1

              MOVE.B D1,DOUT.L  ; INDICATOR WHILE LOADING

              ADDQ.L #1,D4      ; BUMP NUMBER OF BYTE RECEIVED
              DBF D7,READ_DATA

              NOT.B D5          ; ONE'S COMPLEMENT OF BYTE CHECK SUM         

              BSR GET_HEXS      ; GET BYTE CHECK SUM

              CMP.B D1,D5       ; COMPARE CHECK SUM
              BEQ.S NO_ERROR

              ADD.L #$10000,D5  ; ADD 1 TO UPPER WORD
              MOVE.B #'X',D0    ; IF NOT EQUAL SEND "X" FOR ERROR
              BRA.S CHECKSUM_ERROR

NO_ERROR      MOVE.B #'_',D0      ; "_" NO ERROR RECORD
CHECKSUM_ERROR BSR COUT

              BRA READ_S_REC1


;LOOP_BACK     BSR CIN
;              CMP.B #13,D0
;              BNE LOOP_BACK
;              RTS



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

            MOVEA.L #MONVARS,A6
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
            BGE.S HEX_DUMP4

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

              ;BSR SEND_PROMPT

              MOVEA.L #MONVARS,A6
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

;PRINT_DEBUG   BSR NEW_LINE
;              MOVE.L DEBUG(A6),D0
;              BSR OUT8X
;              RTS

;QUICK_HOME    LEA.L QUICK.L,A3
;              BSR PSTR
;              MOVEA.L #MONVARS,A6
;              MOVE.L #RAM,POINTER_NOW(A6)
;              RTS  

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

              LEA.L STARTA.L,A3
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

              LEA.L STARTA.L,A3
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
          MOVEA.L #MONVARS,A5
          ADDA.L #BUFFER,A5
          BSR DHEX2DEC
          MOVEA.L #MONVARS,A3
          ADDA.L #BUFFER,A3
          BSR PSTR
          MOVE.L (SP)+,D0 ; RESTORE D0
          RTS

;**************************************************************************
; The portion of code within STAR lines are modified from Tutor source code
;
;
; HEX2DEC   HEX2DEC convert hex to decimal                   
; CONVERT BINARY TO DECIMAL  REG D0 PUT IN (A5) BUFFER AS ASCII

DHEX2DEC  MOVEM.L D1/D2/D3/D4/D5/D6/D7,-(SP)   ;SAVE REGISTERS
         MOVE.L  D0,D7               ;SAVE IT HERE
         BPL.S   DHX2DC
         NEG.L   D7             ;CHANGE TO POSITIVE
         BMI.S   DHX2DC57        ;SPECIAL CASE (-0)
         MOVE.B  #'-',(A5)+     ;PUT IN NEG SIGN
DHX2DC    CLR.W   D4             ;FOR ZERO SURPRESS
         MOVEQ.L   #10,D6         ;COUNTER
DHX2DC0   MOVEQ.L   #1,D2          ;VALUE TO SUB
         MOVE.L  D6,D1          ;COUNTER
         SUBQ.L  #1,D1          ;ADJUST - FORM POWER OF TEN
         BEQ.S   DHX2DC2         ;IF POWER IS ZERO
DHX2DC1   MOVE.W  D2,D3          ;D3=LOWER WORD
         MULU.W    #10,D3
         SWAP.W    D2             ;D2=UPPER WORD
         MULU.W    #10,D2
         SWAP.W    D3             ;ADD UPPER TO UPPER
         ADD.W   D3,D2
         SWAP.W    D2             ;PUT UPPER IN UPPER
         SWAP.W    D3             ;PUT LOWER IN LOWER
         MOVE.W  D3,D2          ;D2=UPPER & LOWER
         SUBQ.L  #1,D1
         BNE     DHX2DC1
DHX2DC2   CLR.L   D0             ;HOLDS SUB AMT
DHX2DC22  CMP.L   D2,D7
         BLT.S   DHX2DC3         ;IF NO MORE SUB POSSIBLE
         ADDQ.L  #1,D0          ;BUMP SUBS
         SUB.L   D2,D7          ;COUNT DOWN BY POWERS OF TEN
         BRA.S   DHX2DC22        ;DO MORE
DHX2DC3   TST.B   D0             ;ANY VALUE?
         BNE.S   DHX2DC4
         TST.W   D4             ;ZERO SURPRESS
         BEQ.S   DHX2DC5
DHX2DC4   ADDI.B  #$30,D0        ;BINARY TO ASCII
         MOVE.B  D0,(A5)+       ;PUT IN BUFFER
         MOVE.B  D0,D4          ;MARK AS NON ZERO SURPRESS
DHX2DC5   SUBQ.L  #1,D6          ;NEXT POWER
         BNE     DHX2DC0
         TST.W   D4             ;SEE IF ANYTHING PRINTED
         BNE.S   DHX2DC6
DHX2DC57  MOVE.B  #'0',(A5)+     ;PRINT AT LEST A ZERO
DHX2DC6   MOVE.B  #0,(A5)        ; PUT TERMINATOR
         MOVEM.L (SP)+,D1/D2/D3/D4/D5/D6/D7   ;RESTORE REGISTERS
         RTS                    ;END OF ROUTINE

;******************************************************************************


; DISPLAY USER REGISTERS D0-D7 AND A0-A7
;

DISPLAY_REG  LEA.L REGISTER_DISP.L,A3
             BSR PSTR

DISPLAY_REG1 MOVEA.L #MONVARS,A6
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

             MOVEA.L #MONVARS,A6

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

           MOVEA.L #MONVARS,A6
           MOVE.L USER_PC(A6),D0
           BSR OUT6X
           MOVE.B #'>',D0

           BSR COUT

           BSR GET_HEX

           BCLR.B #BIT_ESC,FLAG(A6) ; TEST BIT_ESC BIT
           BNE.S ABORT             ; IF BIT = 1 THEN EXIT

           BCLR.B #1,FLAG(A6)  ; CHECK IF ENTER KEY PRESSED
           BNE.S JUMP1         ; RUN USER PROGRAM

           CLR.L D6
           BSR GET_ADDRESS1

; GOT D6 FOR DESTINATION

           MOVE.L D6,USER_PC(A6)  ; SAVE TO USER PC
           BRA.S JUMP1

ABORT      RTS                 ; GET BACK MONITOR

JUMP1      MOVEA.L #MONVARS,A6     ; POINTED TO START MONITOR RAM

           MOVEA.L USER_USP(A6),A0
           MOVE.L  A0,USP           ; WRITE TO REAL USER STACK (A7)

           MOVE.L  USER_PC(A6),-(SP)     ; PUSH PC

           ;BCLR.B   #5,USER_SR(A6) ; SET USER MODE     

           MOVE.W  USER_SR(A6),-(SP)
           MOVEM.L USER_DATA(A6),D0/D1/D2/D3/D4/D5/D6/D7/A0/A1/A2/A3/A4/A5/A6
           RTE                     ; JUMP TO USER PROGRAM


; TRACE JUMP
; SET TRACE BIT IN SAVED STATUS REGISTER

TRACE_JUMP LEA.L TRACE_MSG.L,A3
           BSR PSTR
           BSR NEW_LINE

           MOVEA.L #MONVARS,A6
           MOVEA.L USER_PC(A6),A4
           MOVEM.L (A4),D0/D1/D2
           MOVEA.L #MONVARS,A5
           ADDA.L #BUFFER,A5      ; LOAD A5 WITH $130000+BUFFER

           JSR  DCODE68K.L


           BSR NEW_LINE
           BSR PRINT_LINE

           MOVEA.L #MONVARS,A6

           BSET.B #TRACE_BIT,USER_SR(A6)  ; SET TRACE BIT
           BRA JUMP1                    ; BORROW JUMP ROUTINE

; CLEAR MONITOR RAM

CLEAR_MON_RAM MOVEA.L #MONVARS,A6
              MOVE.W  #119,D7          ; 240 bytes of monitor RAM, divide by 2 and subtract 1

CLEAR1        MOVE.W #0000,(A6)+
              DBRA D7,CLEAR1
              RTS



; MODIFY USER REGISTERS

MODIFY_REG    MOVEA.L #MONVARS,A6
              BSR CIN
              AND.B #$DF,D0
              CMPI.B #'P',D0
              BNE.S DATA_REGP

              MOVE.B #'C',D0
              BSR COUT
              MOVE.B #'=',D0
              BSR COUT
              BSR GET_ADDRESS

              MOVE.L D6,USER_PC(A6)
              RTS

DATA_REGP     CMPI.B #'D',D0
              BNE.S ADDRESS_REGP
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
              
ADDRESS_REGP  CMPI.B #'A',D0
              BNE.S WHATP
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

WHATP         RTS

;=======================================================================
; TRAP #N SERVICES
;

SERVICE_TRAP0   MOVE.L A0,-(SP)      ; SAVE A0 BEFOREHAND
                MOVEA.L #MONVARS,A0  ; USE A0 AS THE POINTER
                LEA.L USER_DATA(A0),A0
                MOVEM.L D0/D1/D2/D3/D4/D5/D6/D7/A0/A1/A2/A3/A4/A5/A6,(A0)
                MOVE.L (SP)+,32(A0)  ; RESTORE A0

                MOVEA.L #MONVARS,A0
                MOVE.W (SP)+,USER_SR(A0)
                BCLR.B #TRACE_BIT,USER_SR(A0) ; TURN TRACE BIT OFF
                MOVE.L (SP)+,USER_PC(A0)

                MOVE.L USP,A2
                MOVE.L A2,USER_USP(A0)

                BSR DISPLAY_REG1

                MOVE.L #SUPER_STACK,SP  ; REINIT SYSTEM STACK
                ;MOVE.W #INT_ON,SR   ; REENTER SUPERVISOR MODE

                JMP LOOP.L        ; GET BACK MONITOR


; DISASSEMBLE THE MACHNIE CODE INTO MNEMONIC

DISASSEMBLE     LEA.L DIS.L,A3
                BSR PSTR

           ;   LEA.L $102000.L,A4

               MOVEA.L #MONVARS,A6

               MOVE.W #19,D7       ; 20 LINES DISASSEMBLE

               MOVEA.L POINTER_NOW(A6),A4

DIS1           MOVEM.L (A4),D0/D1/D2
               MOVEA.L #MONVARS,A5
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

;UPLOAD        LEA.L UPLOAD1.L,A3
;              BSR PSTR
;              BSR CIN
;
;              LEA.L RAM,A5    ; START
;              LEA.L $102000.L,A6    ; STOP
;
;UPLOAD3       BSR NEW_LINE
;              LEA.L STRING1.L,A3
;              BSR PSTR
;
;              MOVE.W #7,D7
;
;UPLOAD2       MOVE.B #'$',D0
;              BSR COUT
;              MOVE.L (A5)+,D0
;              BSR OUT8X
;              MOVE.B #',',D0
;              BSR COUT
;              DBRA D7,UPLOAD2
;
;              CMPA.L A5,A6
;              BGT  UPLOAD3
;
;              RTS

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
              MOVEA.L #MONVARS,A6


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

SERVICE_ILLEGAL MOVEA.L #ILLEGAL_MSG.L,A3
                BSR PSTR
                TRAP #0

SERVICE_ADDRERR MOVEA.L #ADDRERR_MSG.L,A3
                BSR PSTR
                TRAP #0

SERVICE_ZERODIV MOVEA.L #ZERODIV_MSG.L,A3
                BSR PSTR
                TRAP #0

SERVICE_PRIVVIOL MOVEA.L #PRIVVIOL_MSG.L,A3
                BSR PSTR
                TRAP #0

SERVICE_LINEA MOVEA.L #LINEA_MSG.L,A3
                BSR PSTR
                TRAP #0

SERVICE_LINEF MOVEA.L #LINEF_MSG.L,A3
                BSR PSTR
                TRAP #0

; Default handler for jump table entries that aren't set
SERVICE_DEFAULT MOVEA.L #DEFAULT_MSG.L,A3
                BSR PSTR
                TRAP #0

; DCODE68K
  INCLUDE "DIS.ASM"
   
FLASHUTIL_START
  ;SECTION UTIL
  ;INCLUDE "FLASH-UTIL.ASM"
  INCBIN "FLASH-UTIL.BIN"
  ;SECTION MAIN
FLASHUTIL_END

;----------------------- STRING CONSTANTS -------------------------------------
  IFEQ LOADADDR
TITLE1 dc.b 13,10,'zBug(ROM) for 68Katy (press ? for help)',13,10,0
  ENDC
  IFNE LOADADDR,0
TITLE1 dc.b 13,10,'zBug(RAM) for 68Katy (press ? for help)',13,10,0
  ENDC

BRESET dc.b 'Boot from RESET vector',13,10,0
BZERO dc.b 'Jump to 0',13,10,0

PROMPT dc.b '>',0

CLEAR  dc.b 'lear memory with 0x0000',0
FILL   dc.b 'ill memory with 0xFFFF',0 
STARTA dc.b 13,10,10,'start address=',0
STOP   dc.b 13,10,'stop  address=',0
DONE   dc.b 13,10,'done...',0

EDIT1  dc.b 'dit memory (quit: SPACE BAR, next address: ENTER)',0
EDIT   dc.b 13,10,10,'Address=',0
ROM    dc.b '  rom',0

NEW    dc.b 'ointer=',0

UPDATE dc.b 'pdate Flash ROM (max size 480K)',13,10,0

HEX    dc.b 'ex dump memory',13,10,10
       dc.b 'ADDRESS  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F',0

LOAD   dc.b 'oad Motorola S-record. Accepts S2 and S8. (cancel: ESC)',13,10,0

LOADB  dc.b ' Load binary data',13,10,0
LOADB1 dc.b 'Ready to receive. Terminates after inactivity. (cancel: ESC)', 13,10,0

NUMBER dc.b ' bytes loaded, ',0
ERROR  dc.b ' errors',13,10,0

JUMP_TO dc.b 'ump to address ',0 

REGISTER_DISP dc.b 'egister display (A7 = user stack pointer)',0

DIS    dc.b 'isassemble machine code',13,10,0

;UPLOAD1 dc.b 'pload binary image, hit any key to begin ',0
;STRING1 dc.b '  dc.l ',0

  IFEQ LOADADDR
ABOUTZBUG dc.b 13,10,'zBug(ROM) for 68Katy 20150113 by W. Sirichote, S. Chamberlin',13,10,0
  ENDC
  IFNE LOADADDR,0
ABOUTZBUG dc.b 13,10,'zBug(RAM) for 68Katy 20150113 by W. Sirichote, S. Chamberlin',13,10,0
  ENDC

MEMUSE1 dc.b 'Using code from ',0
MEMUSE2 dc.b ', data above ',0

TRACE_MSG dc.b 'race instruction',0

VIEW      dc.b 'tack display, shows 16-word deep',13,10,0

ILLEGAL_MSG dc.b 13,10,'Illegal instruction!',0
DEFAULT_MSG dc.b 13,10,'Exception has no handler!', 0
ADDRERR_MSG dc.b 13,10,'Address error!', 0
ZERODIV_MSG dc.b 13,10,'Division by zero!', 0
PRIVVIOL_MSG dc.b 13,10,'Privilege violation!', 0
LINEA_MSG dc.b 13,10,'Line A emulator!', 0
LINEF_MSG dc.b 13,10,'Line F emulator!', 0

TOP_OF_STACK dc.b 'TOS--->',0
BLANK_BLOCK  dc.b '       ',0

PC_REG dc.b 'PC=',0
SR_REG dc.b 'SR=',0

CARRY_FLAG dc.b 'C=',0
V_FLAG     dc.b 'V=',0
Z_FLAG     dc.b 'Z=',0
N_FLAG     dc.b 'N=',0
X_FLAG     dc.b 'X=',0


HELP_LIST dc.b 'Monitor commands',13,10,10
       dc.b 'D   Disassemble machine code at current pointer',13,10
       dc.b 'E   Edit memory',13,10
       dc.b 'F   Fill memory with 0xFFFF',13,10
       dc.b 'H   Hex dump memory from current pointer',13,10
       dc.b 'I   Init from RAM [$80000] -> SP [$80004] -> PC',13,10
       dc.b 'J   Jump to address',13,10
       dc.b 'L   Load Motorola S-record',13,10
       dc.b 'N   Load binary data',13,10
       dc.b 'P   Set current pointer',13,10
       dc.b 'R   Register display',13,10
       dc.b 'S   Stack display',13,10
       dc.b 'T   Trace instruction at PC',13,10
       dc.b 'U   Update Flash ROM',13,10
       dc.b 'Z   Clear memory with 0x0000',13,10
       dc.b '.   Modify registers, as .PC .D0 .A0',13,10
       dc.b '?   Help',13,10,0
TAIL
       END START




