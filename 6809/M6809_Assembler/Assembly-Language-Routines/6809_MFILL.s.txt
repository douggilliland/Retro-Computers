;
;	Title:			Memory Fill
;	Name:			MFILL
;
;	Purpose:		Fills an area of memory with a value
; 
;	Entry:			TOP OF STACK
;				 High byte of return address 
;				 Low byte of return address 
;				 Value to be placed in memory 
;				 High byte of area size in bytes 
;				 Low byte of area size in bytes 
;				 High byte of base address
;				 Low byte of base address
;
;	Exit:			Area filled with value
;
;	Registers Used:		A,CC,U,X
;
;	Time:			14 cycles per byte plus 38 cycles overhead 
; 
;	Size:			Program 18 bytes
;
;	OBTAIN PARAMETERS FROM STACK
;
MFILL:
	PULS	Y			; SAVE RETURN ADDRESS IN Y
	PULS	A			; GET BYTE TO FILL WITH
	LDX	2,S			; GET BASE ADDRESS
	STY	2,S			; PUT RETURN ADDRESS BACK IN STACK 
	PULS	Y			; GET AREA SIZE
;
;	FILL MEMORY ONE BYTE AT A TIME
; 
FILLB:
	STA	,X+			; FILL ONE BYTE WITH VALUE 
	LEAY	-1,Y			; DECREMENT BYTE COUNTER 
	BNE	FILLB			; CONTINUE UNTIL COUNTER = O
	RTS
;
;	SAMPLE EXECUTION
; 
SC2A:
; 
;	FILL BF1 THROUGH BF1+15 WITH 00
;
	LDY	#BF1			; BASE ADDRESS
	LDX	#SIZE1			; NUMBER OF BYTES
	LDA	#0			; VALUE TO FILL WITH
	PSHS	A,X,Y			; PUSH PARAMETERS
	JSR	MFILL			; FILL MEMORY
;
;	FILL BF2 THROUGH BF2+1999 WITH 12 HEX (NOP'S OPCODE)
;
	LDY	#BF2			; BASE ADDRESS
	LDX	#SIZE2			; NUMBER OF BYTES
	LDA	#$12			; VALUE TO FILL WITH
	PSHS	A,X,Y			; PUSH PARAMETERS
	JSR	MFILL			; FILL MEMORY
;
SIZE1	EQU	16			; SIZE OF BUFFER 1 (10 HEX) 
SIZE2	EQU	2000			; SIZE OF BUFFER 2 (07D0 HEX)
BF1:	RMB	SIZE1			; BUFFER 1
BF2:	RMB	SIZE2			; BUFFER 2
	END

