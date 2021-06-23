;
;	Negate the working register
;
	.export negeax

	.setcpu 6803
	.code

negeax:
	subd #1
	std @tmp
	ldd @sreg
	sbcb #0
	sbca #0
	coma
	comb
	std @sreg
	ldd @tmp
	coma
	comb
	rts
