;
;	D = TOS / D (unsigned)
;

	.export tosudivax
	.code

tosudivax:
	tsx
	ldx 2,x			; get top of stack
	jsr div16x16		; X is now quotient
	stx @tmp
	ldaa @tmp
	ldab @tmp+1
	jmp pop2
