	.macro	CLC
		ANDCC	#$FE
	.endm

; 	Title:			Multiple-precision Logical Shift Left
; 	Name:			MPLSL
;
;
; 	Purpose:		Logical shift left a multibyte operand
; 				N bits.
;
; 	Entry:			TOP OF STACK
; 				High byte of return address
; 				Low  byte of return address
; 				Number of bits to shift
;				Length of the operand in bytes
; 				High byte of operand base address
; 				Low  byte of operand base address
; 				The operand is stored with ARRAY[0] as its
; 				Least significant byte and ARRAY[LENGTH-1]
;				as its most significant byte
;
; 	Exit:			Operand shifted left filling the least
; 				significant bits with zeros.
; 				CARRY Last bit shifted from most
; 				significant position
;
; 	Registers Used:		A,B,CC,U,X
;
; 	Time:			32 cycles overhead plus
; 				((13 * length) + 24) cycles per shift
;
; 	Size:			Program	 31 bytes
;
;
;
MPLSL:
	LDU	,S		; SAVE RETURN ADDRESS
;
; EXIT IF LENGTH OF OPERAND OR NUMBER OF BITS TO SHIFT
; IS ZERO. CARRY IS CLEARED IN EITHER CASE
;
	CLC			; CLEAR CARRY
	LDA	2,S		; GET NUMBER OF BITS TO SHIFT
	BEQ	EXITLSL		; EXIT IF NUMBER OF BITS TO SHIFT IS ZERO
	LDA	3,S		; GET LENGTH OF OPERAND
	BEQ	EXITLSL		; EXIT IF LENGTH OF OPERAND IS ZERO
;
; SHIFT ENTIRE OPERAND LEFT ONE BIT LOGICALLY
; USE ZERO AS INITIAL CARRY INPUT TO PRODUCE LOGICAL SHIFT
;
LSLLP:
	LDX	4,S		; POINT TO LEAST SIGNIFICANT BYTE
	LDB	3,S		; GET LENGTH OF OPERAND IN BYTES 
	CLC			; CLEAR CARRY TO FILL WITH ZEROS
;
; SHIFT EACH BYTE OF OPERAND LEFT ONE BIT 
; START WITH LEAST SIGNIFICANT BYTE
;
LSLLP1:
	ROL	,X+		; SHIFT NEXT BYTE LEFT
	DECB 
	BNE	LSLLP1		; CONTINUE THROUGH ALL BYTES
	;
	; COUNT NUMBER OF SHIFTS
	;
	DEC	2,S 		; DECREMENT NUMBER OF SHIFTS
	BNE	LSLLP		; CONTINUE UNTIL DONE
	;
	; REMOVE PARAMETERS FROM STACK AND EXIT
	;
EXITLSL:
	LEAS	6,S		; REMOVE PARAMETERS FROM STACK
	JMP	,U		; EXIT TO RETURN ADDRESS
;
; SAMPLE EXECUTION
;
SC4D:
	LDA	SHIFTS		; GET NUMBER OF SHIFTS
	LDB	#SZAY		; GET LENGTH OF OPERAND IN BYTES 
	LDX	AYADR		; GET BASE ADDRESS OF OPERAND
	PSHS	A,B,X		; SAVE PARAMETERS IN STACK
	JSR	MPLSL		; LOGICAL SHIFT LEFT
				; RESULT OF SHIFTING AY=EDCBAO87654321H
				; 4 BITS IS AY=DCBA9876543210H, C=0
				; IN MEMORY
				; AY   = 010H
				; AY+1 = 032H
				; AY+2 = 054H
				; AY+3 = 076H
				; AY+4 = 098H
				; AY+5 = 0BAH
				; AY+6 = 0DCH
	BRA	SC4D
;
; DATA SECTION
;
SZAY 	EQU	7		; LENGTH OF OPERAND IN BYTES

SHIFTS:	FCB	4		; NUMBER OF SHIFTS 		

AYADR:	FDB	AY		; BASE ADDRESS OF OPERAND		

AY:	FCB	$21,$43,$65,$87,$A9,$CB,$ED

	END


