*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
ROM	    EQU $0
ROMTOP      EQU $77FFF
SERIN       EQU $78000
SEROUT      EQU $7A000
SERSTATUS_RDF   EQU $7C000
SERSTATUS_TXE   EQU $7D000
DOUT        EQU $7E000
RAM         EQU $80000
RAMTOP      EQU $FFFFF

; serial communication
CR      EQU 13
LF      EQU 10

	ORG	RAM 
START:				
	;MOVE.W	#$2700,SR	; interrupts off	
	MOVE.L  #RAMTOP+1,SP
	
	LEA.L WELCOME.L,A4 
	BSR PSTR
	
	; check manufacturer ID
	LEA.L MANU_ID.L,A4 
	BSR PSTR
	JSR FLASH_GET_MANUFACTURER_ID
	JSR OUT2X
	JSR NEW_LINE
	
	MOVE.B #$01,D1
	CMP.B D1,D0
	BEQ N1
	LEA.L ID_ERROR.L,A4
	JSR PSTR
	MOVE.B D1,D0
	JSR OUT2X
	JSR NEW_LINE 
	JMP DIE
	
	; check device ID
N1:	LEA.L DEV_ID.L,A4 
	BSR PSTR
	JSR FLASH_GET_DEVICE_ID
	JSR OUT2X
	JSR NEW_LINE

	MOVE.B #$A4,D1
	CMP.B D1,D0
	BEQ N2
	LEA.L ID_ERROR.L,A4
	JSR PSTR
	MOVE.B D1,D0
	JSR OUT2X
	JSR NEW_LINE 
	JMP DIE

N2:
	; these should already be set up by the caller
	; A0 = source buffer start address (in RAM)
	; A1 = source buffer end address + 1
	; A2 = dest buffer start address (in Flash ROM)	
	JSR FLASH_ERASE_CHIP
	JSR FLASH_PROGRAM
	LEA.L REBOOTING.L,A4 
	BSR PSTR
	JMP DIE

FLASH_GET_MANUFACTURER_ID:
	MOVE.B #$AA,ROM+$555
	MOVE.B #$55,ROM+$2AA
   	MOVE.B #$90,ROM+$555
   	MOVE.B ROM+$0, D0
   	JSR FLASH_RESET
   	RTS
   
FLASH_GET_DEVICE_ID:
	MOVE.B #$AA,ROM+$555
	MOVE.B #$55,ROM+$2AA
   	MOVE.B #$90,ROM+$555
   	MOVE.B ROM+$001,D0
   	JSR FLASH_RESET
   	RTS
	
FLASH_RESET:
	MOVE.B #$F0,ROM
	RTS
	
FLASH_ERASE_CHIP:
	LEA.L ERASING_CHIP.L,A4
	JSR PSTR
	MOVE.B #$AA,ROM+$555
	MOVE.B #$55,ROM+$2AA
   	MOVE.B #$80,ROM+$555
	MOVE.B #$AA,ROM+$555
	MOVE.B #$55,ROM+$2AA
	MOVE.B #$10,ROM+$555
	MOVE.L #ROM,A4
	BRA FLASH_ERASE_WAIT

	; wait until it's done. DQ7 will go to 1.
FLASH_ERASE_WAIT:	
	BTST.B #7,(A4)
	BEQ FLASH_ERASE_WAIT
	
	LEA.L DONE.L,A4
	JSR PSTR
	RTS
	
; A0 = source buffer start address (in RAM)
; A1 = source buffer end address + 1
; A2 = dest buffer start address (in Flash ROM)
FLASH_PROGRAM:
	LEA.L PROGRAMMING_CHIP.L,A4
	JSR PSTR
	MOVE.B #'.',D3
FLASH_PROGRAM_NEXT_BYTE:
	MOVE.B #$AA,ROM+$555
	MOVE.B #$55,ROM+$2AA
   	MOVE.B #$A0,ROM+$555
   	MOVE.B (A0)+,(A2)+
FLASH_PROGRAM_WAIT
	; while programming is in progress, successive reads to the same address will see DQ6 toggle
	MOVE.B ROM,D0
	CMP.B  ROM,D0
	BNE FLASH_PROGRAM_WAIT
	; ack every 256 bytes
	ADDQ.B #1,D4
	BEQ ACK
NO_ACK
	; finished?
   	CMP.L  A0,A1
   	BNE FLASH_PROGRAM_NEXT_BYTE
   	LEA.L DONE.L,A4
	JSR PSTR
	RTS

ACK
	MOVE.B D3,SEROUT
	BRA NO_ACK
	
DIE
     	  MOVE.L $4,A0
          JMP (A0)

COUT      MOVE.B #$FD,DOUT	  
	  BTST.B #0,SERSTATUS_TXE
          BNE.S  COUT
          MOVE.B D0,SEROUT
          MOVE.B #$FF,DOUT
          RTS
         
NEW_LINE MOVE.L D0,-(SP)
         MOVE.B #CR,D0
         BSR COUT
         MOVE.B #LF,D0
         BSR COUT
         MOVE.L (SP)+,D0
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
              
; A4 POINTED TO FIRST BYTE
; END WITH 0

PSTR     MOVE.B (A4)+,D3
         CMP.B  #0,D3
         BEQ.S PSTR1
         MOVE.B D3,SEROUT
         BRA.S PSTR

PSTR1    RTS
 
* Variables and Strings

WELCOME dc.b 'Checking Flash ROM ID...',13, 10, 0
MANU_ID dc.b 'Manufacturer ID: ', 0
DEV_ID  dc.b 'Device ID: ', 0
ID_ERROR dc.b 'ABORT - ID does not match expected value ', 0
DONE    dc.b 'done.', 13, 10, 0
ERASING_CHIP dc.b 'Erasing Flash ROM chip...', 0
PROGRAMMING_CHIP dc.b 'Programming Flash ROM chip...', 0
REBOOTING dc.b 'Rebooting...', 13, 10, 0

	END	START		; last line of source