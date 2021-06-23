;
;	Right shift unsigned  TOS >> D
;

	.export tosshrax

	.setcpu 6803
	.code

tosshrax:
	cmpb #15		; More bits are meaningless
	bgt ret0
	tsx
	cmpb #8
	beq shr8
	bls loop
	ldaa 2,x
	staa 3,x
	clr 2,x
	subb #8
loop:
	tstb
	beq retdone
	lsr 2,x
	ror 3,x
	decb
	bra loop
ret0:
	ldd @zero
	jmp pop2
retdone:
	jmp pop2get
shr8:
	ldab 2,x
	clra
	jmp pop2
