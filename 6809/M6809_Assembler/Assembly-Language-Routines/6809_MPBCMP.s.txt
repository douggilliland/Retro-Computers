	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#1
	.endm

;	Title:		Multiple-precision Binary Comparison
;
;	Name:		MPBCMP
;
;	Purpose:	Compare 2 arrays of binary bytes and
;			return the Carry and Zero flags set or cleared
;
;	Entry:
;

;			TOP OF STACK 
;			High byte of return address
;			Low  byte of return address 
;			Length of operands in bytes 
;			High byte of subtrahend address
;			Low  byte of subtrahend address 
;			High byte of minuend address
;			Low  byte of minuend address
;
;			The arrays are unsigned binary numbers
;			with a maximum length of 255 bytes, 
;			ARRAY[0] is the least significant byte, and 
;			ARRAY[LENGTH-1] is the most significant byte.
;
;			IF minuend = subtrahend THEN
;				 C=0, Z=1
;			IF minuend > subtrahend THEN
;				 C=0, Z=0
;			IF minuend < subtrahend THEN
;				 C=1, Z=0
;			IF array Length = 0 THEN
;				 C=1, Z=1
;
;	Exit:
;
;	Registers Used:	All
;
;	Time:		20 cycles per byte that must be examined
;			plus 47 cycles overhead
;
;	Size:		Program	30 bytes
;
;	CHECK IF LENGTH OF ARRAYS IS ZERO
;	EXIT WITH SPECIAL FLAG SETTING (C=1, Z=1) IF IT IS

MPBCMP:
	LDU	,S		; SAVE RETURN ADDRESS
	SEC			; SET CARRY IN CASE LENGTH IS 0
	LDB	2,S		; GET LENGTH OF ARRAYS IN BYTES
	BEQ	EXITCP		; BRANCH (EXIT) IF LENGTH IS ZERO
				; C=1, Z=1 IN THIS CASE
;
;	COMPARE ARRAYS BYTE AT A TIME UNTIL UNEQUAL BYTES ARE FOUND OR ALL
;	BYTES COMPARED
;
	LDX	5,S		; GET BASE ADDRESS OF MINUEND
	LDY	3,S		; GET BASE ADDRESS OF SUBTRAHEND
	LEAX	B,X		; DETERMINE ENDING ADDRESS OF MINUEND
	LEAY	B,Y		; DETERMINE ENDING ADDRESS oF SUBTRAHEND
CMPBYT:
	LDA	,-X		; GET BYTE FROM MINUEND
	CMPA	,-Y		; COMPARE TO BYTE FROM SUBTRAHEND
	BNE	EXITCP		; BRANCH (EXIT) IF BYTES ARE NOT EQUAL
	DECB	
	BNE	CMPBYT		; CONTINUE UNTIL ALL BYTES COMPARED
				; IF PROGRAM FALLS THROUGH, THEN THE
				; ARRAYS ARE IDENTICAL AND THE FLAGS ARE
				; SET PROPERLY (C=0,Z=1)
;
; REMOVE PARAMETERS FROM STACK AND EXIT
; BE CAREFUL NOT TO AFFECT FLAGS (PARTICULARLY ZERO FLAG)
;
EXITCP:
	LEAS	7,S		; REMOVE PARAMETERS FROM STACK
	JMP	,U		; EXIT TO RETURN ADDRESS
;
;
; SAMPLE EXECUTION
;
;
SC3G:
	LDX	AY1ADR		; GET BASE ADDRESS OF MINUEND
	LDY	AY2ADR		; GET BASE ADDRESS OF SUBTRAHEND
	LDA	#SZAYS		; GET LENGTH OF ARRAYS IN BYTES
	PSHS	A,X,Y		; SAVE PARAMETERS IN STACK
	JSR	MPBCMP		; MULTIPLE-PRECISION BINARY COMPARISON
				; RESULT OF COMPARE (2F3E4D5CH - 175E809FH
				; IS C=0, Z=0
;
; DATA
;
SZAYS	EQU	7		; LENGTH OF OPERANDS IN BYTES
AY1ADR	FDB	AY1		; BASE ADDRESS OF ARRAY 1
AY2ADR	FDB	AY2		; BASE ADDRESS OF ARRAY 2

AY1:	FCB	$5C,$4D,$3E,$2F,0,0,0
AY2:	FCB	$9F,$80,$5E,$17,0,0,0

	END

