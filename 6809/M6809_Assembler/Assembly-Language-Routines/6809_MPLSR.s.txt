	.macro	CLC
		ANDCC	#$FE
	.endm

;	Title:			Multiple-Precision Logical Shift Right
;
;	Name:			MPLSR
;
;	Purpose:		Logical shift right a multi-byte operand N bits.
;
;	Entry:
;				TOP OF STACK 
;				High byte of return address
;				Low  byte of return address
;				Number of bits to shift
;				Length of the operand in bytes 
;				High byte of operand base address
;				Low  byte of operand base address
;				The operand is stored with 
;				ARRAY[0] as its Least significant byte and 
;				ARRAY[LENGTH-1] as its most significant byte
;
;	Exit:
;				Operand shifted right filling the most significant bits with zeros.
;				Carry Last bit shifted from Least significant position.	A,B,CC,U,X
;
;	Registers Used:		A,B,CC,U,X
;
;	Time:			48 cycles overhead plus ((13 * Length) + 23) cycles per shift
;
;	Size:			Program 37 bytes
;
MPLSR:
	LDU	,S		; SAVE RETURN ADDRESS
;
; EXIT IF LENGTH OF OPERAND OR NUMBER OF BITS TO SHIFT
; IS ZERO. CARRY IS CLEARED IN EITHER CASE
;
	CLC			; CLEAR CARRY INITIALLY
	LDA	2,S		; GET NUMBER OF BITS TO SHIFT
	BEQ	EXITLS		; EXIT IF NUMBER OF BITS TO SHIFT IS ZERO 
	LDA	3,S		; GET LENGTH OF OPERAND
	BEQ	EXITLS		; EXIT IF LENGTH OF OPERAND IS ZERO
	;
	; SAVE POINTER TO END OF OPERAND
	;
	LDX	4,S		; GET BASE ADDRESS OF OPERAND 
	LEAX	A,X		; CALCULATE ENDING ADDRESS OF OPERAND 
	STX	,S		; SAVE ENDING ADDRESS OF OPERAND
	;
	; SHIFT ENTIRE OPERAND RIGHT ONE BIT LOGICALLY 
	; USE ZERO AS INITIAL CARRY INPUT
	; TO PRODUCE LOGICAL SHIFT
	;
LSRLP:
	LDX	,S		; POINT TO END OF OPERAND
	LDB	3,S		; GET LENGTH OF OPERAND IN BYTES
	CLC			; CLEAR CARRY TO FILL WITH ZEROS
	;
	; SHIFT EACH BYTE OF OPERAND RIGHT ONE BIT
	; START WITH MOST SIGNIFICANT BYTE
	;
LSRLP1:
	ROR		,-X	; SHIFT NEXT BYTE RIGHT
	DECB
	BNE	LSRLP1		; CONTINUE THROUGH ALL BYTES
	;
	; COUNT NUMBER OF SHIFTS
	;
	DEC	2,S		; DECREMENT NUMBER OF SHIFTS 
	BNE	LSRLP		; CONTINUE UNTIL DONE
	;
	; REMOVE PARAMETERS FROM STACK AND EXIT
	;
EXITLS:
	LEAS	6,S		; REMOVE PARAMETERS FROM STACK
	JMP	,U		; EXIT TO RETURN ADDRESS
;
;
; SAMPLE EXECUTION
;
SC4E:
	LDA	SHIFTS		; GET NUMBER OF SHIFTS
	LDB	#SZAY		; GET LENGTH OF OPERAND IN BYTES
	LDX	AYADR		; GET BASE ADDRESS OF OPERAND
	PSHS	A,B,X		; SAVE PARAMETERS IN STACK
	JSR	MPLSR		; LOGICAL SHIFT RIGHT
				; RESULT OF SHIFTING AY=EDCBAO87654321H
				; 4 BITS IS AY=0EDCBA98765432H, C=0
				; IN MEMORY
				; AY   = 032H
				; AY+1 = 054H
				; AY+2 = 076H
				; AY+3 = 098H
				; AY+4 = 0BAH
				; AY+5 = 0DCH
				; AY+6 = 0DEH
	BRA	SC4E
;
; DATA SECTION
;
SZAY	EQU	7			; LENGTH OF OPERAND IN BYTES

SHIFTS:	FCB	4			; NUMBER OF SHIFTS

AYADR:	FDB	AY			; BASE ADDRESS OF OPERAND

AY:	FCB	$21,$43,$65,$87,$A9,$CB,$ED

	END

