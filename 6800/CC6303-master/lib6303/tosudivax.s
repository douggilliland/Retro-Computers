;
;	D = TOS / D (unsigned)
;

	.export tosudivax
	.setcpu 6303
	.code

tosudivax:
	tsx
	ldx 2,x			; get top of stack
	jsr div16x16		; D is now quotient
	xgdx
	jmp pop2
