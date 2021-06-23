;
;	Boolean negation
;
	.code
	.export bnega
	.export bnegax


bnegax:	tsta
	bne ret0
bnega:	tstb
	bne ret0
	ldaa @one
	ldab @one+1
	rts
ret0:
	clra
	clrb
	rts
