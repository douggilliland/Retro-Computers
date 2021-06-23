;
;	Complement the 32bit working register
;
	.setcpu 6803
	.export compleax

	.code

compleax:
	std @tmp
	ldd @sreg
	coma
	comb
	std @sreg
	ldd @tmp
	coma
	comb
	rts
