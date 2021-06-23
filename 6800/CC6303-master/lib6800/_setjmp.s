;
;	Setjmp is nice and simple on the 6803/6303. X is scratch, D is
;	return so only the program counter and S matter
;
	.export __setjmp
	.code

__setjmp:
	tsx
	ldaa	,x
	ldab	1,x		; return address
	ldx	2,x		; get the jmp buffer
	sts	,x		; remember the stack pointer
	staa	2,x		; return address
	stab	3,x
	clra
	clrb
	jmp 	ret4
