;
;	Negate the working register
;
	.export negeax

	.code

negeax:
	subb #1
	sbca #0
	staa @tmp
	stab @tmp+1
	ldaa @sreg
	ldab @sreg+1
	sbcb #0
	sbca #0
	coma
	comb
	staa @sreg
	stab @sreg+1
	ldaa @tmp
	ldab @tmp+1
	coma
	comb
	rts
