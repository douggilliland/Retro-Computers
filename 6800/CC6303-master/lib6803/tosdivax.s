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

	.setcpu 6803

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
	ldd @tmp		; Dividend is signed, fix up remainder
	oraa #$80		; Force negative
	jmp pop2
dd_unsigned:
	ldd @tmp		; Will be unsigned
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
	std @tmp		; save quotient whilst we fix up the sign
	pula			; sign of the dividend
	tsx
	eora ,x			; A bit 7 is now the xor of the signs
	ins
	bra signfix		; shared sign fixing
