;
;	Boolean negation
;
	.setcpu 6803

	.code

	.export bnega
	.export bnegax

bnegax:	tsta
	bne ret0
bnega:	tstb
	bne ret0
	ldd @one
	rts
ret0:
	clra
	clrb
	rts
