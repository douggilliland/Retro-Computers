;	Title:		Generate CRC16
;	Name:		ICRC16, CRC16, GCRC16 
;	Purpose:	Generate a 16 bit CRC based on IBM's Binary
;			Synchronous Communications protocol.
;
;			The CRC is based on the following polynomial:
;			(^ indicates "to the power")
;
;				X^16 + x^15 + x^2 + 1
;
;			To generate a CRC:
;
;			1) Call ICRC16 to initialize the CRC
;				polynomial and clear the CRC.
;			2) Call CRC16 for each data byte.
;			3) Call GCRC16 to obtain the CRC.
;				It should then be appended to the data,
;				high byte first.
;
;			To check a CRC:
;
;			1) Call ICRC16 to initialize the CRC.
;			2) Call CRC16 for each data byte 
;				and the 2 bytes of CRC previously generated.
;			3) Call GCRC16 to obtain the CRC.
;				It will be zero if no errors occurred.
;
;	Entry:		ICRC16		None
;			CRC16		Register A = Data byte
;			GCRC16		None
;
;	Exit:		ICRC16		CRC, PLY initialized
;			CRC16		CRC updated
;			GCRC16		Register D = CRC
;
;	Registers Used:
;			ICRC16		CC,X
;			CRC16		None
;			GCRC16		CC,D
;	Time:
;			ICRC16		23 cycles
;
;			CRC16		490 cycles overhead plus an average 
;					of 34 cycles per data byte.
;					The loop timing assumes that 
;					half the iterations require
;					EXCLUSIVE-0Ring the CRC and the polynomial.
;
;			GCRC16		11 cycles
;	Size:
;			Program		59 bytes
;			Data		4 bytes plus 7 stack bytes for CRC16
;




CRC16:
	;
	; SAVE ALL REGISTERS
	;
	PSHS	CC,D,X,Y	; SAVE ALL REGISTERS
	;
	; LOOP THROUGH EACH DATA BIT, GENERATING THE CRC
	;
	LDB	#8		; 8 BITS PER BYTE
	LDX	#PLY		; POINT TO POLYNOMIAL
	LDY	#CRC		; POINT TO CRC VALUE
CRCLP:
	PSHS	D		; SAVE DATA, BIT COUNT
	ANDA	#10000000b	; GET BIT 7 OF DATA
	EORA	,Y		; EXCLUSIVE-OR BIT 7 WITH BIT 15 OF CRC
	STA	,Y
	ASL	1,Y		; SHIFT CRC LEFT
	ROL	,Y
	BCC	CRCLP1		; BRANCH IF BIT 7 OF EXCLUSIVE-OR IS D
	;
	; BIT 7 IS 1, SO EXCLUSIVE-OR CRC WITH POLYNOMIAL
	;
	LDD	,X		; GET POLYNOMIAL
	EORA	,Y		; EXCLUSIVE-OR WITH HIGH BYTE OF CRC
	EORB	1,Y		; EXCLUSIVE-OR WITH LOW  BYTE OF CRC
	STD	,Y		; SAVE NEW CRC VALUE
	;
	; SHIFT DATA LEFT AND COUNT BITS
	;
CRCLP1:
	PULS	D		; GET DATA, BIT COUNT
	ASLA			; SHIFT DATA LEFT
	DECB			; DECREMENT BIT COUNT
	BNE	CRCLP		; JUMP IF NOT THROUGH 8 BITS
	;
	; RESTORE REGISTERS AND EXIT
	;
	PULS	CC,D,X,Y	; RESTORE ALL REGISTERS
	RTS

	; ****************************************
	; ROUTINE:		ICRC16
	; PURPOSE:		INITIALIZE CRC AND PLY
	; ENTRY:		NONE
	; EXIT:			CRC AND PULYNOMIAL INITIALIZED
	; REGISTERS USED:	X
	; ******************************************
ICRC16:
	LDX	#0		; CRC = 0
	STX	CRC
	LDX	#$8005		; PLY = 8005
	STX	PLY
	;
	; 8005 HEX REPRESENTS X^16 + x^15 + x^2 + 1
	; THERE IS A 1 IN EACH BIT
	; POSITION FOR WHICH A POWER APPEARS
	; IN THE FORMULA (BITS 0, 2, AND 15)
	RTS
	;
	; ******************************************
	; ROUTINE:		GCRC16
	; PURPOSE:		GET CRC VALUE
	; ENTRY:		NONE
	; EXIT:			REGISTER D = CRC VALUE
	; REGISTERS USED:	D
	; *******************************************
GCRC16:	
	LDD	CRC		; D = CRC
	RTS
;
; DATA
;
CRC:	RMB	2		; CRC VALUE
PLY:	RMB	2		; POLYNOMIAL VALUE
;
; SAMPLE EXECUTION:
;
;
; GENERATE CRC FOR THE NUMBER 1 AND CHECK IT
;
SC8D:
	JSR	ICRC16		; INITIALIZE CRC, POLYNOMIAL
	LDA	#1		; GENERATE CRC FOR 1
	JSR	CRC16
	JSR	GCRC16
	JSR	ICRC16		; INITIALIZE AGAIN
	LDA	#1
	JSR	CRC16		; CHECK CRC BY GENERATING IT FOR DATA
	TFR	Y,D		; AND STORED CRC ALSO
	JSR	CRC16		; HIGH BYTE OF CRC FIRST
	TFR	B,A		; THEN LOW BYTE OF CRC
	JSR	CRC16
	JSR	GCRC16		; CRC SHOULD BE ZERO IN D
;
; GENERATE CRC FOR THE SEQUENCE 0,1,2,...,255 AND CHECK IT
;
	JSR	ICRC16		; INITIALIZE CRC, POLYNOMIAL
	CLRB			; START DATA BYTES AT 0
GENLP:
	JSR	CRC16		; UPDATE CRC
	INCB			; ADD 1 TO PRODUCE NEXT DATA BYTE
	BNE	GENLP		; BRANCH IF NOT DONE
	JSR	GCRC16		; GET RESULTING CRC
	TFR	D,Y		; SAVE CRC IN Y
;
; CHECK CRC BY GENERATING IT AGAIN
;
	JSR	ICRC16		; INITIALIZE CRC, POLYNOMIAL
	CLRB			; START DATA BYTES AT 0
CHKLP:
	JSR	CRC16		; UPDATE CRC
	INCB			; ADD 1 TO PRODUCE NEXT DATA BYTE
	BNE	CHKLP		; BRANCH IF NOT DONE
				;
				; INCLUDE STORED CRC IN CHECK
				;
	TFR	Y,D		; GET OLD CRC VALUE
	JSR	CRC16		; INCLUDE HIGH BYTE OF CRC
	TFR	B,A		; INCLUDE LOW BYTE OF CRC
	JSR	CRC16
	JSR	GCRC16		; GET RESULTING CRC
				; IT SHOULD BE 0
	BRA	SC8D		; REPEAT TEST

	END

