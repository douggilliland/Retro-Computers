	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#1
	.endm
; Title:		Multiple-Precision Decimal Addition
; Name:			MPDADD
;
; Purpose:		Add 2 arrays of BCD bytes
;			Array1 := Array 1 + Array 2 
;
; Entry:
;			TOP OF STACK
;
;			High byte of return address 
;			Low  byte of return address
;			Length of the arrays in bytes
;			High byte of array 2 address
;			Low  byte of array 2 address
;			High byte of array 1 address
;			Low  byte of array 1 address
;
;			The arrays are unsigned BCD numbers
;			The arrays are unsigned binary numbers
;			with a maximum length of 255 bytes,
;			ARRAY[0] is the least significant
;			byte, and ARRAY[LENGTH-1] is the
;			most significant byte.
;
; Exit:			Array1 := Array1 + Array2
;
; Registers Used:	A,B,CC,U,X
;
; Time:			23 cycles per byte plus 36 cycles overhead
;
; Size:			Program 26 bytes
;
MPDADD:
	;
	; CHECK IF LENGTH OF ARRAYS IS ZERO
	; EXIT WITH CARRY CLEARED IF IT IS
	;
	CLC			; CLEAR CARRY TO START
	LDB	2,S		; CHECK LENGTH OF ARRAYS
	BEQ	ADEXIT		; BRANCH (EXIT) IF LENGTH IS ZERO
	;
	; ADD ARRAYS 2 DIGITS AT A TIME
	;
	LDX	5,S		; GET BASE ADDRESS OF ARRAY 1
	LDU	3,S		; GET BASE ADDRESS OF ARRAY 2
ADDBYT:
	LDA	,U+		; GET 2 DIGITS FROM ARRAY 2
	ADCA	,X		; ADD 2 DIGITS FROM ARRAY 1 WITH CARRY
	DAA			; MAKE ADDITION DECIMAL
	STA	,X+		; SAVE SUM IN ARRAY 1
	DECB
	BNE	ADDBYT		; CONTINUE UNTIL ALL BYTES SUMMED
	;
	; REMOVE PARAMETERS FROM STACK AND EXIT
	;
ADEXIT:
	LDX	,S		; SAVE RETURN ADDRESS
	LEAS	7,S		; REMOVE PARAMETERS FRDM STACK
	JMP	,X		; EXIT TO RETURN ADDRESS
;
;
; SAMPLE EXECUTION
;
;
SC3H:
	LDY	AY1ADR		; GET FIRST OPERAND
	LDX	AY2ADR		; GET SECOND OPERAND
	LDA	#SZAYS		; LENGTH OF ARRAYS IN BYTES
	PSHS	A,X,Y		; SAVE PARAMETERS IN STACK
	JSR	MPDADD		; MULTIPLE-PRECISION BCD ADDITION
				; RESULT OF 12345678H + 35914028H
				; = 48259706H
				; IN MEMORY
				;	AY1	= 06H
				;	AY1+1	= 97H
				;	AY1+2	= 25H
				;	AY1+3	= 48H
				;	AY1+4	= 00H
				;	AY1+5	= 00H
				;	AY1+6	= 00H
;
; DATA
;
SZAYS	EQU	7		; LENGTH OF ARRAYS IN BYTES
AY1ADR	FDB	AY1		; BASE ADDRESS OF ARRAY 1
AY2ADR	FDB	AY2		; BASE ADDRESS OF ARRAY 2

AY1:	FCB	$78,$56,$34,$12,0,0,0
AY2:	FCB	$28,$40,$91,$35,0,0,0

	END

