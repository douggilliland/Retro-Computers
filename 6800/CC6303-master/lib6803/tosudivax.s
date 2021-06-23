;
;	D = TOS / D (unsigned)
;

	.export tosudivax
	.setcpu 6803
	.code

tosudivax:
	tsx
	ldx 2,x			; get top of stack
	jsr div16x16		; X is now quotient
	stx @tmp
	ldd @tmp
	jmp pop2
