;
;	Right shift 32bit signed
;
	.export tosasreax

	.code

tosasreax:	
	cmpb	#32
	bcc	ret0
	tstb
	beq noshift
	tsx
loop:
	asr	2,x
	ror	3,x
	ror	4,x
	ror	5,x
	decb
	bne loop
	ldaa	2,x
	ldab	3,x
	; Get the value
	staa	@sreg
	stab	@sreg+1
	ldaa	4,x
	ldab	5,x
noshift:
	jmp pop4
ret0:
	clra
	clrb
	staa	@sreg
	stab	@sreg+1
	bra	noshift
