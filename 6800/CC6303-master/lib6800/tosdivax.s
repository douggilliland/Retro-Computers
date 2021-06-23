;
;	D = TOS / D signed
;
;	The rules for signed divide are
;	Dividend and remainder have the same sign
;	Quotient is negative if signs disagree
;
;	So we do the maths in unsigned then fix up
;
	.export tosdivax
	.export tosmodax

	.code

tosmodax:
	tsx
	anda #$7F		; make positive
	ldx 2,x
	psha			; save the sign of the dividend
	anda #$7F		; make positive
	jsr div16x16		; do the unsigned divide
				; D = quotient, X = remainder
	stx @tmp		; save remainder whilst we fix up the sign
	pula			; sign of the dividend
signfix:
	bita #$80		; negative ?
	beq dd_unsigned
	ldaa @tmp		; Dividend is signed, fix up remainder
	ldab @tmp+1
	oraa #$80		; Force negative
	jmp pop2
dd_unsigned:
	ldaa @tmp		; Will be unsigned
	ldab @tmp+1
	jmp pop2
	

tosdivax:
	tsx
	psha			; save sign of divisor
	anda #$7F		; make positive
	ldx 2,x
	psha			; save the sign of the dividend
	anda #$7F		; make positive
	jsr div16x16		; do the unsigned divide
				; D = quotient, X = remainder
	staa @tmp		; save quotient whilst we fix up the sign
	stab @tmp+1
	pula			; sign of the dividend
	tsx
	eora 0,x		; A bit 7 is now the xor of the signs
	ins
	bra signfix		; shared sign fixing
