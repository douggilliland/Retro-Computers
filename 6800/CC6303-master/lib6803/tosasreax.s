;
;	Right shift 32bit signed
;
	.export tosasreax

	.setcpu 6803
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
	ldd	2,x
	; Get the value
	std	@sreg
	ldd	4,x
noshift:
	jmp pop4
ret0:
	clra
	clrb
	std	@sreg
	bra	noshift
