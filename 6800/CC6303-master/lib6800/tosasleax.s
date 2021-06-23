;
;	Left shift 32bit signed
;
	.export tosasleax
	.export tosshleax

	.code

;
;	TODO: optimize 8, 16 steps on asl and asr cases
;
tosasleax:	
tosshleax:
	cmpb	#32
	bcc	ret0
	tstb
	beq noshift
	tsx
loop:
	asl	5,x
	rol	4,x
	rol	3,x
	rol	2,x
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
