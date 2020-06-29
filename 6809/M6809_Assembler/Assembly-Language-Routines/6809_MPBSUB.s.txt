	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#1
	.endm

; Title:		Multiple-Precision Binary Subtraction
;
; Name:			MPBSUB
;
; Purpose:		Subtract 2 arrays of binary bytes
;			Minuend := Minuend - Subtrahend
;
; Entry:		TOP OF STACK
;			High byte of return address
;			Low  byte of return address
;			Length of the arrays in bytes
;			High byte of subtrahend address
;			Low  byte of subtrahend address
;			High byte of minuend address
;			Low  byte of minuend address
;
;			The arrays are unsigned binary numbers
;			with a maximum length of 255 bytes,
;			ARRAY[0]	is the least significant byte, and
;			ARRAY[LENGTH-1]	is the most significant byte.
;
; Exit:			Minuend := Minuend - Subtrahend
;
; Registers Used:	A,B,CC,U,X
;
; Time:			21 cycles per byte plus 36 cycles overhead
; 
;
; Size:			Program 25 bytes
;

MPBSUB:
	;
	; CHECK IF LENGTH OF ARRAYS IS ZERO
	; EXIT WITH CARRY CLEARED IF IT IS
	;
	CLC			; CLEAR CARRY TO START
	LDB	2,S		; CHECK LENGTH OF ARRAYS
	BEQ	SBEXIT		; BRANCH (EXIT) IF LENGTH IS ZERO
				; SUBTRACT ARRAYS ONE BYTE AT A TIME
	LDX	3,S		; GET BASE ADDRESS OF SUBTRAHEND
	LDU	5,S		; GET BASE ADDRESS OF MINUEND
SUBBYT:
	LDA	,U		; GET BYTE OF MINUEND
	SBCA	,X+		; SUBTRACT BYTE OF SUBTRAHEND WITH BORROW
	STA	,U+		; SAVE DIFFERENCE IN MINUEND
	DECB
	BNE	SUBBYT		; CONTINUE UNTIL ALL BYTES SUBTRACTED
	;
	; REMOVE PARAMETERS FROM STACK AND EXIT
	;
SBEXIT:
	LDX	,S		; SAVE RETURN ADDRESS
	LEAS	7,S		; REMOVE PARAMETERS FROM STACK
	JMP	,X		; EXIT TO RETURN ADDRESS
;
;
; SAMPLE EXECUTION
;
;
	LDY	AY1ADR		; GET BASE ADDRESS OF MINUEND
	LDX	AY2ADR		; GET BASE ADDRESS OF SUBTRAHEND
	LDA	#SZAYS		; GET LENGTH OF ARRAYS IN BYTES
	PSHS	A,X,Y		; SAVE PARAMETERS IN STACK
	JSR	MPBSUB		; MULTIPLE-PRECISION BINARY SUBTRACTION
				; RESULT OF 2F3E4D5CH - 175E809FH
				; = 17DFCCBDH
				; IN MEMORY
				;	AY1	= BDH
				;	AY1+1	= CCH
				;	AY1+2	= DFH
				;	AY1+3	= 17H
				;	AY1+4	= 00H
				;	AY1+5	= 00H
				;	AY1+6	= 00H
;
; DATA
;
SZAYS	EQU	7		; LENGTH OF ARRAYS IN BYTES
AY1ADR	FDB	AY1		; BASE ADDRESS OF ARRAY 1
AY2ADR	FDB	AY2		; BASE ADDRESS OF ARRAY 2

AY1:	FCB	$5C,$4D,$3E,$2F,0,0,0
AY2:	FCB	$9F,$80,$5E,$17,0,0,0

	END




