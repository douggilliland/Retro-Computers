;
;	Multiply D by 3
;
	.export mulax6

	.setcpu 6803
	.code

mulax6:
	std @tmp1
	lsld
	addd @tmp1
	lsld
	rts
